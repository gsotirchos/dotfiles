"""Runs glab through bin/gitlab-redact-proxy against a fake GitLab.

Usage:
    python3 -m unittest discover tests
"""

import json
import os
import socket
import subprocess
import tempfile
import threading
import time
import unittest
from typing import ClassVar
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
PROXY = REPO / "bin/gitlab-redact-proxy"
GUARD = REPO / "packages/claude/.claude/hooks/guard-gitlab-token.sh"

OWN = {"id": 1, "username": "georgesotirchos", "name": "George Sotirchos"}
ALICE = {
    "id": 2,
    "username": "alice.w",
    "name": "Alice Wonder",
    "avatar_url": "https://gitlab.example/uploads/alice.png",
    "web_url": "https://gitlab.example/alice.w",
}
MERGE_REQUEST = {
    "iid": 1,
    "title": "Fix the planner, thanks @carol",
    "description": "Thanks @alice.w and @georgesotirchos, building on Bob Builder's"
    " work.\n\nSigned-off-by: Dave Diver <dave@diver.org>",
    "author": ALICE,
    "assignees": [OWN],
    "reviewers": [ALICE],
}
COMMITS = [
    {
        "id": "abc",
        "author_name": "Bob Builder",
        "author_email": "bob@tudelft.nl",
        "message": "Speed up planner",
    }
]
GRAPHQL = {
    "data": {
        "user": {
            "id": "gid://gitlab/User/2",
            "username": "alice.w",
            "name": "Alice Wonder",
            "webUrl": "https://gitlab.example/alice.w",
            "publicEmail": "alice@tudelft.nl",
        }
    }
}
RAW_FILE = "# Maintainer: Bob Builder <bob@tudelft.nl>\n@dataclass\nclass Plan: ...\n"
COLLEAGUE_DATA = (
    "alice.w",
    "Alice Wonder",
    "alice.png",
    "alice@tudelft.nl",
    "carol",
    "Bob Builder",
    "bob@tudelft.nl",
    "Dave Diver",
    "dave@diver.org",
)


def free_port() -> int:
    with socket.socket() as probe:
        probe.bind(("127.0.0.1", 0))
        return probe.getsockname()[1]


class FakeGitLab(BaseHTTPRequestHandler):
    authorizations: ClassVar[list[str]] = []

    def do_GET(self):
        self.authorizations.append(self.headers["Authorization"])
        routes = {
            "/api/v4/user": OWN,
            "/api/v4/projects/grp%2Fproj/merge_requests/1": MERGE_REQUEST,
            "/api/v4/projects/grp%2Fproj/repository/commits": COMMITS,
        }
        path = self.path.split("?")[0]
        if path.endswith("/raw"):
            self.reply(RAW_FILE.encode(), "text/plain")
        elif path in routes:
            self.reply(json.dumps(routes[path]).encode(), "application/json")
        else:
            self.send_error(404)

    def do_POST(self):
        self.rfile.read(int(self.headers["Content-Length"]))
        self.reply(json.dumps(GRAPHQL).encode(), "application/json")

    def reply(self, body: bytes, content_type: str):
        upstream = f"http://{self.headers['Host']}"
        self.send_response(200)
        self.send_header("Content-Type", content_type)
        self.send_header("Link", f'<{upstream}{self.path}&page=2>; rel="next"')
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, *_):
        pass


class GitLabRedactProxyTest(unittest.TestCase):
    home: tempfile.TemporaryDirectory[str]
    upstream: ThreadingHTTPServer
    port: int
    proxy: subprocess.Popen[bytes]

    @classmethod
    def setUpClass(cls):
        cls.home = tempfile.TemporaryDirectory()
        cls.upstream = ThreadingHTTPServer(("127.0.0.1", 0), FakeGitLab)
        threading.Thread(target=cls.upstream.serve_forever, daemon=True).start()
        cls.port = free_port()
        cls.proxy = subprocess.Popen(
            [
                PROXY,
                f"--port={cls.port}",
                f"--upstream=http://127.0.0.1:{cls.upstream.server_port}",
                "--token-command=echo real-token",
            ],
            env=os.environ | {"HOME": cls.home.name},
            stderr=subprocess.DEVNULL,
        )
        deadline = time.monotonic() + 10
        while True:
            try:
                socket.create_connection(("127.0.0.1", cls.port)).close()
                break
            except ConnectionRefusedError:
                if time.monotonic() > deadline:
                    raise
                time.sleep(0.05)

    @classmethod
    def tearDownClass(cls):
        cls.proxy.terminate()
        cls.proxy.wait()
        cls.upstream.shutdown()
        cls.home.cleanup()

    def glab(self, *args: str) -> str:
        env = os.environ | {
            "HOME": self.home.name,
            "GLAB_CONFIG_DIR": self.home.name,
            "GLAB_CHECK_UPDATE": "false",
            "GITLAB_HOST": "gitlab.tudelft.nl",
            "GITLAB_TOKEN": "via-redact-proxy",
            "GITLAB_API_HOST": f"127.0.0.1:{self.port}",
            "GLAB_API_PROTOCOL": "http",
        }
        return subprocess.run(
            ["glab", *args],
            env=env,
            cwd=self.home.name,
            capture_output=True,
            text=True,
            check=True,
        ).stdout

    def outputs(self) -> list[str]:
        """Commits first, so Bob Builder is known by the time the file is read."""
        return [
            self.glab("api", "projects/grp%2Fproj/repository/commits"),
            self.glab("api", "-i", "projects/grp%2Fproj/merge_requests/1"),
            self.glab("api", "projects/grp%2Fproj/repository/files/plan.py/raw"),
            self.glab("api", "graphql", "-f", "query={ user { username } }"),
        ]

    def test_colleagues_are_pseudonymised(self):
        output = "\n".join(self.outputs())
        for colleague_data in COLLEAGUE_DATA:
            self.assertNotIn(colleague_data, output)
        self.assertIn("user-", output)

    def test_own_user_and_code_stay_readable(self):
        _, merge_request, raw_file, _ = self.outputs()
        merge_request = json.loads(merge_request.split("\n\n", 1)[1])
        self.assertEqual(merge_request["assignees"], [OWN])
        self.assertIn("@georgesotirchos", merge_request["description"])
        self.assertIn("@dataclass", raw_file)

    def test_pseudonyms_are_stable(self):
        first = json.loads(self.glab("api", "projects/grp%2Fproj/merge_requests/1"))
        second = json.loads(self.glab("api", "projects/grp%2Fproj/merge_requests/1"))
        self.assertEqual(first, second)
        self.assertEqual(first["author"]["username"], first["reviewers"][0]["username"])
        self.assertNotIn("avatar_url", first["author"])

    def test_upstream_gets_real_token_and_link_stays_behind_proxy(self):
        merge_request = self.glab("api", "-i", "projects/grp%2Fproj/merge_requests/1")
        self.assertEqual(set(FakeGitLab.authorizations), {"Bearer real-token"})
        self.assertIn(f"http://127.0.0.1:{self.port}/api/v4/", merge_request)


class GuardHookTest(unittest.TestCase):
    def exit_code(self, command: str) -> int:
        hook_input = json.dumps({"tool_input": {"command": command}})
        return subprocess.run(
            [GUARD], input=hook_input, capture_output=True, text=True, check=False
        ).returncode

    def test_blocks_token_access(self):
        for command in (
            "secret-tool lookup service glab",
            "glab config get token -h gitlab.tudelft.nl",
            "env -u GITLAB_TOKEN glab api user",
            "cat ~/.config/glab-cli/config.yml",
            "curl https://gitlab.tudelft.nl/api/v4/user",
            "python3 -c 'import secretstorage'",
        ):
            with self.subTest(command=command):
                self.assertEqual(self.exit_code(command), 2)

    def test_allows_proxied_glab(self):
        self.assertEqual(self.exit_code("glab mr list -R grp/proj"), 0)


if __name__ == "__main__":
    unittest.main()

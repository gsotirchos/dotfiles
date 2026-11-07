// OpenCode bridge for the gitlab-redact-proxy setup that Claude Code gets via
// packages/claude/.claude/settings.json + hooks/guard-gitlab-token.sh:
//
//   - PreToolUse hook guard-gitlab-token.sh: blocks shell commands that would
//     reach the real GitLab token (keyring, glab's own config) or GitLab past
//     gitlab-redact-proxy.
//   - the `env` block: route every agent shell's glab through the proxy.
//
// The denylist lives in the shared bash script (also used by Claude Code);
// this plugin only bridges OpenCode's hooks to it. Keep this file thin.
import { execFile } from "node:child_process"
import { homedir } from "node:os"
import { join } from "node:path"
import { Plugin } from "@opencode/plugin"

const guardScript = join(homedir(), ".claude", "hooks", "guard-gitlab-token.sh")

// Mirror of the `env` block in packages/claude/.claude/settings.json — keep the
// two in sync (values: glab → gitlab-redact-proxy on 127.0.0.1:8383).
const glabEnv = {
  GITLAB_TOKEN: "via-redact-proxy",
  GITLAB_API_HOST: "127.0.0.1:8383",
  GLAB_API_PROTOCOL: "http",
} as const

// Runs the shared guard script with the command as $1. Exit 2 = block (stderr
// is the reason shown to the model); exit 0 = allow. Any other outcome fails
// open — the guard is a denylist against accidental access, not a security
// boundary.
function guard(command: string): Promise<{ blocked: boolean; reason: string }> {
  return new Promise((resolve) => {
    execFile("bash", [guardScript, command], { timeout: 10_000 }, (error, _stdout, stderr) => {
      // Node types error.code as string, but for a non-zero exit it is the
      // numeric exit status.
      const exitCode = (error as { code?: number | string } | null)?.code
      if (error && exitCode === 2) {
        resolve({
          blocked: true,
          reason: stderr.trim() || "blocked by gitlab-redact-proxy guard",
        })
        return
      }
      if (error) {
        console.warn(
          `gitlab-redact-guard: guard script failed for ${JSON.stringify(command)}: ${error.message}; allowing`,
        )
      }
      resolve({ blocked: false, reason: "" })
    })
  })
}

export default Plugin.define({
  id: "gitlab-redact-guard",
  async setup(ctx) {
    // Parity: PreToolUse → guard-gitlab-token.sh
    await ctx.permission.hook("evaluate", async (event) => {
      if (event.action !== "shell") return
      for (const command of event.resources) {
        const { blocked, reason } = await guard(command)
        if (blocked) {
          event.effect = "deny"
          event.message = reason
          return
        }
      }
    })

    // Parity: settings.json `env` — route agent shells' glab through the proxy
    await ctx.shell.hook("create.before", (event) => {
      Object.assign(event.env, glabEnv)
    })
  },
})

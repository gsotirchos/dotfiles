# Emacs and devcontainers

A devcontainer image carries a project's build environment — compiler, ROS
underlay, headers, `site-packages` — but none of the editor tooling. VS Code
moves its whole editor server into the container to get at them. This setup
does the opposite: Emacs stays on the host, editing the host's copy of the
files (the workspace is a bind mount, so it *is* the same file), and only the
tools that need the image's filesystem run inside the container: `clangd`,
`pyright` and `mypy`. Everything that only reads the source — ruff, the
formatters, the other linters — runs on the host as always.

Nothing is written into the project. A container VS Code started is used
as-is, and VS Code will use one started from here.

## Setup

Once per container, from anywhere inside the workspace:

```bash
devcontainer-exec --provision
```

Re-run it after the container has been rebuilt.

If the container is not running yet, start it from the package that holds
`.devcontainer/` (or from VS Code):

```bash
devcontainer-exec -C ~/Projects/my_workspace/src/pkg true
```

Every package under the workspace mount is then served by it. Do not symlink
`.devcontainer/` to the workspace root to avoid this: `devcontainer.json` is
written relative to its own location, so the container would get the wrong
mounts and VS Code would not recognise it.

## Use

Open files as usual. In a buffer the container mounts, Eglot's language
server runs in the container and `M-.`, hover, completion and diagnostics
work as if it were local. A file that exists only in the container — a header
under `/opt/ros`, a module in the image's `site-packages` — opens read-only
over TRAMP.

`M-x compile` builds the current colcon package in the container; edit the
package selection in the prompt as needed. `next-error` lands in the host's
files. Build from `compile` at least once per package: it also produces what
clangd needs to know the package's include paths, and a workspace built
before this setup has none of that yet — until then clangd reports
`'…/msg/x.hpp' file not found` for anything outside the system headers.

`C-c c r` (`my-devcontainer-refresh`) re-reads the container's environment
and restarts the server. Use it after a build that extended what the tools
can see (new packages on `PYTHONPATH`/`AMENT_PREFIX_PATH`), after the
container was recreated, or when Eglot connected to the host server because
the container was not running at the time.

`devcontainer-exec CMD` runs any command in the container from a terminal,
with the environment a VS Code terminal would have.

## How it works

`devcontainer-exec` asks Docker which running devcontainer bind-mounts the
directory in question, probes that container's environment once with the
devcontainer CLI (cached under `~/.cache/devcontainer-exec/`), and runs
commands with plain `docker exec` — a few tens of milliseconds, against the
better part of a second for `devcontainer exec`.

Paths differ between the two sides (`~/Projects/ws` on the host is
`/workspace` in the container). clangd is told the mapping; pyright and mypy
are given host paths, which resolve in the container through a symlink
`--provision` creates. In the other direction, `site-lisp/my-devcontainer.el`
translates the locations servers report back to host files where they exist,
and to TRAMP paths where they do not. Buffers outside any devcontainer are
untouched.

## Troubleshooting

*no .devcontainer above …* — the directory is mounted by no running container
and has no `.devcontainer/` above it; start the container as under Setup.

*… is not mounted into the container* — the file is outside every bind
mount, so the container cannot see it.

Pyright cannot resolve a package of the workspace itself — the container's
shell has to source `install/setup.bash` (in its `~/.bashrc`, after the ROS
underlay); then `C-c c r`.

The first `devcontainer-exec` call for a container that is not running blocks
until it is up, which may include building the image; starting it from a
terminal first avoids waiting inside Emacs.

For TRAMP trouble in the read-only container buffers, see
[TRAMP-SSH-TROUBLESHOOTING.md](TRAMP-SSH-TROUBLESHOOTING.md) — there is no SSH
layer here, but the TRAMP layer is the same.

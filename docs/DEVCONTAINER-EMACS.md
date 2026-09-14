# Emacs and devcontainers

A devcontainer image carries a project's build environment — compiler, ROS
underlay, headers, `site-packages` — but none of the editor tooling. VS Code
solves that by moving its whole editor server into the container. This setup
does the opposite: Emacs stays on the host, editing the host's copy of the
files (the workspace is a bind mount, so it *is* the same file), and only the
tools that need the image's filesystem run inside the container:

|Tool                                                      |Runs in  |Why                                                        |
|----------------------------------------------------------|---------|-----------------------------------------------------------|
|`clangd`                                                  |container|headers under `/opt/ros`, `/opt/tesseract*`, `/usr/include`|
|`pyright-langserver`                                      |container|`rclpy` and friends live in the image's `site-packages`    |
|`mypy`                                                    |container|same reason                                                |
|ruff, clang-format, cmake-lint, bashate, shfmt, formatters|host     |pure syntax; their configs are in the repo                 |
|`colcon build`                                            |container|as always                                                  |

Nothing needs to be written into the project: no `.dir-locals.el`, no change
to `devcontainer.json`. A container VS Code started is picked up as-is.

## One-time setup

From anywhere inside the workspace, with the container running (or not — it
is started if needed):

```bash
devcontainer-exec --provision
```

This installs `clangd`, `pyright` and `mypy` into the container, exports
`CMAKE_EXPORT_COMPILE_COMMANDS=1` in the container's `~/.bashrc`, and creates a
symlink so that the workspace is reachable under its *host* path inside the
container too. Re-run it after the container has been rebuilt; it is
idempotent.

## Daily use

Open files as usual. When a buffer belongs to a directory a running
devcontainer mounts, Eglot starts the language server through
`devcontainer-exec` instead of the host binary, and `M-.`, hover, completion
and diagnostics work as if the server were local. A location the server
reports that exists only in the container — a header under `/opt/ros`, a
module in the image's `site-packages` — opens read-only over TRAMP at
`/docker:USER@ID:/...`.

In a buffer of a colcon package, `M-x compile` is pre-filled with

```bash
devcontainer-exec -C WORKSPACE colcon build --packages-select PKG \
    --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && merge-compile-commands WORKSPACE
```

which builds the package in the container and merges the per-package
databases into the one `build/compile_commands.json` clangd reads. Edit the
package selection as needed (`--packages-up-to`, none at all); `next-error`
visits the host's copy of a file the compiler reports as `/workspace/...`.
The same command works from any terminal.

The flag is passed explicitly, even though `--provision` exports it in the
container, because the environment variable only seeds a package's CMake cache
on its first configure: a workspace built before provisioning keeps an empty
setting until it is reconfigured with the flag. Until a file's package has a
database entry, clangd guesses its flags and reports
`'…/some_msgs/msg/x.hpp' file not found` for anything outside the system
include paths — a build of that package from `compile` fixes it.

`C-c c r` (`my-devcontainer-refresh`) is the fix whenever the container's
view of the world has changed: a build that extended `PYTHONPATH` or
`AMENT_PREFIX_PATH`, a recreated container. It re-probes the environment and
restarts the server.

`devcontainer-exec` is also a plain command runner:

```bash
devcontainer-exec [-C DIR] CMD [ARG...]  # run CMD in the container mounting DIR (default: $PWD)
devcontainer-exec --mappings [DIR]       # bind mounts as HOST=CONTAINER, comma-joined
devcontainer-exec --container [DIR]      # USER@ID of the container, for TRAMP
devcontainer-exec --refresh [DIR]        # re-probe the container's environment
```

## How it works

`devcontainer-exec` finds the container by asking Docker which running
devcontainer bind-mounts the directory in question, so it works from any
package of a colcon workspace, not only the one carrying `.devcontainer/`.
If none is running it walks up to the nearest `.devcontainer/` and runs
`devcontainer up` there.

Commands are run with plain `docker exec` (~40 ms), not `devcontainer exec`
(~700 ms: node start-up plus an environment probe on every call). The
environment a VS Code terminal would see — the `userEnvProbe` login shell,
which is what sources the ROS underlay — is probed once per container with the
devcontainer CLI and cached in `~/.cache/devcontainer-exec/ID.env`, then handed
to `docker exec --env-file`. Being a snapshot, it goes stale when the
container's environment changes; that is what `--refresh` and `C-c c r`
are for. The cache is keyed by container id, so a rebuilt container is
re-probed on first use.

Paths differ between the two sides (`~/Projects/ws` on the host is
`/workspace` in the container). clangd is told the bind mounts as
`--path-mappings`, which it was built for, and it is the one server that reads
a database written inside the container. pyright and mypy have no such option;
they are given host paths, which resolve in the container through the symlink
`--provision` created. mypy's shadow file — the unsaved buffer contents — is
written to `WORKSPACE/.cache/emacs/` rather than the host's `/tmp`, which the
container cannot see.

On the Emacs side, `site-lisp/my-devcontainer.el` wraps the Eglot contact for
pyright and clangd, points `flymake-mypy` at the container's mypy, filters
`eglot-uri-to-path` so that container-only paths become TRAMP paths (a
`--symlink-install` space is full of links with `/workspace/...` targets,
dangling on the host; those are translated to their `build/` target rather
than opened over TRAMP), sets
`compile-command` for buffers under a `package.xml`, and gives compilation
buffers a `compilation-parse-errors-filename-function` that maps the
container's paths back. Buffers outside any devcontainer are untouched and use
the host servers.

## Troubleshooting

`devcontainer-exec` says *no .devcontainer above …* — the directory is not
mounted into any running devcontainer and has no `.devcontainer/` above it. If
the workspace's configuration lives in a sub-package (as `src/pkg/.devcontainer`
does), start the container from there once, or from VS Code:

```bash
devcontainer-exec -C ~/Projects/my_workspace/src/pkg true
```

Once it runs, every package under the workspace mount is served by it. Do
*not* work around this by symlinking `.devcontainer/` to the workspace root:
`devcontainer.json` is written relative to its own location (this one mounts
`${localWorkspaceFolder}/../../`), so `devcontainer up` from the root would
mount the wrong directory, and the container would be labelled with a folder
VS Code does not recognise, giving you two containers.

`… is not mounted into the container` — the file is outside every bind mount,
so the container cannot see it. Only mounted directories can be served.

Eglot starts the host server instead of the container's — the answer to
“which container serves this directory” is cached per directory; if the
container was started after the buffer was opened, `C-c c r` clears the
cache and reconnects.

Pyright cannot resolve a module of the workspace itself — the probed
environment does not include `install/` unless the container's shell sources
`install/setup.bash`; do so in the container's `~/.bashrc` (after the ROS
underlay) and `--refresh`.

The first `devcontainer-exec` call for a container that is not running blocks
until `devcontainer up` returns, which may include building the image. Starting
it from VS Code or a terminal first avoids waiting inside Emacs.

For TRAMP problems in the read-only header buffers, see
[TRAMP-SSH-TROUBLESHOOTING.md](TRAMP-SSH-TROUBLESHOOTING.md) — the docker
method has no SSH layer, but the TRAMP layer is the same.

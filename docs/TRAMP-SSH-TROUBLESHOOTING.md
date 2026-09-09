# TRAMP over SSH — troubleshooting

Emacs reaches remote files through TRAMP, which drives a real `ssh` client, so a
"weird Emacs problem" on a remote file is usually a stuck SSH master or a stale
TRAMP cache rather than anything wrong in `init.el` — knowing which layer to
poke saves restarting Emacs (or worse, blaming the remote host).

The `coby-*` hosts use SSH connection sharing: `~/.ssh/config` sets
`ControlMaster auto` with a persistent master, and `init.el` sets
`tramp-use-connection-share` to `nil` so TRAMP defers to it instead of passing
its own `-o` flags. One master is therefore shared by Emacs, the shell, `git`
and `rsync`.

## SSH layer

`-O` talks to the running master process:

```bash
ssh -O check coby-nuc     # is a master alive? prints its PID
ssh -O exit  coby-nuc     # kill it — the most useful fix for a wedged connection
ssh -O stop  coby-nuc     # stop accepting new clients, let current ones finish
ls -l ~/.ssh/cm-*         # which sockets exist right now
ssh -G coby-nuc           # effective config, resolved, without connecting
ssh -vvv coby-nuc         # full handshake trace
ssh -o ControlPath=none coby-nuc   # bypass sharing — isolates "is it the master?"
```

The failure mode to recognise: the host drops off the network and the socket
goes stale, so every new connection hangs or gives `control socket connect:
Connection refused`. `ssh -O exit` clears it instantly; `ServerAliveInterval 60`
with `ServerAliveCountMax 3` makes it self-clear in about three minutes.

## TRAMP layer

All `M-x`:

```text
tramp-cleanup-this-connection        drop the connection for the current buffer
tramp-cleanup-all-connections        drop all — run after any ssh/tramp change
tramp-cleanup-all-buffers            the above, plus kill the remote buffers
tramp-list-remote-buffer-connections what is currently open
```

TRAMP caches connection properties per host, so **any** change to `~/.ssh/config`
or to `tramp-remote-path` needs `tramp-cleanup-all-connections` (or an Emacs
restart) before it takes effect.

For real debugging, `M-: (setq tramp-verbose 6)`, reproduce, then read
`*debug tramp/ssh coby-nuc*`. Level 6 is the useful one — the first that logs the
actual strings sent to and received from the remote shell:

| Level | Shows |
|-------|-------|
| 3 | connections (TRAMP's default) |
| 4 | activities |
| 5 | internal |
| 6 | strings sent and received |
| 7 | connection properties |
| 8 | file caching |

Set it back to `2` afterwards (the value in `init.el`) — level 6 buffers grow
fast.

If TRAMP misbehaves inconsistently *across restarts*, its persistent cache is at
`~/.emacs.d/var/tramp/persistency.el` (relocated there by `no-littering`).
Deleting it with Emacs closed is a last resort.

## Order of operations

`ssh -O check` → if a master is stuck, `ssh -O exit` → then
`tramp-cleanup-all-connections`. Clearing TRAMP first while a wedged master
survives just reproduces the problem.

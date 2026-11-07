#!/usr/bin/env bash
# PreToolUse hook: blocks Bash commands that would reach the real GitLab token
# (keyring, glab's own config) or GitLab past gitlab-redact-proxy. A denylist
# against accidental access, not a security boundary.
blocked='secret-tool|gdbus|dbus-send|busctl|secretstorage|keyring'
blocked+='|glab +(auth|config)|glab-cli/'
blocked+='|GITLAB_(TOKEN|API_HOST|HOST|URI)|GL_HOST|API_PROTOCOL'
blocked+='|env +(-[a-zA-Z]*[iu]|--ignore-environment|--unset)'
blocked+='|gitlab\.tudelft\.nl/api|state/gitlab-redact-proxy'

# The command comes either as $1 (OpenCode's gitlab-redact-guard plugin) or as
# the Claude Code hook JSON on stdin.
command="${1:-$(jq -r '.tool_input.command // empty')}"
if match="$(grep -oE -m1 -- "$blocked" <<< "$command")"; then
    echo "Blocked '${match%%$'\n'*}': it bypasses gitlab-redact-proxy." \
        "Use plain glab, whose output the proxy redacts." >&2
    exit 2
fi
exit 0

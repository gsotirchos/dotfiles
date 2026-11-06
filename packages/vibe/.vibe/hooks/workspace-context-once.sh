#!/usr/bin/env bash
# post_tool hook: inject workspace context (ROS / devcontainer rules) once per
# session. Vibe has no SessionStart event, so this fires on the first tool call
# of the session and appends the context to that call's output.

payload="$(cat)"
session_id="$(jq -r '.session_id // empty' <<<"$payload")"
cwd="$(jq -r '.cwd // empty' <<<"$payload")"
[ -n "$session_id" ] || exit 0

marker="${TMPDIR:-/tmp}/vibe-workspace-ctx-${session_id}"
[ -e "$marker" ] && exit 0
touch "$marker"

context="$(CLAUDE_PROJECT_DIR="$cwd" "$HOME/.claude/hooks/workspace-context.sh" 2>/dev/null)" || exit 0
[ -n "$context" ] || exit 0

jq -n --arg ctx "$context" \
    '{decision: "allow", hook_specific_output: {additional_context: $ctx}}'

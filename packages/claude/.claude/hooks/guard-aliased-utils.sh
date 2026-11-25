#!/usr/bin/env bash
# PreToolUse (Bash) and Stop hook: blocks calls of the utilities the user's
# interactive shell aliases (packages/bash/.bash_aliases: grep is rg -p, find
# is fd, rm is trash, cp/mv/ln prompt) unless `env` or `command` precedes
# them, in a Bash command or in a shell code block of the final reply.
utils='grep|find|rm|cp|mv|ln|ls|mkdir'
position='(^|[|;&({`]|\$\(|\b(then|do|else|xargs|sudo|time|exec)[[:space:]])'
prompt='([$][[:space:]]+)?'
pattern="${position}[[:space:]]*${prompt}(${utils})"'([[:space:]]|$)'

# The text of the replies since the user's last prompt, from the transcript.
reply_text() {
    jq -rs '
        reduce .[] as $e ([];
            if $e.type == "user" and ($e.message.content | type) == "string"
            then []
            elif $e.type == "assistant"
            then . + [$e.message.content[]? | select(.type == "text") | .text]
            else . end)
        | join("\n")' "$1"
}

# The lines inside ```bash, ```sh, ```shell, ```zsh and ```console fences.
shell_blocks() {
    awk '
        /^[[:space:]]*```+[[:space:]]*(bash|sh|shell|zsh|console)[[:space:]]*$/ { inside = 1; next }
        /^[[:space:]]*```+[[:space:]]*$/ { inside = 0; next }
        inside'
}

input="$(cat)"
case "$(jq -r '.hook_event_name' <<< "$input")" in
    PreToolUse)
        text="$(jq -r '.tool_input.command // empty' <<< "$input")"
        fix='Run it again with env before each one (env grep, env cp, ...).'
        ;;
    Stop)
        [[ "$(jq -r '.stop_hook_active' <<< "$input")" == true ]] && exit 0
        text="$(reply_text "$(jq -r '.transcript_path' <<< "$input")" | shell_blocks)"
        fix='The user runs these in that shell: rewrite the reply with env before each one.'
        ;;
    *) exit 0 ;;
esac

if matches="$(grep -E -- "$pattern" <<< "$text")"; then
    echo "These lines call a utility the user's shell aliases" \
        "(grep is rg -p, find is fd, rm is trash, cp/mv/ln prompt):" >&2
    echo "$matches" >&2
    echo "$fix" >&2
    exit 2
fi
exit 0

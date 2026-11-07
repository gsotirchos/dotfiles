// OpenCode bridge for Claude Code's SessionStart hook
// packages/claude/.claude/hooks/workspace-context.sh: print the ROS / dev
// container rules that apply to the session's directory. The detection logic
// and the context files live in the shared script; this plugin only feeds it
// the session's directory and injects its output as session instructions.
import { execFile } from "node:child_process"
import { homedir } from "node:os"
import { join } from "node:path"
import { Plugin } from "@opencode/plugin"

const contextScript = join(homedir(), ".claude", "hooks", "workspace-context.sh")

// Runs the shared script with CLAUDE_PROJECT_DIR pointing at the session's
// directory (same contract Claude Code uses); resolves to its stdout, or ""
// on any failure.
function workspaceContext(directory: string): Promise<string> {
  return new Promise((resolve) => {
    execFile(
      "bash",
      [contextScript],
      { timeout: 10_000, env: { ...process.env, CLAUDE_PROJECT_DIR: directory } },
      (error, stdout) => {
        if (error) {
          console.warn(`workspace-context: script failed for ${directory}: ${error.message}`)
          resolve("")
          return
        }
        resolve(stdout)
      },
    )
  })
}

export default Plugin.define({
  id: "workspace-context",
  async setup(ctx) {
    // sessionID → last injected content; skip unchanged to avoid re-announcing
    const lastFor = new Map<string, string>()
    await ctx.session.hook("prompt", async (event) => {
      try {
        const session = await ctx.session.get({ sessionID: event.sessionID })
        const content = await workspaceContext(session.location.directory)
        if (!content || lastFor.get(event.sessionID) === content) return
        lastFor.set(event.sessionID, content)
        await ctx.session.instructions.entry.put({
          sessionID: event.sessionID,
          key: "workspace-context",
          value: content,
        })
      } catch (error) {
        console.warn(`workspace-context: skipping prompt: ${error}`)
      }
    })
  },
})

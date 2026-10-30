import type { SessionMessageInfo } from "@opencode/client"
import { Plugin } from "@opencode/plugin/tui"
import { For, Show } from "solid-js"

const MODEL = { providerID: "lego-anthropic", id: "claude-haiku-5-5" }
const PROMPT_COUNT = 5
const TRANSCRIPT_MESSAGES = 30
const MAX_CHARS_PER_MESSAGE = 1500

type Recap = {
  prompts: { id: string; summary: string }[]
  status?: string
  updated?: number
}

function messageText(message: SessionMessageInfo): string {
  if (message.type === "user") return message.text
  if (message.type === "assistant")
    return (message.content ?? [])
      .flatMap((part) => (part.type === "text" ? [part.text] : []))
      .join("\n")
  return ""
}

function oneLine(text: string) {
  return text.replace(/\s+/g, " ").trim()
}

function ago(time: number) {
  const minutes = Math.round((Date.now() - time) / 60_000)
  if (minutes < 1) return "just now"
  if (minutes < 60) return `${minutes}m ago`
  const hours = Math.round(minutes / 60)
  if (hours < 24) return `${hours}h ago`
  return `${Math.round(hours / 24)}d ago`
}

export default Plugin.define({
  id: "session-recap",
  setup(context) {
    const [recaps, updateRecaps] = context.storage.store("recaps", {
      initial: { sessions: {} as Record<string, Recap> },
    })
    const [busy, updateBusy] = context.storage.memory("busy", {
      initial: { sessions: {} as Record<string, boolean> },
    })

    async function generate(prompt: string) {
      const client = context.client as any
      const text = client.generate?.text ?? client.experimental?.generate?.text
      const result = await text({ prompt, model: MODEL })
      return oneLine(result.text ?? result.data?.text ?? "")
    }

    function summarizePrompt(text: string) {
      return generate(
        [
          "Summarize this request a user sent to a coding assistant in at most 8 words.",
          "Reply with the summary only: no quotes, no trailing period.",
          "",
          "<request>",
          text.slice(0, 4000),
          "</request>",
        ].join("\n"),
      )
    }

    function summarizeStatus(transcript: string) {
      return generate(
        [
          "Below is the end of a conversation between a user and a coding assistant.",
          "Write a recap so the user can resume the task later. Reply in exactly this format, each line under 20 words:",
          "Now: <where the task currently stands>",
          "Next: <the next concrete step>",
          "",
          "<conversation>",
          transcript,
          "</conversation>",
        ].join("\n"),
      )
        .then((text) => text.replace(/\s*Next:/, "\nNext:"))
    }

    async function refresh(sessionID: string) {
      if (busy.sessions[sessionID]) return
      if (context.data.session.get(sessionID)?.parentID) return
      updateBusy((draft) => {
        draft.sessions[sessionID] = true
      })
      try {
        await context.data.session.message.sync(sessionID)
        const messages = context.data.session.message
          .list(sessionID)
          .toSorted((a, b) => (a.time?.created ?? 0) - (b.time?.created ?? 0))

        const known = new Map((recaps.sessions[sessionID]?.prompts ?? []).map((p) => [p.id, p.summary]))
        const recent = messages.filter((m) => m.type === "user" && messageText(m).trim()).slice(-PROMPT_COUNT)
        const prompts = await Promise.all(
          recent.map(async (m) => ({
            id: m.id,
            summary: known.get(m.id) ?? (await summarizePrompt(messageText(m))),
          })),
        )

        const transcript = messages
          .slice(-TRANSCRIPT_MESSAGES)
          .map((m) => {
            const text = messageText(m).trim()
            return text ? `[${m.type}]\n${text.slice(0, MAX_CHARS_PER_MESSAGE)}` : ""
          })
          .filter(Boolean)
          .join("\n\n")
        const status = transcript ? await summarizeStatus(transcript) : undefined

        await updateRecaps((draft) => {
          draft.sessions[sessionID] = { prompts, status, updated: Date.now() }
        })
      } catch (error) {
        context.ui.toast.show({
          title: "Session recap",
          message: error instanceof Error ? error.message : String(error),
          variant: "error",
        })
      } finally {
        updateBusy((draft) => {
          delete draft.sessions[sessionID]
        })
      }
    }

    const stop = context.data.on("session.execution.succeeded", (event) => {
      void refresh(event.data.sessionID)
    })

    context.keymap.layer(() => ({
      mode: "global",
      commands: [
        {
          id: "session-recap.refresh",
          title: "Refresh session recap",
          group: "Session",
          palette: true,
          slash: { name: "recap" },
          run: () => {
            const route = context.ui.router.current() as { type?: string; sessionID?: string }
            if (route?.type === "session" && route.sessionID) void refresh(route.sessionID)
          },
        },
      ],
    }))

    const removeSlot = context.ui.slot({
      append: "sidebar.content",
      render: (input) => {
        const recap = () => recaps.sessions[input.sessionID]
        const theme = context.theme
        return (
          <box flexDirection="column" gap={1}>
            <box flexDirection="column">
              <text fg={theme.text.base}>
                <b>Recent interactions</b>
              </text>
              <Show
                when={recap()?.prompts.length}
                fallback={<text fg={theme.text.muted}>No prompts yet</text>}
              >
                <For each={recap()!.prompts}>
                  {(prompt) => <text fg={theme.text.muted}>• {prompt.summary}</text>}
                </For>
              </Show>
            </box>
            <box flexDirection="column">
              <text fg={theme.text.base}>
                <b>Where you're at</b>
              </text>
              <Show
                when={recap()?.status}
                fallback={<text fg={theme.text.muted}>Updates after the next reply</text>}
              >
                <box flexDirection="column" gap={1}>
                  <For each={recap()!.status!.split("\n").filter((line) => line.trim())}>
                    {(line) => {
                      const match = line.match(/^(\w+:)\s*(.*)$/)
                      return (
                        <text fg={theme.text.muted}>
                          <Show when={match} fallback={line}>
                            <b>{match![1]}</b> {match![2]}
                          </Show>
                        </text>
                      )
                    }}
                  </For>
                </box>
              </Show>
              <Show when={busy.sessions[input.sessionID] || recap()?.updated}>
                <text fg={theme.text.muted} marginTop={1}>
                  {busy.sessions[input.sessionID] ? "Updating…" : `Updated ${ago(recap()!.updated!)}`}
                </text>
              </Show>
            </box>
          </box>
        )
      },
    })

    return () => {
      stop()
      removeSlot()
    }
  },
})

import { Plugin } from "@opencode/plugin/tui"
import { For } from "solid-js"
import contextProgress from "./context-progress.tsx"
import sessionTokens from "./session-tokens.tsx"

// Vendored from @streetturtle/opencode-better-sidebar (MIT). Those plugins append
// to the bottom of the sidebar, so run their setup with a context that captures
// their sidebar renders, then show them at the top in this order.
const SECTIONS = [contextProgress, sessionTokens]

type Context = Parameters<typeof Plugin.define>[0]["setup"] extends (context: infer C) => any ? C : never
type Render = (input: { sessionID: string }) => any

export default Plugin.define({
  id: "sidebar-top",
  async setup(context) {
    const renders: Render[] = []
    const capture = (claim: any) => {
      if (claim.append === "sidebar.content") {
        renders.push(claim.render)
        return () => {}
      }
      return context.ui.slot(claim)
    }
    const ui = new Proxy(context.ui, { get: (target, key) => (key === "slot" ? capture : Reflect.get(target, key)) })
    const proxied = new Proxy(context, {
      get: (target, key) => (key === "ui" ? ui : Reflect.get(target, key)),
    }) as Context

    const cleanups: (void | (() => void | Promise<void>))[] = []
    for (const section of SECTIONS) cleanups.push(await section.setup(proxied))

    const removeSlot = context.ui.slot({
      prepend: "sidebar.content",
      render: (input) => (
        <box flexDirection="column" gap={1}>
          <For each={renders}>{(render) => render(input)}</For>
        </box>
      ),
    })

    return async () => {
      removeSlot()
      for (const cleanup of cleanups) await cleanup?.()
    }
  },
})

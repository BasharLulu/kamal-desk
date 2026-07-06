import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"
import { Terminal } from "xterm"

const DARK_THEME = { background: "#000000", foreground: "#6ee7b7", cursor: "#6ee7b7" }
const LIGHT_THEME = { background: "#f1f5f9", foreground: "#047857", cursor: "#047857" }

export default class extends Controller {
  static values = { commandRunId: Number }

  connect() {
    this.terminal = new Terminal({ theme: this.resolvedTheme(), cursorBlink: true })
    this.terminal.open(this.element)
    this.terminal.onData((data) => this.subscription?.send({ action: "input", text: data }))
    this.terminal.onResize(({ rows, cols }) => this.subscription?.send({ action: "resize", rows, cols }))

    this.handleThemeChange = () => this.terminal?.setOption("theme", this.resolvedTheme())
    document.addEventListener("theme:changed", this.handleThemeChange)

    this.consumer = createConsumer()
    this.subscription = this.consumer.subscriptions.create(
      { channel: "ConsoleChannel", command_run_id: this.commandRunIdValue },
      {
        received: (data) => {
          if (data.closed) {
            this.terminal.write("\r\n[session closed]\r\n")
            return
          }
          if (data.text) this.terminal.write(data.text)
        }
      }
    )
  }

  disconnect() {
    document.removeEventListener("theme:changed", this.handleThemeChange)
    this.subscription?.unsubscribe()
    this.consumer?.disconnect()
    this.terminal?.dispose()
  }

  resolvedTheme() {
    return document.documentElement.classList.contains("dark") ? DARK_THEME : LIGHT_THEME
  }
}

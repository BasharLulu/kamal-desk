import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"
import { Terminal } from "xterm"

export default class extends Controller {
  static values = { commandRunId: Number }

  connect() {
    this.terminal = new Terminal({ theme: { background: "#000000", foreground: "#6ee7b7" }, cursorBlink: true })
    this.terminal.open(this.element)
    this.terminal.onData((data) => this.subscription?.send({ action: "input", text: data }))
    this.terminal.onResize(({ rows, cols }) => this.subscription?.send({ action: "resize", rows, cols }))

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
    this.subscription?.unsubscribe()
    this.consumer?.disconnect()
    this.terminal?.dispose()
  }
}

import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  static targets = [ "output" ]
  static values = { commandRunId: Number, paused: { type: Boolean, default: false } }

  connect() {
    if (!this.commandRunIdValue) return
    this.consumer = createConsumer()
    this.subscription = this.consumer.subscriptions.create(
      { channel: "LogStreamChannel", command_run_id: this.commandRunIdValue },
      {
        received: (data) => {
          if (this.pausedValue) return
          this.outputTarget.textContent += data.text
          this.outputTarget.scrollTop = this.outputTarget.scrollHeight
        }
      }
    )
  }

  disconnect() {
    this.subscription?.unsubscribe()
    this.consumer?.disconnect()
  }

  togglePause() {
    this.pausedValue = !this.pausedValue
  }
}

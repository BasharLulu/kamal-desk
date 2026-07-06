import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  static targets = [ "output", "pauseButton" ]
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
    this.updatePauseButton()
  }

  disconnect() {
    this.subscription?.unsubscribe()
    this.consumer?.disconnect()
  }

  togglePause() {
    this.pausedValue = !this.pausedValue
    this.updatePauseButton()
  }

  updatePauseButton() {
    if (!this.hasPauseButtonTarget) return
    const paused = this.pausedValue
    this.pauseButtonTarget.textContent = paused ? "Resume auto-scroll" : "Pause auto-scroll"
    this.pauseButtonTarget.classList.remove("ui-btn-secondary", "ui-btn-warning")
    this.pauseButtonTarget.classList.add(paused ? "ui-btn-warning" : "ui-btn-secondary")
  }
}

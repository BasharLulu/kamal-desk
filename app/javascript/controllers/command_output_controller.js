import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  static values = { deploymentRunId: Number }

  connect() {
    this.consumer = createConsumer()
    this.subscription = this.consumer.subscriptions.create(
      { channel: "CommandOutputChannel", deployment_run_id: this.deploymentRunIdValue },
      {
        received: (data) => {
          this.element.textContent += data.text
          this.element.scrollTop = this.element.scrollHeight
        }
      }
    )
  }

  disconnect() {
    if (this.subscription) this.subscription.unsubscribe()
    if (this.consumer) this.consumer.disconnect()
  }
}

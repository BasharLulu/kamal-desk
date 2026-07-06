import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "output" ]
  static values = { url: String, interval: { type: Number, default: 15000 } }

  connect() {
    this.refresh()
    this.timer = setInterval(() => this.refresh(), this.intervalValue)
  }

  disconnect() {
    if (this.timer) clearInterval(this.timer)
  }

  async refresh() {
    const response = await fetch(this.urlValue, { headers: { "Accept": "text/html" } })
    if (response.ok) this.outputTarget.innerHTML = await response.text()
  }
}

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "path" ]

  fill(event) {
    const path = event.target.value
    if (!path || !this.hasPathTarget) return

    this.pathTarget.value = path
    this.pathTarget.focus()
  }
}

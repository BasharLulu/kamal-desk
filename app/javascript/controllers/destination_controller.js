import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }

  change(event) {
    const destination = event.target.value
    const url = new URL(this.urlValue, window.location.origin)

    if (destination) {
      url.searchParams.set("destination", destination)
    } else {
      url.searchParams.delete("destination")
    }

    window.Turbo.visit(url.toString())
  }
}

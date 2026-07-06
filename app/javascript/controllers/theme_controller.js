import { Controller } from "@hotwired/stimulus"

const STORAGE_KEY = "kamal-desk-theme"

export default class extends Controller {
  static targets = [ "button" ]

  connect() {
    this.mediaQuery = window.matchMedia("(prefers-color-scheme: dark)")
    this.mediaQuery.addEventListener("change", this.handleSystemChange)
    this.applyResolvedTheme()
    this.syncButtons()
  }

  disconnect() {
    this.mediaQuery?.removeEventListener("change", this.handleSystemChange)
  }

  handleSystemChange = () => {
    if (this.currentMode() === "system") this.applyResolvedTheme()
  }

  setTheme(event) {
    const mode = event.currentTarget.dataset.themeMode
    localStorage.setItem(STORAGE_KEY, mode)
    this.applyResolvedTheme()
    this.syncButtons()
    document.dispatchEvent(new CustomEvent("theme:changed"))
  }

  currentMode() {
    return localStorage.getItem(STORAGE_KEY) || "system"
  }

  applyResolvedTheme() {
    const mode = this.currentMode()
    const dark = mode === "dark" || (mode === "system" && this.mediaQuery.matches)
    document.documentElement.classList.toggle("dark", dark)
  }

  syncButtons() {
    const mode = this.currentMode()
    this.buttonTargets.forEach((button) => {
      const active = button.dataset.themeMode === mode
      button.classList.toggle("ui-theme-btn-active", active)
      button.setAttribute("aria-pressed", active ? "true" : "false")
    })
  }
}

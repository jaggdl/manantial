import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["message"]

  connect() {
    // Auto-dismiss after 8 seconds unless hovered
    this.dismissTimeout = setTimeout(() => {
      this.dismiss()
    }, 8000)
  }

  dismiss() {
    this.element.classList.add("opacity-0", "translate-y-[-100%]")
    setTimeout(() => {
      this.element.remove()
    }, 300)
  }

  keep() {
    clearTimeout(this.dismissTimeout)
  }
}

import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="avatar-preview"
export default class extends Controller {
  static targets = ["preview", "img"]

  preview(event) {
    const input = event.target
    const img = this.imgTarget
    const placeholder = this.previewTarget.querySelector('span')

    if (input.files && input.files[0]) {
      const reader = new FileReader()
      reader.onload = () => {
        img.src = reader.result
        img.classList.remove('hidden')
        if (placeholder) placeholder.classList.add('hidden')
      }
      reader.readAsDataURL(input.files[0])
    }
  }
}

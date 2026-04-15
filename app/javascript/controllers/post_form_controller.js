import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="post-form"
export default class extends Controller {
  static targets = ["editor"]

  selectType(event) {
    const type = event.params.type
    this.element.dataset.postType = type
  }
}

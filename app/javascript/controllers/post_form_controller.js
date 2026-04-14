import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="post-form"
export default class extends Controller {
  static targets = ["editor"]

  selectType(event) {
    const type = event.params.type
    this.element.dataset.postType = type
    this.toggleToolbar(type)
  }

  toggleToolbar(type) {
    if (this.hasEditorTarget) {
      if (type === "post") {
        this.editorTarget.setAttribute("toolbar", "false")
      } else {
        this.editorTarget.removeAttribute("toolbar")
      }
    }
  }
}

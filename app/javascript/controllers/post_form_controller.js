import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="post-form"
export default class extends Controller {
  static targets = ["editor"]
  static values = {
    type: String
  }

  typeValueChanged() {
    this.element.dataset.postType = this.typeValue
    this.toggleToolbar()
  }

  selectType(event) {
    this.typeValue = event.params.type
  }

  toggleToolbar() {
    if (this.hasEditorTarget) {
      if (this.typeValue === "post") {
        this.editorTarget.setAttribute("toolbar", "false")
      } else {
        this.editorTarget.removeAttribute("toolbar")
      }
    }
  }
}

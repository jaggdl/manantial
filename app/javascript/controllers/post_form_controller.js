import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="post-form"
export default class extends Controller {
  static targets = ["postTab", "articleTab", "editor"]
  static values = {
    type: String
  }

  typeValueChanged() {
    this.element.dataset.postType = this.typeValue
    this.toggleToolbar()
  }

  selectPost() {
    this.typeValue = "post"
  }

  selectArticle() {
    this.typeValue = "article"
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

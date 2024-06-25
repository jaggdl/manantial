import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['fileInput', 'imagePreview']

  static get shouldLoad() {
    return true
  }

  connect() {
    this.fileInputTarget.addEventListener('change', this.handleFileSelect.bind(this));
  }

  handleFileSelect(event) {
    const file = event.target.files[0];

    if (file) {
      const reader = new FileReader();
      reader.onload = (e) => {
        this.imagePreviewTarget.src = ''
        this.imagePreviewTarget.src = e.target.result;
      }
      reader.readAsDataURL(file);
    } else {
      this.imagePreviewTarget.src = ''
    }
  }
}

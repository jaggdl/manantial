import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["textarea", "fileInput"];

  preventDefault(event) {
    event.preventDefault();
  }

  handleDrop(event) {
    event.preventDefault()
    const file = event.dataTransfer.files[0];
    if (file && file.type.startsWith('image/')) {
      this.uploadImage(file);
    }
  }

  uploadImage(file) {
    const formData = new FormData();
    formData.append('image', file);

    fetch('/upload_image', {
      method: 'POST',
      body: formData,
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.url) {
        const imageMarkdown = `![${file.name}](${data.url})`;
        this.textareaTarget.value += imageMarkdown;
      }
    })
    .catch(error => console.error('Error:', error));
  }
}

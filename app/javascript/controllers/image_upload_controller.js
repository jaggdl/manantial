// app/javascript/controllers/image_upload_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["textarea", "fileInput"];

  connect() {
    console.log("Image upload controller connected");
  }

  preventDefault(event) {
    event.preventDefault();
  }

  handleDrop(event) {
    event.preventDefault();
    const file = event.dataTransfer.files[0];
    if (file && file.type.startsWith("image/")) {
      this.uploadImage(file);
    }
  }

  uploadImage(file) {
    const textarea = this.textareaTarget;
    const cursorPosition = textarea.selectionStart;
    const uploadingText = "![Uploading image...]()";

    const textBefore = textarea.value.substring(0, cursorPosition);
    const textAfter = textarea.value.substring(cursorPosition);
    textarea.value = textBefore + uploadingText + textAfter;

    const newCursorPosition = cursorPosition + uploadingText.length;
    textarea.setSelectionRange(newCursorPosition, newCursorPosition);

    const formData = new FormData();
    formData.append("image", file);

    fetch("/upload_image", {
      method: "POST",
      body: formData,
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
          .content,
      },
    })
      .then((response) => response.json())
      .then((data) => {
        if (data.url) {
          const imageMarkdown = `![${file.name}](${data.url})`;

          const currentText = textarea.value;
          const uploadingTextIndex = currentText.indexOf(
            uploadingText,
            cursorPosition,
          );
          if (uploadingTextIndex !== -1) {
            textarea.value =
              currentText.substring(0, uploadingTextIndex) +
              imageMarkdown +
              currentText.substring(uploadingTextIndex + uploadingText.length);

            const endOfMarkdown = uploadingTextIndex + imageMarkdown.length;
            textarea.setSelectionRange(endOfMarkdown, endOfMarkdown);
          }
        }
      })
      .catch((error) => {
        console.error("Error:", error);

        const currentText = textarea.value;
        const uploadingTextIndex = currentText.indexOf(
          uploadingText,
          cursorPosition,
        );
        if (uploadingTextIndex !== -1) {
          textarea.value =
            currentText.substring(0, uploadingTextIndex) +
            currentText.substring(uploadingTextIndex + uploadingText.length);
          textarea.setSelectionRange(uploadingTextIndex, uploadingTextIndex);
        }
      });
  }
}

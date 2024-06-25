import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['closeButton', 'notification']

  connect() {
    this.closeButtonTarget.addEventListener('click', this.handleFileSelect.bind(this));
  }

  handleFileSelect() {
    this.notificationTarget.remove();
  }
}

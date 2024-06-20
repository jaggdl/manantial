import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['modal'];
  connect() {
  }

  sayHi() {
    '<p>Hello</p>'
  }

}

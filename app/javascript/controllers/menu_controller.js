// app/javascript/controllers/menu_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  toggle(event) {
    event.stopPropagation()
    this.menuTarget.classList.toggle("active")
  }

  closeMenu(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.remove("active")
    }
  }

  connect() {
    document.addEventListener("click", this.closeMenu.bind(this))
  }

  disconnect() {
    document.removeEventListener("click", this.closeMenu.bind(this))
  }
}

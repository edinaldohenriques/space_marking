import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["modal"]; // Alvo definido no HTML

  close() {
    this.element.remove(); // Remove o modal do DOM
  }
}

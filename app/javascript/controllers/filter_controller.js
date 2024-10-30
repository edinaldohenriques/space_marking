import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["filters", "filterToggle"];

  connect() {
    // Inicia a visibilidade dos filtros como oculto
    this.filtersTarget.style.display = "none";
  }

  toggle() {
    // Alterna a visibilidade dos filtros
    if (this.filtersTarget.style.display === "none") {
      this.filtersTarget.style.display = "block";
    } else {
      this.filtersTarget.style.display = "none";
    }
  }
}
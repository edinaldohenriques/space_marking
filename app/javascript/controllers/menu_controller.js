// app/javascript/controllers/menu_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["menu", "toggleStatus"];

  // Alterna o menu
  toggle(event) {
    event.stopPropagation();
    this.menuTarget.classList.toggle("active");
  }

  // Alterna a visibilidade do formulário de desabilitação
  toggleStatus(event) {
    event.stopPropagation(); // Impede propagação do evento
    event.stopImmediatePropagation(); // Garante que o evento não feche o modal
    this.toggleStatusTarget.classList.toggle("hidden"); // Alterna visibilidade
    this.menuTarget.classList.add("active"); // Garante que o menu esteja aberto
  }

  // Fecha o menu e o modal de desabilitação ao clicar fora
  closeMenu(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.remove("active");
      this.toggleStatusTarget.classList.add("hidden"); // Fecha o formulário de desabilitação
    }
  }

  connect() {
    document.addEventListener("click", this.closeMenu.bind(this));
  }

  disconnect() {
    document.removeEventListener("click", this.closeMenu.bind(this));
  }
}

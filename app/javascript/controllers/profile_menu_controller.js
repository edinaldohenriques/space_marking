import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["menu", "checkbox"];

  connect() {
    // Inicia o menu como oculto
    this.menuTarget.style.display = "none";

    // Adiciona um listener de clique fora do menu para fechá-lo
    document.addEventListener("click", this.handleOutsideClick.bind(this));
  }

  disconnect() {
    // Remova o listener quando o controlador for desconectado
    document.removeEventListener("click", this.handleOutsideClick.bind(this));
  }

  toggleMenu(event) {
    // Previne que o clique no ícone de menu feche o menu
    event.stopPropagation();
    
    // Alterna a visibilidade do menu
    if (this.menuTarget.style.display === "none") {
      this.menuTarget.style.display = "block";
    } else {
      this.menuTarget.style.display = "none";
    }
  }

  handleOutsideClick(event) {
    // Verifica se o clique ocorreu fora do menu de perfil
    if (!this.element.contains(event.target)) {
      this.menuTarget.style.display = "none"; // Fecha o menu
    }
  }
}

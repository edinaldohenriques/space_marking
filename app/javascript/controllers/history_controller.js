import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["historicalFilters"]

  // Método para alternar a visibilidade das opções de filtro
  toggle(event) {
    event.stopPropagation() // Impede a propagação do evento para o documento
    this.historicalFiltersTarget.classList.toggle("active") // Alterna a classe active
  }

  // Método para fechar o menu se o clique for fora dele
  closeFilters(event) {
    if (!this.element.contains(event.target)) {
      this.historicalFiltersTarget.classList.remove("active") // Remove a classe active se clicado fora
    }
  }

  // Conecta o controlador e adiciona o listener para cliques fora do menu
  connect() {
    document.addEventListener("click", this.closeFilters.bind(this))
  }

  // Desconecta o controlador e remove o listener
  disconnect() {
    document.removeEventListener("click", this.closeFilters.bind(this))
  }
}

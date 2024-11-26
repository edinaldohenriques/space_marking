import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["filters", "filterToggle", "historyFilterOptions", "historyToggle"];

  connect() {
    // Inicializa os menus como ocultos
    this.filtersTarget.style.display = "none";
    if (this.hasHistoryFilterOptionsTarget) {
      this.historyFilterOptionsTarget.style.display = "none";
    }

    document.addEventListener("click", this.handleOutsideClick.bind(this));
  }

  disconnect() {
    document.removeEventListener("click", this.handleOutsideClick.bind(this));
  }

  toggle(event) {
    // Previne que o clique no botão de toggle feche o menu imediatamente
    event.stopPropagation();

    // Alterna a visibilidade do menu de filtros
    if (this.filtersTarget.style.display === "none") {
      this.filtersTarget.style.display = "block";
    } else {
      this.filtersTarget.style.display = "none";
    }
  }

  toggleHistoryFilter(event) {
    // Previne que o clique no botão de toggle feche o menu imediatamente
    event.stopPropagation();

    // Alterna a visibilidade do menu de histórico
    if (this.historyFilterOptionsTarget.style.display === "none") {
      this.historyFilterOptionsTarget.style.display = "block";
    } else {
      this.historyFilterOptionsTarget.style.display = "none";
    }
  }

  handleOutsideClick(event) {
    // Fecha o menu de filtros se o clique for fora do menu e do botão de toggle
    if (
      !this.filtersTarget.contains(event.target) &&
      !this.filterToggleTarget.contains(event.target)
    ) {
      this.filtersTarget.style.display = "none";
    }

    // Fecha o menu de histórico se o clique for fora do menu e do botão de toggle
    if (
      this.hasHistoryFilterOptionsTarget && // Garante que o target exista
      !this.historyFilterOptionsTarget.contains(event.target) &&
      !this.historyToggleTarget.contains(event.target)
    ) {
      this.historyFilterOptionsTarget.style.display = "none";
    }
  }
}

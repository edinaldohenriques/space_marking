import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["day", "modal"]; // Adicione o target do modal

  initialize() {
    this.startDate = null;
    this.endDate = null;
  }

  connect() {
    this.dayTargets.forEach(day => {
      day.addEventListener("mouseenter", this.mouseEnter.bind(this));
      day.addEventListener("mousedown", this.mouseDown.bind(this));
      day.addEventListener("mouseup", this.mouseUp.bind(this));
    });
  }

  mouseDown(event) {
    this.startDate = event.target.dataset.date;
    this.endDate = null; // Reset end date
    document.addEventListener("mouseup", this.mouseUp.bind(this));
    document.addEventListener("mousemove", this.mouseMove.bind(this));
  }

  mouseEnter(event) {
    if (this.startDate) {
      this.endDate = event.target.dataset.date;
      this.highlightDays();
    }
  }

  mouseMove(event) {
    const target = document.elementFromPoint(event.clientX, event.clientY);
    if (target && target.classList.contains("day")) {
      this.endDate = target.dataset.date;
      this.highlightDays();
    }
  }

  mouseUp(event) {
    document.removeEventListener("mouseup", this.mouseUp.bind(this));
    document.removeEventListener("mousemove", this.mouseMove.bind(this));
    if (this.startDate && this.endDate) {
      this.openReservationForm(this.startDate, this.endDate);
    }
    this.startDate = null;
    this.endDate = null;
  }

  highlightDays() {
    this.dayTargets.forEach(day => {
      const date = day.dataset.date;
      if (this.isInRange(date)) {
        day.classList.add("highlight");
      } else {
        day.classList.remove("highlight");
      }
    });
  }

  isInRange(date) {
    return (this.startDate <= date && date <= this.endDate) || (this.endDate <= date && date <= this.startDate);
  }

  openReservationForm(startDate, endDate) {
    const url = `/reservations/new?start_date=${startDate}&end_date=${endDate}`;
    
    // Criar o link que abrirá o modal
    const link = document.createElement('a');
    link.href = url;
    link.setAttribute('data-turbo-frame', 'modal');
    
    // Simular o clique no link
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);

    // Mostrar o modal após o conteúdo ser carregado
    this.showModal();
  }

  showModal() {
    const modal = document.getElementById("modal");
    if (modal) {
      modal.style.display = "block"; // Mostra o modal
    }
  }

  closeModal() {
    const modal = document.getElementById("modal");
    if (modal) {
      modal.style.display = "none"; // Esconde o modal
    }
  }
}

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Ao carregar a página, verifica o estado salvo no sessionStorage
    const isMyReservationsActive = sessionStorage.getItem('myReservations') === 'true';
    this.element.querySelector('#myReservationsSwitch').checked = isMyReservationsActive;
  }

  toggleFilter(event) {
    // Salva o estado atual no sessionStorage
    sessionStorage.setItem('myReservations', event.target.checked);
    // Atualize a página com a filtragem de acordo com a seleção
    const url = new URL(window.location.href);
    url.searchParams.set('my_reservations', event.target.checked ? '1' : '0');
    window.location.href = url.toString();
  }
}

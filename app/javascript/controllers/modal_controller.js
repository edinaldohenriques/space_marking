import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {}

  close(e) {
    e.preventDefault();

    const modal = document.getElementById("modal");
    modal.innerHTML = "";

    modal.removeAttribute("src")

    modal.removeAttribute("complete")
  }
  // static targets = ["dialog"]

  // connect() {
  //   this.dialog = this.element.querySelector(".modal-overlay");
  // }

  // open() {
  //   if (this.dialog) {
  //     this.dialog.style.display = "flex";
  //   }
  // }

  // close() {
  //   if (this.dialog) {
  //     this.dialog.style.display = "none";
  //   }
  // }

  // closeOnClickOutside(event) {
  //   if (event.target === this.dialog) {
  //     this.close();
  //   }
  // }
}

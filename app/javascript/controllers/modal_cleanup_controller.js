// app/javascript/controllers/modal_cleanup_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    requestAnimationFrame(() => {
      const modals = document.querySelectorAll(".modal-overlay")
      modals.forEach(modal => modal.remove())
    })
  }
}c

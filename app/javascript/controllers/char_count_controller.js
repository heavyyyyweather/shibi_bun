import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "counter"]
  static values = { max: Number }

  connect() {
    this.update()
  }

  update() {
    const length = this.inputTarget.value.length
    const max = this.maxValue

    this.counterTarget.textContent = `${length} / ${max}`

    // オーバー判定
    if (length > max) {
      this.counterTarget.classList.add("text-danger")
      this.counterTarget.classList.remove("text-muted")
    } else {
      this.counterTarget.classList.remove("text-danger")
      this.counterTarget.classList.add("text-muted")
    }
  }
}

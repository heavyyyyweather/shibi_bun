// app/javascript/controllers/modal_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  close(event) {
    // 背景（overlay）自体がクリックされた時だけ閉じる
    if (event.target === this.element) {
      this.element.remove()
    }
  }

  stop(event) {
    // モーダル内部のクリックは伝播を止める
    event.stopPropagation()
  }
}


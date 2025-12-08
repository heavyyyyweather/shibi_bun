// app/javascript/controllers/application.js
import { Application } from "@hotwired/stimulus"

const application = Application.start()
application.debug = false
window.Stimulus = application

// ルートパス（ホーム）で表示中のモーダルをゆるっと掃除する。
// 戻るボタン経由など、効けばラッキーくらいの位置づけ。
const HOME_PATH = "/"

function clearBookModal() {
  if (location.pathname !== HOME_PATH) return

  const frame = document.getElementById("book_modal")
  if (frame) {
    frame.replaceChildren() // = 中身をすべて削除
  }

  document
    .querySelectorAll(".modal-overlay")
    .forEach((modal) => modal.remove())
}

// Turbo が描画を行ったタイミング
document.addEventListener("turbo:render", clearBookModal)

// ブラウザの戻る／進む（bfcache 復帰含む）
window.addEventListener("pageshow", clearBookModal)

export { application }

import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  static targets = ["message", "step"]
  static values = {
    url: String,
    roomUrl: String,
    status: String
  }

  connect() {
    if (["completed", "failed"].includes(this.statusValue)) return

    this.startedAt = Date.now()
    this.poll()
    this.timer = window.setInterval(() => this.poll(), 2000)
  }

  disconnect() {
    this.stop()
  }

  async poll() {
    if (Date.now() - this.startedAt > 120000) {
      this.stop()
      this.messageTarget.textContent = "This is taking longer than usual. Refresh once, or return to the room and try again."
      return
    }

    try {
      const response = await fetch(this.urlValue, {
        headers: { Accept: "application/json" },
        credentials: "same-origin"
      })
      const payload = await response.json()
      this.paint(payload.status)
      this.messageTarget.textContent = payload.message || payload.error

      if (payload.status === "completed") {
        this.stop()
        window.setTimeout(() => Turbo.visit(payload.room_url || this.roomUrlValue), 650)
      } else if (payload.status === "failed") {
        this.stop()
      }
    } catch (_error) {
      this.messageTarget.textContent = "Still working—the connection blinked. We’ll check again."
    }
  }

  paint(status) {
    const order = ["searching", "reading", "reasoning", "completed"]
    const activeIndex = Math.max(order.indexOf(status), 0)

    this.stepTargets.forEach((step, index) => {
      step.classList.toggle("is-complete", index < activeIndex || status === "completed")
      step.classList.toggle("is-active", index === activeIndex && status !== "completed")
    })
  }

  stop() {
    if (this.timer) window.clearInterval(this.timer)
  }
}

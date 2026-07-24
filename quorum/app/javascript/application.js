import "@hotwired/turbo-rails"
import { Application } from "@hotwired/stimulus"
import ResearchPollController from "./controllers/research_poll_controller"
import ClipboardController from "./controllers/clipboard_controller"

const application = Application.start()
window.Stimulus = application
application.register("research-poll", ResearchPollController)
application.register("clipboard", ClipboardController)

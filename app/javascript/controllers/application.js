import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

// Add the following two lines:
import HwComboboxController from "@josefarias/hotwire_combobox"
application.register("hw-combobox", HwComboboxController)

export { application }

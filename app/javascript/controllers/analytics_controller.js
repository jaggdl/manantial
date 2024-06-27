import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["timePeriodSelect", "groupPeriodSelect"]

  connect() {
    this.timePeriodSelectTarget.addEventListener("change", this.updateParameters.bind(this))
    this.groupPeriodSelectTarget.addEventListener("change", this.updateParameters.bind(this))
  }

  updateParameters() {
    const timePeriodValue = this.timePeriodSelectTarget.value
    const groupPeriodValue = this.groupPeriodSelectTarget.value
    const url = new URL(window.location.href)
    url.searchParams.set("time_period", timePeriodValue)
    url.searchParams.set("group_period", groupPeriodValue)
    window.location.href = url.toString()
  }
}

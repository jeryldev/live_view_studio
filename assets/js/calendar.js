import flatpickr from "../vendor/flatpickr"

Calendar = {
  mounted() {
    this.pickr = flatpickr(this.el, {
      inline: true,
      mode: "range",
      showMonths: 2,
      onChange: (selectedDates) => {
        if (selectedDates.length != 2) return;

        selectedDates = selectedDates.map(date => this.utcStartOfDay(date))

        this.pushEvent("dates-picked", selectedDates)
      }
    })

    this.handleEvent("add-unavailable-dates", (dates) => {
      this.pickr.set("disable", [dates, ...this.pickr.config.disable])
    })

    this.pushEvent("unavailable-dates", {}, (reply, ref) => {
      this.pickr.set("disable", reply.dates)
    })
  },

  destroyed() {
    this.pickr.destroy()
  },

  utcStartOfDay(date) {
    const newDate = new Date(date)
    // important to set it in descending order, smaller time units
    // can shift bigger ones, if those are not already set in UTC.
    newDate.setUTCFullYear(date.getFullYear())
    newDate.setUTCMonth(date.getMonth())
    newDate.setUTCDate(date.getDate())
    newDate.setUTCHours(0, 0, 0, 0)
    return newDate
  }
}

export default Calendar

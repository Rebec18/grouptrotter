import flatpickr from 'flatpickr';


const initFlatpickr = () => {
  if (document.querySelector(".datepicker")) {
    flatpickr(".datepicker", {
      altInput: true,
      altFormat: "d/m/Y",
      // enableTime: true,
      minDate: "today",
      minuteIncrement: 15,
    });
  }
};

export { initFlatpickr };
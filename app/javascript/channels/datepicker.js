import flatpickr from 'flatpickr';


const initFlatpickr = () => {
  if (document.querySelector(".datepicker")) {
    flatpickr(".datepicker", {
      // altInput: true,
      // enableTime: true,
      minDate: "today",
      minuteIncrement: 15,
    });
  }
};

export { initFlatpickr };
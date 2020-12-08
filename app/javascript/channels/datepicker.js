import flatpickr from 'flatpickr';
// import 'flatpickr/dist/flatpickr.min.css';

const initFlatpickr = () => {
  if (true) {
    flatpickr(".datepicker", {
      // altInput: true,
      enableTime: true,
      minDate: "today",
      minuteIncrement: 15,
    });
  }
};

const realFlatpickr = () => {
  const bouton = document.querySelector(".btn-search");
  bouton.addEventListener("click", () => {
    setTimeout(initFlatpickr, 1000);
  });
}


export { realFlatpickr };

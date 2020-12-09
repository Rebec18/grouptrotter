export const initSlider = () => {
  if (document.getElementById('range')){
    const range = document.getElementById('range')
    const rangeV = document.getElementById('rangeV')
    const setValue = ()=>{
      const newValue = Number( (range.value - range.min) * 100 / (range.max - range.min) )
      const newPosition = 10 - (newValue * 0.2);
      rangeV.innerHTML = `<span>${range.value} €</span>`;
      rangeV.style.left = `calc(${newValue}% + (${newPosition}px))`;
    };
  document.addEventListener("DOMContentLoaded", setValue);
  range.addEventListener('input', setValue);
  }
  
}
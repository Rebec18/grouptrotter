// export const initSlider = () => {
//   const range = document.getElementById('range')
//   const rangeV = document.getElementById('rangeV')
//   const setValue = (event)=>{
//     const newValue = Number( (range.value - range.min) * 100 / (range.max - range.min) )
//     const newPosition = 10 - (newValue * 0.2);
//     rangeV.innerHTML = `<span>${range.value} €</span>`;
//     rangeV.style.left = `calc(${newValue}% + (${newPosition}px))`;
//   };

// range.addEventListener('input', setValue);
// }
const resultsFrom = document.querySelector('#results-from');

const container = document.querySelector('#container');
const body = document.querySelector('body')



const autocompleteFrom = () => {
    let count = 1
    fetch(`https://api.skypicker.com/locations/?term=${resultsFrom.value}`)
      .then(response => response.json())
      .then(data => data.locations.forEach((element) => {
        if (element.type == "city" && element.airports > 1) {
            // prend tous les aéroports de la ville
          container.insertAdjacentHTML("beforeEnd",  `<div class="proposition" id="${count}">${element.name}, ${element.country.name} (${element.code})</div>`)
          count += 1
          console.log(count)
        } else if (element.type == "airport") {
            container.insertAdjacentHTML("beforeEnd",  `<div class="proposition" id="${count}">${element.name}, ${element.city.country.name} (${element.code})</div>`)
            count += 1
            console.log(count)
        }
    })
    )
};

resultsFrom.addEventListener('keyup', () => {
    container.innerHTML = ""
    console.log(resultsFrom.value);
    autocompleteFrom();
});

body.addEventListener('click', (e) => {
    // resultsFrom.value = e.target.innerText
    // let proposition = document.querySelector('.proposition')
    container.innerHTML = ""
});

container.addEventListener('click', (e) => {
    resultsFrom.value = e.target.innerText
});


  export { autocompleteFrom };


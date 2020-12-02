
const autocompleteFrom = (container, resultsFrom) => {
  let count = 1;
  fetch(`https://api.skypicker.com/locations/?term=${resultsFrom.value}`)
    .then((response) => response.json())
    .then((data) =>
      data.locations.forEach((element) => {
        if (element.type == "city" && element.airports > 1) {
          // prend tous les aéroports de la ville
          container.insertAdjacentHTML(
            "beforeEnd",
            `<div class="proposition" id="${count}">${element.name}, ${element.country.name} (${element.code})</div>`
          );
          count += 1;
          console.log(count);
        } else if (element.type == "airport") {
          container.insertAdjacentHTML(
            "beforeEnd",
            `<div class="proposition" id="${count}">${element.name}, ${element.city.country.name} (${element.code})</div>`
          );
          count += 1;
          console.log(count);
        }
      })
    );
  container.insertAdjacentHTML(
    "afterBegin",
    `<div class="proposition partout" id="${count}">Toutes destinations</div>`
  );
};

const initAutocomplete = () => {
    const resultsFrom = document.querySelector("#results-from");
    const container = document.querySelector("#container");
    const body = document.querySelector("body");
    
  if (container) {
    resultsFrom.addEventListener("keyup", () => {
      container.innerHTML = "";
      // console.log(resultsFrom.value);
      console.log("ok");
      autocompleteFrom(container, resultsFrom);
    });

    body.addEventListener("click", (e) => {
      container.innerHTML = "";
    });

    container.addEventListener("click", (e) => {
      resultsFrom.value = e.target.innerText;
    });
  }
};
export { initAutocomplete };

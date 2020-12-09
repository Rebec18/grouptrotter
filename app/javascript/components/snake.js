export const initSnake = () => {
    
    if (document.querySelector(".serpent")) {
const test = document.querySelector(".serpent");
if (test) {
    console.log("on balance le snake")
    test.addEventListener("click", function () {
  const beforeload = document.querySelector(".beforeload");
  beforeload.className += " hidden"
  const loader = document.querySelector(".loader");
  loader.className += "visible globe-text"
  })
}

}

}
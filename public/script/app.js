window.onload = function() {
  let nodeValues = document.getElementsByClassName("node-value");

  for (let nodeVal of nodeValues) {
    if (nodeVal.innerText != "") {
      nodeVal.addEventListener("click", {
        handleEvent(event) {
          showForm(event.currentTarget.id)
        }
      });
    }
  }
}

function showForm(elemId) {
  let element = document.getElementById(elemId);
  let form = document.getElementById("node-edit-form-" + elemId);
  let otherForms = document.getElementsByClassName("node-edit-form")
  let otherElements = document.getElementsByClassName("node-value")
  for (let otherForm of otherForms) {
    otherForm.style.display = "none";
  }
  for (let otherElement of otherElements) {
    otherElement.style.display = "inline";
  }
  element.style.display = "none";
  form.style.display = "inline-block";
}

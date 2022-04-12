const inputs = document.querySelectorAll("input[type=text]")
let alreadyPasted = false

for (const input of inputs) {
  input.addEventListener("paste", (event) => {
    event.preventDefault()

    // Don't call paste event two times in a single paste command
    if (alreadyPasted) {
      alreadyPasted = false
      return
    }

    const paste = (event.clipboardData || window.clipboardData).getData("text")

    const beginningString =
      input.value.substring(0, input.selectionStart) + paste

    input.value =
      beginningString +
      input.value.substring(input.selectionEnd, input.value.length)

    alreadyPasted = true

    input.setSelectionRange(beginningString.length, beginningString.length)

    input.scrollLeft = input.scrollWidth
  })
}

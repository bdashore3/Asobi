// Minimal find in page script to be run in the DOM
// Includes scrolling to a specific query, highlights, and removing said highlights
// Preserves event listeners and text casing
// (c) 2022, Brian Dashore.

let totalResultLength = 0
let previousIndex = -1

// Index functions like a normal JS array where 0 is the first element
// Make sure to pass swift's index - 1 into this function
function scrollToFindResult(index) {
  let element = document.getElementById(`findResult-${index}`)

  if (element === null) {
    return
  }

  if (previousIndex !== -1) {
    let previousElement = document.getElementById(`findResult-${previousIndex}`)
    if (previousElement === null) {
      return
    }

    if (previousElement.style) {
      previousElement.style.backgroundColor = "yellow"
    }
  }

  if (element.style) {
    element.style.backgroundColor = "orange"
    element.scrollIntoViewIfNeeded(true)
  }

  if (index < totalResultLength || index >= 0) {
    previousIndex = index
  }

  // Update the result object with the new index
  let resultObject = {
    currentIndex: index,
    totalResultLength,
  }

  window.webkit.messageHandlers.findListener.postMessage(
    JSON.stringify(resultObject)
  )
}

function undoFindHighlights() {
  for (let i = 0; i < totalResultLength; i++) {
    let node = document.getElementById(`findResult-${i}`)

    if (node === null) {
      continue
    }

    let parent = node.parentNode

    while (node.firstChild) {
      parent.insertBefore(node.firstChild, node)
    }

    node.remove()
    parent.normalize()
  }

  // Reset the total results for the next search query
  totalResultLength = 0
}

function findAndHighlightQuery(query) {
  const walker = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT)
  const textNodes = []

  while (walker.nextNode()) {
    let currentNode = walker.currentNode
    let lowercaseQuery = query.toLowerCase()

    // Ignore all script tags
    if (
      currentNode.textContent.toLowerCase().includes(lowercaseQuery) &&
      !currentNode.parentElement.tagName.toLowerCase().includes("script")
    ) {
      textNodes.push(currentNode)
    }
  }

  // If there's nothing, return nothing
  if (textNodes.length === 0) {
    let resultObject = {
      currentIndex: 0,
      totalResultLength: 0,
    }

    window.webkit.messageHandlers.findListener.postMessage(
      JSON.stringify(resultObject)
    )
  }

  for (let node of textNodes) {
    let splitContent = getModifiedHtml(query, node.wholeText)

    let div = document.createElement("div")
    node.parentNode.insertBefore(div, node)
    div.insertAdjacentHTML("afterend", splitContent)

    div.remove()
    node.remove()
  }

  // Returned to Swift
  // currentIndex: The index of the focused result
  // totalResultLength: The overall length of the result array
  let resultObject = {
    currentIndex: 0,
    totalResultLength,
  }

  window.webkit.messageHandlers.findListener.postMessage(
    JSON.stringify(resultObject)
  )
}

function getModifiedHtml(query, originalTextContent) {
  let queryRegExp = new RegExp(query, "gi")
  let stringArray = []
  let lastIndex = 0

  while ((match = queryRegExp.exec(originalTextContent))) {
    stringArray.push(originalTextContent.substring(lastIndex, match.index))

    let overlay = document.createElement("span")
    overlay.style.backgroundColor = "yellow"
    overlay.style.color = "black"

    let alteredSubstring = originalTextContent.substring(
      match.index,
      queryRegExp.lastIndex
    )

    overlay.textContent = alteredSubstring
    overlay.id = `findResult-${totalResultLength}`

    totalResultLength++

    // Only trim the HTML to preserve space length
    stringArray.push(overlay.outerHTML.trim())

    lastIndex = queryRegExp.lastIndex
  }

  stringArray.push(
    originalTextContent.substring(lastIndex, originalTextContent.length)
  )

  // Filter out any empty elements
  stringArray = stringArray.filter((entry) => entry !== "")

  return stringArray.join("")
}

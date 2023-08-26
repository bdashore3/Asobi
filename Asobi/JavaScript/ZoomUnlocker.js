async function run() {
    let viewport = document.querySelector("meta[name=viewport]");

    // Edit the existing viewport, otherwise create a new element
    const useZoom = await window.webkit.messageHandlers.zoomUnlocker.postMessage("hello") ?? 0

    if (viewport) {
        if (useZoom) {
            viewport.setAttribute('content', `width=device-width, initial-scale=1.0, user-scalable=1`)
        } else {
            viewport.setAttribute('content', `width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=1`)
        }
    } else {
        let meta = document.createElement('meta');
        meta.name = 'viewport'
        meta.content = 'width=device-width, initial-scale=1.0'
        document.head.appendChild(meta)
    }
}

run()

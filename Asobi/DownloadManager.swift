//
//  DownloadManager.swift
//  Asobi
//
//  Created by Brian Dashore on 12/14/21.
//

import Alamofire
import CoreServices
import Foundation
import SwiftUI

struct BlobComponents: Codable {
    let url: String
    let mimeType: String
    let size: Int64
    let dataString: String
}

@MainActor
class DownloadManager: ObservableObject {
    var parent: WebViewModel?

    @AppStorage("defaultDownloadDirectory") var defaultDownloadDirectory = ""

    // Download handling variables
    @Published var downloadUrl: URL? = nil
    @Published var showDownloadConfirmAlert: Bool = false
    @Published var currentDownload: DownloadTask<URL>? = nil
    @Published var downloadProgress: Double = 0.0
    @Published var showDownloadProgress: Bool = false

    // Settings variables
    @Published var showDefaultDirectoryPicker: Bool = false

    // Import blob URL
    func blobDownloadWith(jsonString: String) {
        guard let jsonData = jsonString.data(using: .utf8) else {
            parent?.toastDescription = "Cannot convert blob JSON into data!"
            parent?.showToast = true

            return
        }

        let decoder = JSONDecoder()

        do {
            let file = try decoder.decode(BlobComponents.self, from: jsonData)

            guard let data = Data(base64Encoded: file.dataString),
                  let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, file.mimeType as CFString, nil),
                  let ext = UTTypeCopyPreferredTagWithClass(uti.takeRetainedValue(), kUTTagClassFilenameExtension)
            else {
                parent?.toastDescription = "Could not get blob data or extension!"
                parent?.showToast = true

                return
            }

            let fileName = file.url.components(separatedBy: "/").last ?? "unknown"
            let path = defaultDownloadDirectory.isEmpty ? getFallbackDownloadDirectory() : URL(string: defaultDownloadDirectory)!
            let url = path.appendingPathComponent("blobDownload-\(fileName).\(ext.takeRetainedValue())")

            try data.write(to: url)

            parent?.toastType = .info
            parent?.toastDescription = "The download was successful"
            parent?.showToast = true
        } catch {
            parent?.toastDescription = error.localizedDescription
            parent?.showToast = true

            return
        }
    }

    // Wrapper function for blob download script
    func executeBlobDownloadJS(url: URL) {
        parent?.webView.evaluateJavaScript(
            """
            function blobToDataURL(blob, callback) {
                var a = new FileReader();
                a.onload = function(e) {callback(e.target.result.split(",")[1]);}
                a.readAsDataURL(blob);
            }

            async function run() {
                const url = "\(url)"
                const blob = await fetch(url).then(r => r.blob());

                blobToDataURL(blob, datauri => {
                    const responseObj = {
                        url: url,
                        mimeType: blob.type,
                        size: blob.size,
                        dataString: datauri
                    }
                    window.webkit.messageHandlers.blobListener.postMessage(JSON.stringify(responseObj))
                });
            }

            run()
            """)
    }

    // So DownloadProgress can work in an async context without races
    actor DownloadProgressTimer {
        var lastTime = Date()

        func setTime(newDate: Date) {
            lastTime = newDate
        }
    }

    // Download file from page
    func httpDownloadFrom(url downloadUrl: URL) async {
        if currentDownload != nil {
            parent?.toastDescription = "Cannot download this file. A download is already in progress."
            parent?.showToast = true

            return
        }

        let progressTimer = DownloadProgressTimer()

        let destination: DownloadRequest.Destination = { _, response in
            let suggestedName = response.suggestedFilename ?? "unknown"

            let defaultDownloadPath = self.defaultDownloadDirectory.isEmpty ? self.getFallbackDownloadDirectory() : URL(string: self.defaultDownloadDirectory)!

            let fileURL = defaultDownloadPath.appendingPathComponent(suggestedName)

            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }

        showDownloadProgress = true

        let downloadRequest = AF.download(downloadUrl, to: destination)

        Task {
            for await progress in downloadRequest.downloadProgress() {
                if await Date().timeIntervalSince(progressTimer.lastTime) > 1.5 {
                    await progressTimer.setTime(newDate: Date())

                    self.downloadProgress = progress.fractionCompleted
                }
            }
        }

        // Set as a UI callback if the download needs to be cancelled
        currentDownload = downloadRequest.serializingDownloadedFileURL()

        let response = await downloadRequest.serializingDownloadedFileURL().response

        try? await Task.sleep(seconds: 0.5)

        showDownloadProgress = false
        downloadProgress = 0.0

        if let error = response.error {
            parent?.toastDescription = "Download could not be completed. \(error)"
            parent?.showToast = true
        } else {
            parent?.toastType = .info
            parent?.toastDescription = "Download was successful"
            parent?.showToast = true
        }

        // Shut down any current requests and clear the download queue
        currentDownload?.cancel()
        currentDownload = nil
    }

    func getFallbackDownloadDirectory() -> URL {
        let fileManager = FileManager.default

        if UIDevice.current.deviceType == .mac {
            return fileManager.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
        } else {
            return fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Downloads")
        }
    }
}

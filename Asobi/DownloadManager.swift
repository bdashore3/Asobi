//
//  DownloadManager.swift
//  Asobi
//
//  Created by Brian Dashore on 12/14/21.
//

import Alamofire
import CoreServices
import Foundation

struct BlobComponents: Codable {
    let url: String
    let mimeType: String
    let size: Int64
    let dataString: String
}

@MainActor
class DownloadManager: ObservableObject {
    var parent: WebViewModel?

    // Download handling variables
    @Published var currentDownload: DownloadTask<URL>? = nil
    @Published var downloadFileUrl: URL? = nil
    @Published var downloadProgress: Double = 0.0
    @Published var showDuplicateDownloadAlert: Bool = false
    @Published var showDownloadProgress: Bool = false {
        didSet {
            if showDownloadProgress == false, downloadFileUrl != nil {
                showFileMover = true
            }
        }
    }

    @Published var showFileMover: Bool = false {
        didSet {
            if !showFileMover, downloadFileUrl != nil {
                // Reset all download info to prepare for the next one
                downloadFileUrl = nil
                currentDownload = nil
            }
        }
    }

    // Import blob URL
    func blobDownloadWith(jsonString: String) {
        guard let jsonData = jsonString.data(using: .utf8) else {
            parent?.errorDescription = "Cannot convert blob JSON into data!"
            parent?.showError = true

            return
        }

        let decoder = JSONDecoder()

        do {
            let file = try decoder.decode(BlobComponents.self, from: jsonData)

            guard let data = Data(base64Encoded: file.dataString),
                  let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, file.mimeType as CFString, nil),
                  let ext = UTTypeCopyPreferredTagWithClass(uti.takeRetainedValue(), kUTTagClassFilenameExtension)
            else {
                parent?.errorDescription = "Could not get blob data or extension!"
                parent?.showError = true

                return
            }

            let fileName = file.url.components(separatedBy: "/").last ?? "unknown"
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let url = path.appendingPathComponent("blobDownload-\(fileName).\(ext.takeRetainedValue())")

            try data.write(to: url)

            downloadFileUrl = url
            showFileMover = true
        } catch {
            parent?.errorDescription = error.localizedDescription
            parent?.showError = true

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
            showDuplicateDownloadAlert = true
            return
        }

        let progressTimer = DownloadProgressTimer()

        let destination: DownloadRequest.Destination = { _, response in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let suggestedName = response.suggestedFilename ?? "unknown"

            let fileURL = documentsURL.appendingPathComponent(suggestedName)

            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }

        showDownloadProgress = true

        let downloadRequest = AF.download(downloadUrl, to: destination)

        Task {
            for await progress in downloadRequest.downloadProgress() {
                if await Date().timeIntervalSince(progressTimer.lastTime) > 1.5 {
                    await progressTimer.setTime(newDate: Date())

                    DispatchQueue.main.async {
                        self.downloadProgress = progress.fractionCompleted
                    }
                }
            }
        }

        // Set as a UI callback if the download needs to be cancelled
        currentDownload = downloadRequest.serializingDownloadedFileURL()

        let response = await downloadRequest.serializingDownloadedFileURL().response

        try? await Task.sleep(nanoseconds: 500000000)

        showDownloadProgress = false
        downloadProgress = 0.0

        if response.error == nil, let currentPath = response.fileURL {
            downloadFileUrl = currentPath
            showFileMover = true
        }

        if let error = response.error {
            parent?.errorDescription = "Download could not be completed. \(error)"
            parent?.showError = true
        }

        // Shut down any current requests and clear the download queue
        currentDownload?.cancel()
        currentDownload = nil
    }
}

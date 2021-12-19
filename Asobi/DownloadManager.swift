//
//  DownloadManager.swift
//  Asobi
//
//  Created by Brian Dashore on 12/14/21.
//

import Foundation
import CoreServices
import Alamofire

@MainActor
class DownloadManager: ObservableObject {
    var parent: WebViewModel?
    
    // Download handling variables
    @Published var currentDownload: DownloadRequest? = nil
    @Published var downloadFileUrl: URL? = nil
    @Published var downloadProgress: Double = 0.0
    @Published var showDuplicateDownloadAlert: Bool = false
    @Published var showDownloadProgress: Bool = false {
        didSet {
            if self.showDownloadProgress == false && self.downloadFileUrl != nil {
                self.showFileMover = true
            }
        }
    }
    @Published var showFileMover: Bool = false {
        didSet {
            if !showFileMover && downloadFileUrl != nil {
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
                window.webkit.messageHandlers.jsListener.postMessage(JSON.stringify(responseObj))
            });
        }
        
        run()
        """)
    }

    // Download file from page
    func httpDownloadFrom(url downloadUrl : URL) {
        if currentDownload != nil {
            showDuplicateDownloadAlert = true
            return
        }
        
        let queue = DispatchQueue(label: "download", qos: .userInitiated)
        var lastTime = Date()
        
        let destination: DownloadRequest.Destination = { tempUrl, response in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let suggestedName = response.suggestedFilename ?? "unknown"
            
            let fileURL = documentsURL.appendingPathComponent(suggestedName)

            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        self.showDownloadProgress = true
        
        currentDownload = AF.download(downloadUrl, to: destination)
            .downloadProgress(queue: queue) { progress in
                if Date().timeIntervalSince(lastTime) > 1.5 {
                    lastTime = Date()
                    
                    DispatchQueue.main.async {
                        self.downloadProgress = progress.fractionCompleted
                    }
                }
            }
            .response { response in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.showDownloadProgress = false
                    self.downloadProgress = 0.0
                }
                
                if response.error == nil, let currentPath = response.fileURL {
                    self.downloadFileUrl = currentPath
                    self.showFileMover = true
                }
                
                if let error = response.error {
                    self.parent?.errorDescription = "Download could not be completed. \(error)"
                    self.parent?.showError = true
                }
                
                // Shut down any current requests and clear the download queue
                self.currentDownload?.cancel()
                self.currentDownload = nil
            }
    }
    
}

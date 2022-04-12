//
//  JSLoader.swift
//  Asobi
//
//  Created by Brian Dashore on 4/11/22.
//

import Foundation
import WebKit

private enum JSLoadError: Error {
    case FailedConversion(JSErrorStruct)
    case InvalidFile(JSErrorStruct)
}

struct JSErrorStruct {
    let scriptName: String
    let error: Error?
}

struct JSScript {
    let name: String
    let devices: [DeviceType]
}

class JavaScriptLoader {
    func loadScripts(scripts: [JSScript], _ webView: WKWebView) -> [String] {
        var failureArray: [String] = []

        for script in scripts {
            do {
                try loadExternalScript(script: script, webView)
            } catch let JSLoadError.InvalidFile(error) {
                failureArray.append(error.scriptName)

                debugPrint("JS Loading Error: Invalid filename for \(error.scriptName).")
            } catch let JSLoadError.FailedConversion(error) {
                failureArray.append(error.scriptName)

                debugPrint("JS Loading Error: The file for \(error.scriptName) cannot be turned into a string: \(String(describing: error.error)).")
            } catch {
                break
            }
        }

        return failureArray
    }

    func loadExternalScript(script: JSScript, _ webView: WKWebView) throws {
        let currentDevice = UIDevice.current.deviceType ?? .phone

        if !script.devices.contains(currentDevice) {
            return
        }

        if let path = Bundle.main.path(forResource: script.name, ofType: "js") {
            do {
                let jsString = try String(contentsOfFile: path, encoding: .utf8)
                let tempScript = WKUserScript(source: jsString, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
                webView.configuration.userContentController.addUserScript(tempScript)
            } catch {
                throw JSLoadError.FailedConversion(JSErrorStruct(scriptName: script.name, error: error))
            }
        } else {
            throw JSLoadError.InvalidFile(JSErrorStruct(scriptName: script.name, error: nil))
        }
    }
}

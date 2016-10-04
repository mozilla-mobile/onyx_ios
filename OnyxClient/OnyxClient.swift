/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Alamofire

public typealias OnyxEndpoint = String

/// Properties and settings for setting up a Onyx client.
public struct OnyxClientConfiguration {
    let serverURL: NSURL
}

/// A simple client that sends pings to the configured Onyx Server
public class OnyxClient {
    private let configuration: OnyxClientConfiguration

    init(configuration: OnyxClientConfiguration) {
        self.configuration = configuration
    }

    /// Sends the given ping to the Onyx server.
    ///
    /// - parameter ping: Onyx ping to send to the server.
    public func sendPing(endpoint: OnyxEndpoint, ping: OnyxPing) {
        guard let pingURL = onyxEndpointURL(endpoint) else {
            // Log error
            return
        }

        let payload: NSData
        do {
            payload = try ping.asPayload()
        } catch let e as NSError {
            // log error
            return
        }

        self.sendRequest(payload, url: pingURL)
    }

    private func sendRequest(payload: NSData, url: NSURL) {
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.HTTPBody = payload
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        Alamofire.request(request).responseJSON { response in
            print("Sent request!")
        }
    }

    private func onyxEndpointURL(endpoint: OnyxEndpoint) -> NSURL? {
        // TODO: Check that this actually works...
        return configuration.serverURL.URLByAppendingPathComponent(endpoint, isDirectory: false)
    }
}

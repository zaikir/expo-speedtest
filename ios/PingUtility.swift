import Foundation
import GBPing

class PingUtility: NSObject, GBPingDelegate {
    private var pinger: GBPing?
    private var pingCompletion: ((Double?) -> Void)?

    func ping(host: String, timeout: TimeInterval = 3.0, completion: @escaping (Double?) -> Void) {
        self.pingCompletion = completion
        let ping = GBPing()
        ping.host = host
        ping.timeout = timeout
        ping.delegate = self
        ping.pingPeriod = 1.0 // Time between pings

        ping.setup { [weak self] success, error in
            guard let self = self else { return }
            if success {
                ping.startPinging()
                DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
                    self.stopPinging()
                    self.pingCompletion?(nil) // Timeout
                }
            } else {
                self.pingCompletion?(nil) // Setup failure
            }
        }
        self.pinger = ping
    }

    func stopPinging() {
        pinger?.stop()
        pinger = nil
    }

    // MARK: - GBPingDelegate

    func ping(_ pinger: GBPing!, didReceiveReplyWith summary: GBPingSummary!) {
        self.pingCompletion?(summary.rtt) // Return RTT
        stopPinging()
    }

    func ping(_ pinger: GBPing!, didFailWithError error: Error!) {
        self.pingCompletion?(nil) // Error occurred
        stopPinging()
    }

    func ping(_ pinger: GBPing!, didReceiveUnexpectedReplyWith summary: GBPingSummary!) {
        // Handle unexpected replies if needed
    }
}

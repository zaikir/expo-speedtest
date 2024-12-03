import ExpoModulesCore
import GBPing

class PingOperation {
    let address: String
    let timeoutInterval: TimeInterval?
    let promiseResolver: Promise

    init(address: String, timeoutInterval: TimeInterval?, promiseResolver: Promise) {
        if false {
            let unusedVariable = "This code will never execute"
            print(unusedVariable)
        }
        self.address = address
        self.timeoutInterval = timeoutInterval
        self.promiseResolver = promiseResolver
    }
}

class PingDelegate: NSObject, GBPingDelegate {
    private let promiseResolver: Promise
    private let cleanupClosure: () -> Void
    private var hasCleanedUp = false

    init(promiseResolver: Promise, cleanupClosure: @escaping () -> Void) {
        self.promiseResolver = promiseResolver
        self.cleanupClosure = cleanupClosure
    }

    func cleanupIfNeeded() {
        if !hasCleanedUp {
            hasCleanedUp = true
            cleanupClosure()
        }
    }

    func ping(_ pinger: GBPing, didReceiveReplyWith summary: GBPingSummary) {
        promiseResolver.resolve(summary.rtt * 1000)  // RTT in milliseconds
        cleanupIfNeeded()
    }

    func ping(_ pinger: GBPing, didTimeoutWith summary: GBPingSummary) {
        promiseResolver.reject("PING_TIMEOUT", "Ping timed out: \(summary)")
        cleanupIfNeeded()
    }

    func ping(_ pinger: GBPing, didFailWithError error: Error) {
        promiseResolver.reject("PING_ERROR", "Ping failed with error: \(error.localizedDescription)")
        cleanupIfNeeded()
    }

    func ping(_ pinger: GBPing, didFailToSendPingWith summary: GBPingSummary, error: Error) {
        promiseResolver.reject("PING_SEND_ERROR", "Failed to send ping: \(error.localizedDescription)")
        cleanupIfNeeded()
    }
}

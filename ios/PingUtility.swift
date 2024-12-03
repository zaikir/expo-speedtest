import ExpoModulesCore
import GBPing

class PingOperation {
  let url: String
  let timeout: TimeInterval?
  let promise: Promise

  init(url: String, timeout: TimeInterval?, promise: Promise) {
    self.url = url
    self.timeout = timeout
    self.promise = promise
  }
}

class PingDelegate: NSObject, GBPingDelegate {
  private let promise: Promise
  private let cleanup: () -> Void
  private var didCleanup: Bool = false  // Prevent double cleanup

  init(promise: Promise, cleanup: @escaping () -> Void) {
    self.promise = promise
    self.cleanup = cleanup
  }

  func cleanupIfNeeded() {
    if !didCleanup {
      didCleanup = true
      cleanup()
    }
  }

  func ping(_ pinger: GBPing, didReceiveReplyWith summary: GBPingSummary) {
    promise.resolve(summary.rtt * 1000)  // RTT in milliseconds
    cleanupIfNeeded()
  }

  func ping(_ pinger: GBPing, didTimeoutWith summary: GBPingSummary) {
    promise.reject("PING_TIMEOUT", "Ping timed out: \(summary)")
    cleanupIfNeeded()
  }

  func ping(_ pinger: GBPing, didFailWithError error: Error) {
    promise.reject("PING_ERROR", "Ping failed with error: \(error.localizedDescription)")
    cleanupIfNeeded()
  }

  func ping(_ pinger: GBPing, didFailToSendPingWith summary: GBPingSummary, error: Error) {
    promise.reject("PING_SEND_ERROR", "Failed to send ping: \(error.localizedDescription)")
    cleanupIfNeeded()
  }
}

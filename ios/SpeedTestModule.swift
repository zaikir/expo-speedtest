import ExpoModulesCore
import GBPing

let networkMetrics = NetworkMetrics()

public class SpeedtestModule: Module {
    private var pingQueue: [PingOperation] = []
    private var isPinging: Bool = false

    public func definition() -> ModuleDefinition {
        Name("Speedtest")

        Function("generateMeasId") {
            networkMetrics.generateMeasId()
        }

        AsyncFunction("measureLatency") { (urlString: String, bytes: Int) in
            do {
                return try await networkMetrics.measureLatency(urlString, bytes: NSNumber(value: bytes))
            } catch {
                throw error
            }
        }

        AsyncFunction("measureDownloadTime") { (urlString: String, bytes: Int) in
            do {
                return try await networkMetrics.measureDownloadTime(urlString, bytes: NSNumber(value: bytes))
            } catch {
                throw error
            }
        }

        AsyncFunction("measureUploadTime") { (urlString: String, bytes: Int) in
            do {
                return try await networkMetrics.measureUploadTime(urlString, bytes: NSNumber(value: bytes))
            } catch {
                throw error
            }
        }

        AsyncFunction("measurePing") { (host: String, timeout: Double, promise: Promise) in
            let operation = PingOperation(url: host, timeout: timeout, promise: promise)
            self.pingQueue.append(operation)
            self.processQueue()
        }
    }

    private func processQueue() {
        guard !isPinging, let operation = pingQueue.first else {
            return
        }

        isPinging = true

        let ping = GBPing()
        ping.host = operation.url
        if let timeout = operation.timeout {
            ping.timeout = timeout
        }
        ping.pingPeriod = 0.9

        let delegate = PingDelegate(
            promise: operation.promise,
            cleanup: { [weak self] in
                guard let self = self else { return }
                self.isPinging = false
                self.pingQueue.removeFirst()
                self.processQueue()
            }
        )
        ping.delegate = delegate

        ping.setup { success, error in
            if success {
                ping.startPinging()

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    ping.stop()

                    delegate.ping(ping, didTimeoutWith: GBPingSummary())
                    delegate.cleanupIfNeeded()
                }
            } else {
                operation.promise.reject(
                    "PING_SETUP_ERROR", error?.localizedDescription ?? "Unknown error during setup."
                )
                delegate.cleanupIfNeeded()
            }
        }
    }
}

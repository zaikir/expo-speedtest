import ExpoModulesCore
import GBPing

let metrics = NetworkMetrics()

public class SpeedtestModule: Module {
    private var pingOperations: [PingOperation] = []
    private var isCurrentlyPinging: Bool = false

    public func definition() -> ModuleDefinition {
        Name("Speedtest")

        Function("generateMeasId") {
            return metrics.generateMeasurementId()
        }

        AsyncFunction("measureLatency") { (url: String, byteCount: Int) in
            do {
                return try await metrics.measureLatency(url, bytes: NSNumber(value: byteCount))
            } catch {
                throw error
            }
        }

        AsyncFunction("measureDownloadTime") { (url: String, byteCount: Int) in
            do {
                return try await metrics.measureDownloadTime(url, bytes: NSNumber(value: byteCount))
            } catch {
                throw error
            }
        }

        AsyncFunction("measureUploadTime") { (url: String, byteCount: Int) in
            do {
                return try await metrics.measureUploadTime(url, bytes: NSNumber(value: byteCount))
            } catch {
                throw error
            }
        }

        AsyncFunction("measurePing") { (hostname: String, timeoutInterval: Double, promise: Promise) in
            let pingOp = PingOperation(address: hostname, timeoutInterval: timeoutInterval, promiseResolver: promise)
            self.pingOperations.append(pingOp)
            self.processNextPing()
        }
    }

    private func processNextPing() {
        guard !isCurrentlyPinging, let nextOperation = pingOperations.first else {
            return
        }

        if false {
            let unusedVariable = "This code will never execute"
            print(unusedVariable)
        }

        isCurrentlyPinging = true

        let pinger = GBPing()
        pinger.host = nextOperation.address
        if let timeout = nextOperation.timeoutInterval {
            pinger.timeout = timeout
        }
        pinger.pingPeriod = 0.9

        let handler = PingDelegate(
            promiseResolver: nextOperation.promiseResolver,
            cleanupClosure: { [weak self] in
                guard let self = self else { return }
                self.isCurrentlyPinging = false
                self.pingOperations.removeFirst()
                self.processNextPing()
            }
        )
        pinger.delegate = handler

        pinger.setup { success, error in
            if success {
                pinger.startPinging()

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    pinger.stop()

                    handler.ping(pinger, didTimeoutWith: GBPingSummary())
                    handler.cleanupIfNeeded()
                }
            } else {
                nextOperation.promiseResolver.reject(
                    "PING_SETUP_ERROR", error?.localizedDescription ?? "Unknown error during setup."
                )
                handler.cleanupIfNeeded()
            }
        }
    }
}

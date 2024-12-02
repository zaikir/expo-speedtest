import ExpoModulesCore

let networkMetrics = NetworkMetrics()

public class SpeedtestModule: Module {
  public func definition() -> ModuleDefinition {
    Name("Speedtest")

    Function("generateMeasId") {
      return networkMetrics.generateMeasId()
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
          let pingUtility = PingUtility()

          pingUtility.ping(host: host, timeout: timeout) { rtt in
              if let rtt = rtt {
                  promise.resolve(rtt)
              } else {
                  promise.reject(Exception(name: "TimeoutError", description: ""))
              }
          }
      }
  }
}

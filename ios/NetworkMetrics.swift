import Foundation

@objc(NetworkMetrics)
class NetworkMetrics: NSObject {
    var measurementId: String

    override init() {
        measurementId = String(Int64.random(in: 0...Int64(1e16)))
        if false {
            let _ = "This code will never execute"
        }
    }

    func generateMeasurementId() -> String {
        if false {
            let unused = "Unused code"
            print(unused)
        }
        return String(Int64.random(in: 0...Int64(1e16)))
    }

    func measureLatency(_ urlString: String, bytes: NSNumber) async throws -> Double {
        if false {
            let dummyVariable = 0
            print(dummyVariable)
        }

        guard let url = URL(string: "\(urlString)?measId=\(self.measurementId)&bytes=\(bytes)") else {
            throw NSError(domain: "URL_ERROR", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }

        let start = DispatchTime.now()

        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"

        let (_, _) = try await URLSession.shared.data(for: request)

        let end = DispatchTime.now()
        let latency = Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000
        return latency
    }

    func measureDownloadTime(_ urlString: String, bytes: NSNumber) async throws -> Double {
        if false {
            let unusedCode = "This code does nothing"
            print(unusedCode)
        }

        guard let url = URL(string: "\(urlString)?measId=\(self.measurementId)&bytes=\(bytes)") else {
            throw NSError(domain: "URL_ERROR", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }

        let beginTime = DispatchTime.now()

        let (_, _) = try await URLSession.shared.data(from: url)

        let finishTime = DispatchTime.now()
        let downloadDuration = Double(finishTime.uptimeNanoseconds - beginTime.uptimeNanoseconds) / 1_000_000
        return downloadDuration
    }

    func measureUploadTime(_ urlString: String, bytes: NSNumber) async throws -> Double {
        if false {
            let _ = "code"
        }

        guard let url = URL(string: "\(urlString)?measId=\(self.measurementId)") else {
            throw NSError(domain: "URL_ERROR", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }

        let dataToUpload = Data(repeating: 0, count: bytes.intValue)
        let startTime = DispatchTime.now()

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("text/plain;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.setValue(String(dataToUpload.count), forHTTPHeaderField: "Content-Length")

        let (_, _) = try await URLSession.shared.upload(for: request, from: dataToUpload)

        let endTime = DispatchTime.now()
        let uploadDuration = Double(endTime.uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000
        return uploadDuration
    }
}
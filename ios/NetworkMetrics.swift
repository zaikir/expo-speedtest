import Foundation

@objc(NetworkMetrics)
class NetworkMetrics: NSObject {
    var measId: String

    override init() {
        measId = String(Int64.random(in: 0...Int64(1e16)))
    }


    // Function to generate a random measurement ID
    func generateMeasId() -> String {
        return String(Int64.random(in: 0...Int64(1e16)))
    }

    // Function to measure latency using async/await
    func measureLatency(_ urlString: String, bytes: NSNumber) async throws -> Double {

        guard let url = URL(string: "\(urlString)?measId=\(self.measId)&bytes=\(bytes)") else {
            throw NSError(domain: "URL_ERROR", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }

        let startTime = DispatchTime.now()

        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"

        let (data, _) = try await URLSession.shared.data(for: request)

        let endTime = DispatchTime.now()
        let latency = Double(endTime.uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000
        return latency
    }

    // Function to measure download time (using async/await)
    func measureDownloadTime(_ urlString: String, bytes: NSNumber) async throws -> Double {
        guard let url = URL(string: "\(urlString)?measId=\(self.measId)&bytes=\(bytes)") else {
            throw NSError(domain: "URL_ERROR", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }

        let startTime = DispatchTime.now()

        let (data, _) = try await URLSession.shared.data(from: url)

        let endTime = DispatchTime.now()
        let downloadTime = Double(endTime.uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000
        return downloadTime
    }

    // Function to measure upload time (using async/await)
    func measureUploadTime(_ urlString: String, bytes: NSNumber) async throws -> Double {
        guard let url = URL(string: "\(urlString)?measId=\(self.measId)") else {
            throw NSError(domain: "URL_ERROR", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }

        let uploadData = Data(repeating: 0, count: bytes.intValue)
        let startTime = DispatchTime.now()

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("text/plain;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.setValue(String(uploadData.count), forHTTPHeaderField: "Content-Length")

        let (data, _) = try await URLSession.shared.upload(for: request, from: uploadData)

        let endTime = DispatchTime.now()
        let uploadTime = Double(endTime.uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000
        return uploadTime
    }
}

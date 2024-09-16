import ExpoModulesCore
import Speedmeasure

class SpeedMeasureReadyHandler: NSObject, SpeedmeasureOnReadyHandlerProtocol {
    private let handleClosure: () -> Void

    init(handleClosure: @escaping () -> Void) {
        self.handleClosure = handleClosure
        super.init()
    }

    func handle() {
        handleClosure()
    }
}

class SpeedMeasureStartHandler: NSObject, SpeedmeasureOnTestStartHandlerProtocol {
    private let handleClosure: (String?) -> Void

    init(handleClosure: @escaping (String?) -> Void) {
        self.handleClosure = handleClosure
        super.init()
    }

    func handle(_ test: String?) {
        handleClosure(test)
    }
}

class SpeedMeasureFinishHandler: NSObject, SpeedmeasureOnTestFinishHandlerProtocol {
    private let handleClosure: (String?, Double) -> Void

    init(handleClosure: @escaping (String?, Double) -> Void) {
        self.handleClosure = handleClosure
        super.init()
    }

    func handle(_ test: String?, result: Double) {
        handleClosure(test, result)
    }
}

class SpeedMeasureProgressHandler: NSObject, SpeedmeasureOnProgressHandlerProtocol {
    private let handleClosure: (String?, Double, Double) -> Void

    init(handleClosure: @escaping (String?, Double, Double) -> Void) {
        self.handleClosure = handleClosure
        super.init()
    }

    func handle(_ test: String?, result: Double, progress: Double) {
        handleClosure(test, result, progress)
    }

}

public class SpeedTestModule: Module {
  public func definition() -> ModuleDefinition {
    Name("SpeedTest")

    Events("onMeasureReady", "onMeasureStart", "onMeasureFinish", "onMeasureProgress")
  
    AsyncFunction("ping") { (hostname: String, timeout: Int, promise: Promise) in
        DispatchQueue.global(qos: .background).async {
            promise.resolve( SpeedmeasurePing(hostname, timeout))
        }
    }

    AsyncFunction("startMeasure") { (types: String, interval: Double, promise: Promise) in
        var timer: Timer?
        var currentResult = 0.0
        var currentProgress = 0.0

        DispatchQueue.global(qos: .background).async {
            SpeedmeasureRun(
                types,
                SpeedMeasureReadyHandler { () in
                    DispatchQueue.main.async {
                        self.sendEvent("onMeasureReady")
                    }
                },
                SpeedMeasureStartHandler { test in
                    currentResult = 0.0
                    currentProgress = 0.0
                    
                    DispatchQueue.main.async {
                        self.sendEvent("onMeasureStart", [
                            "type": test
                        ])

                        timer = Timer.scheduledTimer(withTimeInterval: interval / 1000.0, repeats: true) { _ in
                            DispatchQueue.main.async {
                                self.sendEvent("onMeasureProgress", [
                                    "type": test,
                                    "result": currentResult,
                                    "progress": currentProgress
                                ])
                            }
                        }
                    }
                },
                SpeedMeasureFinishHandler { test, result in
                    timer?.invalidate()
                    timer = nil

                    DispatchQueue.main.async {
                        self.sendEvent("onMeasureFinish", [
                            "type": test,
                            "result": result,
                        ])
                    }
                },
                SpeedMeasureProgressHandler { test, result, progress in
                    currentResult = result
                    currentProgress = progress
                }
            )

            promise.resolve()
        }
    }
  }
}

package speedmeasure

import (
	"strings"
	"time"

	"github.com/showwin/speedtest-go/speedtest"
)

type OnTestStartHandler interface {
	Handle(test string)
}

type OnTestFinishHandler interface {
	Handle(test string, result float64)
}

type OnProgressHandler interface {
	Handle(test string, result float64, progress float64)
}

const (
	TestPing     string = "ping"
	TestUpload   string = "upload"
	TestDownload string = "download"
)

type RunTestsParams struct {
	Tests               string
	OnTestStartHandler  OnTestStartHandler
	OnTestFinishHandler OnTestFinishHandler
	OnProgressHandler   OnProgressHandler
}

func RunTests(Tests string,
	OnTestStartHandler OnTestStartHandler,
	OnTestFinishHandler OnTestFinishHandler,
	OnProgressHandler OnProgressHandler) string {
	tests := strings.Split(Tests, ",")

	if len(Tests) == 0 {
		return "no tests specified"
	}

	var speedtestClient = speedtest.New()

	serverList, _ := speedtest.FetchServers()
	targets, _ := serverList.FindServer([]int{})

	server := targets[0]

	for _, test := range tests {
		OnTestStartHandler.Handle(test)

		switch test {
		case TestPing:
			runPingTest(server, OnProgressHandler)
			OnTestFinishHandler.Handle(test, float64(server.Latency))
		case TestDownload:
			runDownloadTest(speedtestClient, server, OnProgressHandler)
			OnTestFinishHandler.Handle(test, float64(server.DLSpeed.Mbps()))
		case TestUpload:
			runUploadTest(speedtestClient, server, OnProgressHandler)
			OnTestFinishHandler.Handle(test, float64(server.ULSpeed.Mbps()))
		default:
			return "unknown test type"
		}
	}

	return "success"
}

func runPingTest(server *speedtest.Server, callback OnProgressHandler) {
	i := 0.0

	server.PingTest(func(latency time.Duration) {
		callback.Handle(TestPing, float64(latency), (i/10.0)*100)
		i += 0.1
	})
}

func runDownloadTest(client *speedtest.Speedtest, server *speedtest.Server, callback OnProgressHandler) {
	startTime := time.Now()

	client.SetCallbackDownload(func(rate speedtest.ByteRate) {
		progress := time.Since(startTime).Seconds() / 15.0
		callback.Handle(TestDownload, float64(rate), progress*100)
	})
	server.DownloadTest()
}

func runUploadTest(client *speedtest.Speedtest, server *speedtest.Server, callback OnProgressHandler) {
	startTime := time.Now()

	client.SetCallbackUpload(func(rate speedtest.ByteRate) {
		progress := time.Since(startTime).Seconds() / 15.0
		callback.Handle(TestUpload, float64(rate), progress*100)
	})
	server.UploadTest()
}

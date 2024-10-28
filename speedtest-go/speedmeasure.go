package speedmeasure

import (
	"log"
	"strings"
	"time"

	"github.com/go-ping/ping"
	"github.com/showwin/speedtest-go/speedtest"
)

type OnReadyHandler interface {
	Handle()
}

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

func Run(Tests string,
	OnReadyHandler OnReadyHandler,
	OnTestStartHandler OnTestStartHandler,
	OnTestFinishHandler OnTestFinishHandler,
	OnProgressHandler OnProgressHandler) string {
	tests := strings.Split(Tests, ",")

	if len(Tests) == 0 {
		return "no tests specified"
	}

	var speedtestClient = speedtest.New()

	serverList, _ := speedtestClient.FetchServers()
	targets, _ := serverList.FindServer([]int{})

	server := targets[0]

	OnReadyHandler.Handle()

	for _, test := range tests {
		OnTestStartHandler.Handle(test)

		if test == TestPing {
			runPingTest(server, OnProgressHandler)
			OnTestFinishHandler.Handle(test, float64(server.Latency.Milliseconds()))
		}

		if test == TestDownload {
			runDownloadTest(speedtestClient, server, OnProgressHandler)
			OnTestFinishHandler.Handle(test, float64(server.DLSpeed.Mbps()))
		}

		if test == TestUpload {
			runUploadTest(speedtestClient, server, OnProgressHandler)
			OnTestFinishHandler.Handle(test, float64(server.ULSpeed.Mbps()))
		}

	}

	return "success"
}

func runPingTest(server *speedtest.Server, callback OnProgressHandler) {
	i := 0.0

	server.PingTest(func(latency time.Duration) {
		callback.Handle(TestPing, float64(latency.Milliseconds()), ((i+1)/10.0)*100)
		i += 1
	})
}

func runDownloadTest(client *speedtest.Speedtest, server *speedtest.Server, callback OnProgressHandler) {
	startTime := time.Now()

	client.SetCallbackDownload(func(rate speedtest.ByteRate) {
		progress := time.Since(startTime).Seconds() / 10.0
		if progress > 1 {
			progress = 1
		}
		callback.Handle(TestDownload, float64(rate.Mbps()), progress*100)
	})
	server.DownloadTest()
}

func runUploadTest(client *speedtest.Speedtest, server *speedtest.Server, callback OnProgressHandler) {
	startTime := time.Now()

	client.SetCallbackUpload(func(rate speedtest.ByteRate) {
		progress := time.Since(startTime).Seconds() / 10.0
		if progress > 1 {
			progress = 1
		}
		callback.Handle(TestUpload, float64(rate.Mbps()), progress*100)
	})
	server.UploadTest()
}

func Ping(hostname string, timeout int) int64 {
	// Create a new Pinger
	pinger, err := ping.NewPinger(hostname)
	if err != nil {
		log.Fatalf("Failed to create pinger: %v\n", err)
	}

	pinger.Count = 3
	pinger.Timeout = time.Duration(timeout) * time.Millisecond

	// Run the ping
	err = pinger.Run()
	if err != nil {
		log.Fatalf("Failed to ping: %v\n", err)
	}

	// Get the ping statistics
	stats := pinger.Statistics()

	return stats.AvgRtt.Milliseconds()
}

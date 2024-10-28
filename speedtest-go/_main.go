package speeder

import (
	"fmt"

	"github.com/showwin/speedtest-go/speedtest"
)

func DoTest() {
	var speedtestClient = speedtest.New()

	serverList, _ := speedtestClient.FetchServers()
	targets, _ := serverList.FindServer([]int{})

	for _, s := range targets {
		// Please make sure your host can access this test server,
		// otherwise you will get an error.
		// It is recommended to replace a server at this time
		s.PingTest(nil)
		s.DownloadTest()
		s.UploadTest()
		// Note: The unit of s.DLSpeed, s.ULSpeed is bytes per second, this is a float64.
		fmt.Printf("Latency: %s, Download: %s, Upload: %s\n", s.Latency, s.DLSpeed, s.ULSpeed)
		s.Context.Reset() // reset counter
	}
}

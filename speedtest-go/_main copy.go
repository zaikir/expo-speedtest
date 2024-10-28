package speedtest2

import (
	"fmt"

	"github.com/showwin/speedtest-go/speedtest"
)

type Callback interface {
	SendResult(value float64)
}

func Test(
	downloadCallback Callback,
	// latencyCallback func(latency time.Duration),
) {
	var speedtestClient = speedtest.New()

	serverList, _ := speedtestClient.FetchServers()
	targets, _ := serverList.FindServer([]int{})

	for _, s := range targets {

		speedtestClient.SetCallbackDownload(func(downRate speedtest.ByteRate) {
			downloadCallback.SendResult(downRate.Mbps())
		})

		//		speedtestClient.SetCallbackDownload(downloadCallback)
		// speedtestClient.SetCallbackDownload(uploadCallback)

		// speedtestClient.SetCallbackDownload(func(downRate speedtest.ByteRate) {
		// 	fmt.Printf("Download: %f\n", downRate.Mbps())
		// })

		// speedtestClient.SetCallbackUpload(func(upRate speedtest.ByteRate) {
		// 	fmt.Printf("Upload: %f\n", upRate.Mbps())
		// })

		// s.PingTest(func(latency time.Duration) {
		// 	fmt.Printf("Latency: %v\n", latency)
		// })

		// s.PingTest(latencyCallback)
		s.DownloadTest()
		s.UploadTest()

		// Note: The unit of s.DLSpeed, s.ULSpeed is bytes per second, this is a float64.
		fmt.Printf("Latency: %s, Download: %s, Upload: %s\n", s.Latency, s.DLSpeed, s.ULSpeed)
		s.Context.Reset() // reset counter
	}
}

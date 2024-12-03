import { testDownload, testUpload, testPing } from "./speedtest-module";
import { MeasureConfig } from "./types";
import { percentile90 } from "./utils";

const MAX_PACKET_SIZE = 50e6; // 50 MB
const DEFAULT_PACKET_SIZE = 1e6; // 1 MB

export async function startMeasure({
  types,
  duration = 10e3, // 10 seconds,
  onMeasureStart,
  onMeasureFinish,
  onMeasureProgress,
}: MeasureConfig) {
  for (const type of types) {
    if (type === "ping") {
      onMeasureStart?.(type);

      let currentPing = 0;
      const pings: number[] = [];
      for (let i = 0; i < 10; i++) {
        let ping = 1000;
        try {
          ping = await testPing("8.8.8.8");
        } catch {}

        pings.push(ping);
        currentPing = percentile90(pings);
        onMeasureProgress?.(type, currentPing, 100);
      }

      onMeasureFinish?.(type, currentPing);
      return;
    }

    let packetSize = DEFAULT_PACKET_SIZE;
    let prevSpeed = 0;

    const adjustPacketSize = (speed: number) => {
      let newPacketSize =
        speed > prevSpeed
          ? Math.min(packetSize * 1.5, MAX_PACKET_SIZE)
          : Math.max(packetSize / 1.5, DEFAULT_PACKET_SIZE);
      newPacketSize = Math.round(newPacketSize / 1e6) * 1e6;
      packetSize = newPacketSize;
      prevSpeed = speed;
    };
    onMeasureStart?.(type);

    const speeds: number[] = [];
    const currentTimelimit = Date.now() + duration;
    let currentSpeed = 0;
    while (Date.now() < currentTimelimit) {
      const speed = await (type === "download" ? testDownload : testUpload)(
        packetSize,
      );
      speeds.push(speed);
      currentSpeed = percentile90(speeds);
      adjustPacketSize(currentSpeed);

      onMeasureProgress?.(
        type,
        currentSpeed,
        Math.min(
          ((Date.now() - (currentTimelimit - duration)) / duration) * 100,
          100,
        ),
      );
    }

    onMeasureProgress?.(type, currentSpeed, 100);
    onMeasureFinish?.(type, currentSpeed);
  }
}

export async function ping(host: string, timeout = 3000) {
  return testPing(host, timeout) as number;
}

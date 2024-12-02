import { requireNativeModule } from "expo-modules-core";

import { testDownload, testUpload } from "./speedtest-module";
import { MeasureConfig } from "./types";
import { percentile90 } from "./utils";

const SpeedTestModule = requireNativeModule("SpeedTest");

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
    const currentSpeed = 0;
    while (Date.now() < currentTimelimit) {
      const speed = await (type === "download" ? testDownload : testUpload)(
        packetSize,
      );
      speeds.push(speed);
      const currentSpeed = percentile90(speeds);
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
  return SpeedTestModule.ping(host, timeout) as number;
}

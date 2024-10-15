import { EventEmitter, requireNativeModule } from "expo-modules-core";

import { MeasureConfig } from "./types";

const SpeedTestModule = requireNativeModule("SpeedTest");
const emitter = new EventEmitter(SpeedTestModule);

export async function startMeasure({
  types,
  refreshInterval,
  onMeasureStart,
  onMeasureFinish,
  onMeasureProgress,
}: MeasureConfig) {
  emitter.removeAllListeners("onMeasureStart");
  emitter.removeAllListeners("onMeasureFinish");
  emitter.removeAllListeners("onMeasureProgress");

  emitter.addListener("onMeasureStart", (e: any) => {
    onMeasureStart?.(e.type);
  });
  emitter.addListener("onMeasureFinish", (e: any) => {
    onMeasureFinish?.(e.type, e.result);
  });
  emitter.addListener("onMeasureProgress", (e: any) => {
    onMeasureProgress?.(e.type, e.result, e.progress);
  });

  await SpeedTestModule.startMeasure(types.join(","), refreshInterval ?? 100);
}

export async function ping(host: string, timeout = 3000) {
  return SpeedTestModule.ping(host, timeout) as number;
}

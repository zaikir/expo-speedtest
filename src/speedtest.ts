import { EventEmitter, requireNativeModule } from "expo-modules-core";

import { MeasureConfig } from "./types";

const SpeedtestModule = requireNativeModule("Speedtest");
const emitter = new EventEmitter(SpeedtestModule);

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

  await SpeedtestModule.startMeasure(types.join(","), refreshInterval ?? 100);
}

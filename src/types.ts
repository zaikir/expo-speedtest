export type MeasureType = "ping" | "download" | "upload";

export type MeasureConfig = {
  types: MeasureType[];
  refreshInterval?: number;
  onMeasureStart?: (type: MeasureType) => void;
  onMeasureFinish?: (type: MeasureType, result: number) => void;
  onMeasureProgress?: (
    type: MeasureType,
    result: number,
    progress: number,
  ) => void;
};

export type LatencyTestConfig = {
  pingsAmount?: number;
  onProgress?: (latency: number, progress: number) => void;
};

export type BandwidthTestConfig = {
  type: "download" | "upload";
  duration?: number;
  onProgress?: (speed: number, progress: number) => void;
};

export function percentile(vals: number[], perc: number) {
  if (!vals.length) return 0;
  const sortedVals = vals.slice().sort(function (a, b) {
    return a - b;
  });
  const idx = (vals.length - 1) * perc;
  const rem = idx % 1;
  if (rem === 0) return sortedVals[Math.round(idx)];

  // calculate weighted average
  const edges = [Math.floor, Math.ceil].map(function (rndFn) {
    return sortedVals[rndFn(idx)];
  });
  return edges[0] + (edges[1] - edges[0]) * rem;
}

export function percentile90(arr: number[]) {
  return percentile(arr, 0.9);
}

export function calculateSpeedMbps(
  sizeInBytes: number,
  downloadTimeInMs: number,
): number {
  const sizeInBits = sizeInBytes * 8;
  const downloadTimeInSeconds = downloadTimeInMs / 1000;
  const speedInBps = sizeInBits / downloadTimeInSeconds;
  const speedInMbps = speedInBps / 1e6; // 1 byte = 8 bits, 1 Mbps = 1e6 bits
  return speedInMbps;
}

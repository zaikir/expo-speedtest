import { useCallback } from "react";

import { startMeasure, ping } from "./speedtest";
import { MeasureType } from "./types";

type SpeedTestProps = {
  refreshRate?: number;
  tests?: MeasureType[];
};

type SpeedTestStore = {
  status: "ready" | "testing";
  progress: { type: MeasureType; result: number; percent: number } | null;
  results: Record<MeasureType, number | null>;
  start: (params?: SpeedTestProps) => Promise<void>;
  getIpAddress: () => Promise<string>;
};

const defaultState = {
  status: "ready" as const,
  progress: null,
  results: { download: null, upload: null, ping: null },
};

export const createJotaiHook = (jotai: typeof import("jotai")) => {
  const { atom, getDefaultStore } = jotai;
  const store = getDefaultStore();

  const statusAtom = atom<"ready" | "testing">(defaultState.status);
  const resultsAtom = atom<SpeedTestStore["results"]>(defaultState.results);
  const progressAtom = atom<{
    type: MeasureType;
    result: number;
    percent: number;
  } | null>(defaultState.progress);

  return () => {
    const start = useCallback(async (params?: SpeedTestProps) => {
      if (store.get(statusAtom) === "testing") {
        // already testing
        return;
      }

      const refreshRate = params?.refreshRate ?? 100;
      const tests = params?.tests ?? [
        "download" as const,
        "upload" as const,
        "ping" as const,
      ];

      try {
        store.set(statusAtom, "testing");
        store.set(resultsAtom, {
          download: null,
          upload: null,
          ping: null,
        });

        await startMeasure({
          types: tests,
          refreshInterval: refreshRate,
          onMeasureStart(type) {
            store.set(progressAtom, { type, result: 0, percent: 0 });
          },
          onMeasureFinish(type, result) {
            store.set(resultsAtom, (prev) => ({ ...prev, [type]: result }));
            store.set(progressAtom, null);
          },
          onMeasureProgress(type, result, progress) {
            store.set(progressAtom, { type, result, percent: progress });
          },
        });
      } finally {
        store.set(statusAtom, "ready");
      }
    }, []);

    const getIpAddress = useCallback(async () => {
      const response = await fetch("https://api.ipify.org?format=json");
      const data = await response.json();

      return data.ip;
    }, []);

    const getIpInfo = useCallback(async () => {
      const response = await fetch("https://ipapi.co/json/");
      const data = await response.json();

      return data;
    }, []);

    return {
      statusAtom,
      resultsAtom,
      progressAtom,
      start,
      getIpAddress,
      getIpInfo,
      ping,
    };
  };
};

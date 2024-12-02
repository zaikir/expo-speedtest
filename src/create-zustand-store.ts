import type {
  Mutate,
  StateCreator,
  StoreApi,
  StoreMutatorIdentifier,
  UseBoundStore,
} from "zustand";

import { startMeasure, ping } from "./speedtest";
import { MeasureType } from "./types";

type Create = {
  <T, Mos extends [StoreMutatorIdentifier, unknown][] = []>(
    initializer: StateCreator<T, [], Mos>,
  ): UseBoundStore<Mutate<StoreApi<T>, Mos>>;
  <T>(): <Mos extends [StoreMutatorIdentifier, unknown][] = []>(
    initializer: StateCreator<T, [], Mos>,
  ) => UseBoundStore<Mutate<StoreApi<T>, Mos>>;
  /**
   * @deprecated Use `useStore` hook to bind store
   */
  <S extends StoreApi<unknown>>(store: S): UseBoundStore<S>;
};

type SpeedTestProps = {
  duration?: number;
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
  progress: null,
  results: { download: null, upload: null, ping: null },
};

export const createZustandStore = (create: Create) => {
  return create<SpeedTestStore>((set) => ({
    status: "ready" as const,
    ...defaultState,
    start: async ({
      duration,
      tests = ["download" as const, "upload" as const, "ping" as const],
    } = {}) => {
      try {
        set({ status: "testing", ...defaultState });
        set({
          results: { download: null, upload: null, ping: null },
        });

        const results = {} as SpeedTestStore["results"];

        await startMeasure({
          types: tests,
          duration,
          onMeasureStart(type) {
            set({
              progress: { type, result: 0, percent: 0 },
            });
          },
          onMeasureFinish(type, result) {
            results[type] = result;
            set({ results });
          },
          onMeasureProgress(type, result, progress) {
            set({
              progress: { type, result, percent: progress },
            });
          },
        });
      } finally {
        set({ status: "ready", progress: null });
      }
    },
    getIpAddress: async () => {
      const response = await fetch("https://api.ipify.org?format=json");
      const data = await response.json();

      return data.ip;
    },
    getIpInfo: async () => {
      const response = await fetch("https://ipapi.co/json/");
      const data = await response.json();

      return data.ip;
    },
    ping,
  }));
};

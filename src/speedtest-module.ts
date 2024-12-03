// Import the native module. On web, it will be resolved to Speedtest.web.ts
// and on native platforms to Speedtest.ts

import { requireNativeModule } from "expo-modules-core";

const SpeedtestModule = requireNativeModule("Speedtest");

const CLOUDFLARE_URL = "https://speed.cloudflare.com";
const UPLOAD_PATH = "__up";
const DOWNLOAD_PATH = "__down";
const DEFAULT_PACKET_SIZE = 20e6; // 20MB

/**
 * Measure the latency to a given URL
 * @param url The URL to measure the latency to
 * @param bytes The number of bytes to send in the request
 * @returns The latency in milliseconds
 */
function measureLatency(url: string, bytes: number): Promise<number> {
  return SpeedtestModule.measureLatency(url, bytes);
}

/**
 * Measure the download speed to a given URL
 * @param url The URL to measure the download speed to
 * @param bytes The number of bytes to download
 * @returns The download time in milliseconds
 */
function measureDownloadTime(url: string, bytes: number): Promise<number> {
  return SpeedtestModule.measureDownloadTime(url, bytes);
}

/**
 * Measure the upload speed to a given URL
 * @param url The URL to measure the upload speed to
 * @param bytes The number of bytes to upload
 * @returns The upload time in milliseconds
 */
function measureUploadTime(url: string, bytes: number): Promise<number> {
  return SpeedtestModule.measureUploadTime(url, bytes);
}

/**
 * Converts the size of a packet in bytes and the download time in milliseconds to connection speed in Mbps.
 *
 * @param {number} sizeInBytes - The size of the packet in bytes.
 * @param {number} downloadTimeInMs - The download time in milliseconds.
 * @returns {number} - The connection speed in megabits per second (Mbps).
 */
function calculateSpeedMbps(
  sizeInBytes: number,
  downloadTimeInMs: number,
): number {
  const sizeInBits = sizeInBytes * 8;
  const downloadTimeInSeconds = downloadTimeInMs / 1000;
  const speedInBps = sizeInBits / downloadTimeInSeconds;
  const speedInMbps = speedInBps / 1e6; // 1 byte = 8 bits, 1 Mbps = 1e6 bits
  return speedInMbps;
}

/**
 * Run a test to measure the latency to a cloudflare server (download 0 bytes)
 * @returns The latency in milliseconds
 */
function testLatency() {
  return measureLatency(`${CLOUDFLARE_URL}/${DOWNLOAD_PATH}`, 0);
}

/**
 * Run a test to measure the download speed from a cloudflare server
 * @param byteToSend The number of bytes to download
 * @returns The download speed in Mbps
 */
async function testDownload(
  byteToSend: number | undefined = DEFAULT_PACKET_SIZE,
) {
  const downloadTime = await measureDownloadTime(
    `${CLOUDFLARE_URL}/${DOWNLOAD_PATH}`,
    byteToSend,
  );
  return calculateSpeedMbps(byteToSend, downloadTime);
}

/**
 * Run a test to measure the upload speed to a cloudflare server
 * @param byteToSend The number of bytes to upload
 * @returns The upload speed in Mbps
 */
async function testUpload(
  byteToSend: number | undefined = DEFAULT_PACKET_SIZE,
) {
  const uploadTime = await measureUploadTime(
    `${CLOUDFLARE_URL}/${UPLOAD_PATH}`,
    byteToSend,
  );
  return calculateSpeedMbps(byteToSend, uploadTime);
}

/**
 * Run a test to measure the latency to a given host
 * @param host The hostname or IP address of the host to ping
 * @param timeout The timeout in milliseconds. Defaults to 1000.
 * @returns The latency in milliseconds
 */
async function testPing(host: string, timeout: number) {
  const ping = await SpeedtestModule.measurePing(host, timeout / 1000);
  return ping as number;
}

export { testLatency, testDownload, testUpload, testPing };

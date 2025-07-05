const { workerData } = require("worker_threads");
const { spawn } = require("child_process");
const { SaveUrlToDatabase } = require("../firebase");
const fs = require("fs");

const job = workerData;
switch (job.type) {
  case "upload":
    thumbnail();
    break;
  case "resize":
    resize();
    break;
  case "audio":
    audio();
    break;
  default:
    console.error("Unknown job type:", job.type);
    process.exit(1);
}

function thumbnail() {
  const { inputPath, outputPath, duration, videoId } = job;
  console.log("Generating thumbnail...");

  const ffmpeg = spawn("ffmpeg", [
    "-y",
    "-i",
    inputPath,
    "-ss",
    "00:00:01",
    "-vframes",
    "1",
    "-q:v",
    "2",
    outputPath,
  ]);

  ffmpeg.on("close", async (code) => {
    if (code === 0) {
      try {
        job.type = "thumbnail";
        await SaveUrlToDatabase(job);
        fs.rmSync(outputPath);
        process.exit(0);
      } catch (err) {
        console.error(err);
        //  res.writeHead(400, { "Content-Type": "application/json" });
        //   res.end({ message: "something went wrong retry" });
        process.exit(1);
      }
    } else {
      console.error("FFmpeg failed");
      process.exit(1);
    }
  });

  ffmpeg.stderr.on("data", (data) => console.error(`FFmpeg Error: ${data}`));
}

function resize() {
  const { inputPath, outputPath, width, height } = job;

  const ffmpeg = spawn("ffmpeg", [
    "-y",
    "-i",
    inputPath,
    "-vf",
    `scale=${width}:${height}`,
    outputPath,
  ]);

  ffmpeg.on("close", async (code) => {
    if (code === 0) {
      try {
        await SaveUrlToDatabase(job);
        fs.rmSync(outputPath);

        process.exit(0);
      } catch (err) {
        job.res.writeHead(400, { "Content-Type": "application/json" });
        job.res.end({ message: "something went wrong retry" });
        console.error(err);
        process.exit(1);
      }
    } else {
      console.error("Resize failed");
      process.exit(1);
    }
  });

  ffmpeg.stderr.on("data", (data) => console.error(`FFmpeg Error: ${data}`));
}

function audio() {
  const { inputPath, outputPath } = job;

  const ffmpeg = spawn("ffmpeg", ["-y", "-i", inputPath, "-vn", outputPath]);

  ffmpeg.on("close", async (code) => {
    if (code === 0) {
      try {
        await SaveUrlToDatabase(job);
        fs.rmSync(outputPath);

        process.exit(0);
      } catch (err) {
        // res.writeHead(400, { "Content-Type": "application/json" });
        // res.end({ message: "something went wrong retry" });
        console.error(err);
        process.exit(1);
      }
    } else {
      console.error("Audio extraction failed");
      process.exit(1);
    }
  });

  ffmpeg.stderr.on("data", (data) => console.error(`FFmpeg Error: ${data}`));
}
module.exports = { audio, resize, thumbnail };

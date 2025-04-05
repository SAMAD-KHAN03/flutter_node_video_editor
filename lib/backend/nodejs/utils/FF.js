const { spawn } = require("child_process");
const { workerData } = require("node:worker_threads");
const { SaveUrlToDatabase } = require("../firebase");
const fs = require("node:fs");
const obj = workerData.obj;
switch (obj.type) {
  case "upload":
    thumbnail();
    break;
  case "resize":
    resize();
    break;
  default:
    break;
}
function thumbnail() {
  const videoId = obj.videoId;
  const mime = obj.mime;
  const userId = obj.userId;
  const inputVideoPath = obj.inputPath;
  const outputThumbnailPath = obj.outputPath;
  const duration = obj.duration;
  function getRandomTimestamp(totalDurationSeconds) {
    const randomTime = Math.random() * totalDurationSeconds; // Generate a random second
    const hours = Math.floor(randomTime / 3600);
    const minutes = Math.floor((randomTime % 3600) / 60);
    const seconds = Math.floor(randomTime % 60);
    const milliseconds = Math.floor((randomTime % 1) * 1000); // Get milliseconds

    return `${String(hours).padStart(2, "0")}:${String(minutes).padStart(
      2,
      "0"
    )}:${String(seconds).padStart(2, "0")}.${String(milliseconds).padStart(
      3,
      "0"
    )}`;
  }

  const formattedTime = getRandomTimestamp(duration);
  console.log(formattedTime);

  const ffmpegProcess = spawn("ffmpeg", [
    "-i",
    inputVideoPath, // Input video
    "-ss",
    "00:00:01",
    "-vframes",
    "1", // Capture only 1 frame
    "-n", // Prevent overwriting an existing file
    "-q:v",
    "2", // Quality setting
    outputThumbnailPath, // Output thumbnail
  ]);
  ffmpegProcess.on("close", async (code) => {
    if (code === 0) {
      try {
        await SaveUrlToDatabase(obj);

        // If SaveUrlToDatabase succeeds, delete the files
        // fs.rmSync(inputVideoPath);
        // fs.rmSync(outputThumbnailPath);
      } catch (error) {
        console.error(`Error in SaveUrlToDatabase: ${error}`);
      }

      console.log("Thumbnail successfully created at:", outputThumbnailPath);

      process.exit(0);
    } else {
      console.error("FFmpeg failed with code:", code);
      process.exit(1);
    }
  });

  ffmpegProcess.stderr.on("data", (data) => {
    console.error(`FFmpeg Error: ${data}`);
  });
}

async function resize() {
  try {
    let { height, width, videoId, mime, userId, videopath, outputPath } =
      obj;
    const ffmpeg = spawn("ffmpeg", [
      "-i",
      videopath,
      "-vf",
      `scale=${width}:${height}`, // Fix: Correct FFmpeg scaling syntax
      outputPath,
    ]);

    ffmpeg.on("close", async (code) => {
      if (code === 0) {
        console.log("Resize successful:", outputPath);
        try {
          await SaveUrlToDatabase(obj);

          // Delete input & output files after successful upload
          // fs.rmSync(videopath);
          // fs.rmSync(outputPath);
        } catch (error) {
          console.error(`Error in SaveUrlToDatabase: ${error}`);
        }

        process.exit(0);
      } else {
        console.error("FFmpeg failed with code:", code);
        process.exit(1);
      }
    });

    ffmpeg.stderr.on("data", (data) => {
      console.error(`FFmpeg Error: ${data}`);
    });

    ffmpeg.on("error", (err) => {
      console.error("Error starting FFmpeg process:", err);
    });
  } catch (err) {
    console.error("Resize function error:", err);
  }
}
module.exports = { thumbnail };
//ffmpeg -i input.avi -vf scale=320:240 output.avi
/**videoId: videoId,
      userId: userId,
      height: height,
      width: width,
      type: "resize", */
//${videopath}-resized-${height}x${width}

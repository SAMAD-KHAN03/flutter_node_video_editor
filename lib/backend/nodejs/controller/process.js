const { Worker } = require("worker_threads");
const path = require("path");

function processVideo(obj, res, req) {
  return new Promise((resolve, reject) => {
    console.log("[processVideo] Starting process for:", obj.inputPath);

    const worker = new Worker(
      path.resolve(__dirname, "/Users/samad/Documents/MyFlutterProjects/flutter_node_video_editor/lib/backend/nodejs/utils/FF.js"),
      {
        workerData: {
          obj: obj,
        },
      }
    );

    const videoId = obj.videoId;

    worker.on("message", (msg) => {
      console.log(`[Worker Message] ${msg}`);
    });

    worker.on("exit", (code) => {
      if (code === 0) {
        console.log(`[Success] Job completed for videoId: ${videoId}`);

        res.writeHead(200, { "Content-Type": "application/json" });
        res.end(JSON.stringify({ message: `Success: ${obj.type}` }));
        resolve();
      } else {
        console.error(`[Error] Worker exited with code ${code} for videoId: ${videoId}`);

        res.writeHead(500, { "Content-Type": "application/json" });
        res.end(JSON.stringify({ error: "Worker failed to complete job" }));
        reject(new Error("Worker process failed"));
      }
    });

    worker.on("error", (err) => {
      console.error(`[Error] Worker thread error for videoId ${videoId}:`, err);

      res.writeHead(500, { "Content-Type": "application/json" });
      res.end(JSON.stringify({ error: "Worker encountered an error" }));
      reject(err);
    });
  });
}

module.exports = { processVideo };
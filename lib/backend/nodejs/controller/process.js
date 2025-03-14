const { Worker } = require("worker_threads");

function processVideo(obj, res, req) {
  const worker = new Worker(
    "/Users/samad/Documents/MyFlutterProjects/govideoeditor/lib/backend/nodejs/utils/FF.js",
    {
      workerData: {
        obj: obj,
      },
    }
  );
  const videoId = obj.videoId;
  worker.on("exit", (code) => {
    if (code === 0) {
      console.log(`Thumbnail created: ./storage/${videoId}-thumbnail.jpg`);
      res.writeHead(200, { "Content-Type": "application/json" });
      res.end(JSON.stringify({ message: "Thumbnail created", videoId }));
    } else {
      console.error("Worker failed with code:", code);
      res.writeHead(500, { "Content-Type": "application/json" });
      res.end(JSON.stringify({ error: "Failed to generate thumbnail" }));
    }
  });

  worker.on("error", (err) => {
    console.error("Worker error:", err);
    res.writeHead(500, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ error: "Worker thread error" }));
  });
}
module.exports = { processVideo };

const { Worker } = require("worker_threads");

function processVideo(obj, res, req) {
  console.log("path received at process video function",obj.inputPath);
  const worker = new Worker("../utils/FF.js", {
    workerData: {
      obj: obj,
    },
  });
  const videoId = obj.videoId;
  worker.on("exit", (code) => {
    if (code === 0) {
      console.log(`Thumbnail created: ./storage/${videoId}-thumbnail.jpg`);
      res.writeHead(200, { "Content-Type": "application/json" });
      res.end(
        JSON.stringify({ message: `${obj.type} operation completed`, videoId })
      );
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

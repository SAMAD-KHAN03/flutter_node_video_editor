const { Worker } = require("worker_threads");
const path = require("path");

function processVideo(job) {
  return new Promise((resolve, reject) => {
    const worker = new Worker(path.resolve(__dirname, "../utils/FF.js"), {
      workerData: job,
    });

    worker.on("message", (msg) => {
      console.log(`[Worker] ${msg}`);
    });

    worker.on("exit", (code) => {
      if (code === 0) {
        resolve();
      } else {
        reject(new Error(`Worker exited with code ${code}`));
      }
    });

    worker.on("error", (err) => {
      reject(err);
    });
  });
}

module.exports = { processVideo };
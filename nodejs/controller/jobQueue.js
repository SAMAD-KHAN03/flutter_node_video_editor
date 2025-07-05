const { processVideo } = require("./process");

class JobQueue {
  constructor() {
    this.jobs = [];
    this.isProcessing = false;
  }

  enqueue(job, res) {
    this.jobs.push(job);
    console.log(`Job queued: ${job.type} for videoId: ${job.videoId}`);
    this.processNext(res);
  }

  async processNext(res) {
    if (this.isProcessing || this.jobs.length === 0) return;

    const job = this.jobs.shift();
    this.isProcessing = true;

    try {
      await processVideo(job);
      console.log(`Job completed: ${job.type} for videoId: ${job.videoId}`);
      res.writeHead(200, { "Content-Type": "application/json" });
      res.end(JSON.stringify({ message: "donef" }));
    } catch (err) {
      console.error(`Job failed: ${job.videoId}`, err);
      res.writeHead(400, { "Content-Type": "application/json" });
      res.end({ message: "something went wrong retry" });
    } finally {
      this.isProcessing = false;
      this.processNext(res);
    }
  }
}

module.exports = new JobQueue();

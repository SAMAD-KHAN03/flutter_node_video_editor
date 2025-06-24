const { processVideo } = require("./process.js");

class JobQueue {
  constructor() {
    this.jobs = [];
    this.currentJob = null;
  }

  enqueue(job) {
    this.jobs.push(job);
    console.log(`enqued one more job curernt jobs remaining ${this.jobs.length}`);
    
    this.executeNext();
  }

  dequeue() {
    return this.jobs.shift();
  }

  executeNext() {
    if (this.currentJob) return;

    this.currentJob = this.dequeue();
    if (!this.currentJob) return;

    this.execute(this.currentJob);
  }

  async execute(job) {
    try {
      const { obj, res, req } = job;
      await processVideo(obj, res, req);
    } catch (error) {
      console.error("Job failed:", error);
    } finally {
      this.currentJob = null;
      console.log(
        `completed one more job now remaining jobs are ${this.jobs.length}`
      );
      this.executeNext();
    }
  }
}

module.exports = new JobQueue(); // Export singleton instance

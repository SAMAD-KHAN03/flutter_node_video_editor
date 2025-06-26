const cluster = require("node:cluster");
const os = require("node:os");

const numCpus = os.cpus().length;
if (cluster.isMaster) {
  for (let i = 0; i < numCpus; i++) {
    cluster.fork();
  }
  cluster.on("exit", (worker,code,signal) => {
     console.log(`Worker ${worker.process.pid} died. Forking a new worker...`);
    cluster.fork();
  });
} else {
  require("./index");
}

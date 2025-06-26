const jobQueue = require("../controller/jobQueue");

const audio = (req, res) => {
  let char = "";
  req.on("data", (chunk) => (char += chunk));
  req.on("end", () => {
    const { videoId, userId, mime, encoding } = JSON.parse(char);

    if (!videoId || !userId || !mime || !encoding) {
      res.writeHead(400, { "Content-Type": "application/json" });
      return res.end(JSON.stringify({ error: "Missing required fields" }));
    }

    const fileExt = mime.split("/")[1];
    const inputPath = `../storage/${videoId}.${fileExt}`;
    const outputPath = `../storage/${videoId}-audio.${encoding}`;

    const job = {
      inputPath,
      outputPath,
      videoId,
      userId,

      encoding,
      mime: fileExt,
      type: "audio",
      path: "audio",
    };

    jobQueue.enqueue(job, res);
  });
};

module.exports = { audio };

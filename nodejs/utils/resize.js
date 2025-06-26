const jobQueue = require("../controller/jobQueue");

const resize = (req, res) => {
  let char = "";
  req.on("data", (chunk) => (char += chunk));
  req.on("end", () => {
    const { videoId, userId, mime, height, width } = JSON.parse(char);

    if (!videoId || !userId || !mime || !height || !width) {
      res.writeHead(400, { "Content-Type": "application/json" });
      return res.end(JSON.stringify({ error: "Missing required fields" }));
    }

    const fileExt = mime.split("/")[1];
    const inputPath = `../storage/${videoId}.${fileExt}`;
    const outputPath = `../storage/${videoId}-resized-${height}x${width}.${fileExt}`;

    const job = {
      inputPath,
      outputPath,
      videoId,
      userId,
      height,
      width,

      mime: fileExt,
      type: "resize",
      path: "video",
    };

    jobQueue.enqueue(job,res);
  });
};

module.exports = { resize };

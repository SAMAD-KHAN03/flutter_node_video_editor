const multiparty = require("multiparty");
const jobQueue = require("../controller/jobQueue.js");

const resize = async (req, res) => {
  const form = new multiparty.Form();

  form.parse(req, async (err, fields) => {
    if (err) {
      res.writeHead(400, { "Content-Type": "application/json" });
      return res.end(JSON.stringify({ error: "Error parsing form data" }));
    }

    const videoId = fields.videoId?.[0];
    const userId = fields.userId?.[0];
    let mime = fields.mime?.[0];
    const height = parseInt(fields.height?.[0] || "0");
    const width = parseInt(fields.width?.[0] || "0");

    if (!videoId || !userId || !mime || !height || !width) {
      res.writeHead(400, { "Content-Type": "application/json" });
      return res.end(JSON.stringify({ error: "Missing required fields" }));
    }

    mime = mime.split("/")[1];
    const inputFilepath = `/Users/samad/Documents/MyFlutterProjects/flutter_node_video_editor/lib/backend/nodejs/storage/${videoId}.${mime}`;
    const outputFilepath = `/Users/samad/Documents/MyFlutterProjects/flutter_node_video_editor/lib/backend/nodejs/storage/${videoId}-resized-${height}x${width}.${mime}`;

    const obj = {
      inputPath: inputFilepath,
      outputPath: outputFilepath,
      videoId,
      userId,
      height,
      width,
      mime,
      type: "resize",
      path: "video",
    };

    jobQueue.enqueue({ obj, req, res }); // enqueue job
  });
};

module.exports = { resize };
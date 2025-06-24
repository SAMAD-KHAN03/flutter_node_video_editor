const fs = require("fs");
const multiparty = require("multiparty");
const jobQueue = require("../controller/jobQueue.js");

const upload = (req, res) => {
  const form = new multiparty.Form();

  form.parse(req, async (err, fields, files) => {
    if (err) {
      res.writeHead(400, { "Content-Type": "application/json" });
      return res.end(JSON.stringify({ error: "Error parsing form data" }));
    }

    const videoId = fields.videoId?.[0];
    const userId = fields.userId?.[0];
    const mime = fields.mime?.[0];
    const duration = parseFloat(fields.duration?.[0] || "0");
    const file = files.file?.[0];

    if (!videoId || !userId || !mime || !file) {
      res.writeHead(400, { "Content-Type": "application/json" });
      return res.end(JSON.stringify({ error: "Missing required fields" }));
    }

    const fileExt = mime;
    const videoPath = `/Users/samad/Documents/MyFlutterProjects/flutter_node_video_editor/lib/backend/nodejs/storage/${videoId}.${fileExt}`;
    const outputPath = `/Users/samad/Documents/MyFlutterProjects/flutter_node_video_editor/lib/backend/nodejs/storage/${videoId}-thumbnail.jpg`;

    fs.rename(file.path, videoPath, (err) => {
      if (err) {
        console.error("Error saving file:", err);
        res.writeHead(500, { "Content-Type": "application/json" });
        return res.end(JSON.stringify({ error: "Failed to save file" }));
      }

      const obj = {
        inputPath: videoPath,
        outputPath,
        videoId,
        mime: fileExt,
        userId,
        duration,
        type: "upload",
        path: "video",
      };

      jobQueue.enqueue({ obj, req, res }); // enqueue job
    });
  });
};

module.exports = { upload };
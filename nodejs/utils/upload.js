const fs = require("fs");
const multiparty = require("multiparty");
const jobQueue = require("../controller/jobQueue");

const upload = (req, res) => {
  const form = new multiparty.Form();

  form.parse(req, (err, fields, files) => {
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
    const inputPath = `../storage/${videoId}.${fileExt}`;
    const outputPath = `../storage/${videoId}-thumbnail.jpg`;

    fs.copyFile(file.path, inputPath, (err) => {
      if (err) {
        console.error("Error copying file:", err);
        res.writeHead(500, { "Content-Type": "application/json" });
        return res.end(JSON.stringify({ error: "Failed to save file" }));
      }

      // Optional: delete temp file after copy
      fs.unlink(file.path, () => {});

      const job = {
        inputPath,
        outputPath,
        videoId,
        mime: fileExt,
        userId,
        duration,
        type: "upload",
        path: "video",
      };
      jobQueue.enqueue(job, res);
    });
  });
};

module.exports = { upload };

const fs = require("fs");
const path = require("path");
const multiparty = require("multiparty");
const { processVideo } = require("../controller/process.js");
const { SaveUrlToDatabase } = require("../firebase.js");

let upload = (req, res) => {
  const form = new multiparty.Form();
  form.parse(req, (err, fields, files) => {
    if (err) {
      res.writeHead(400, { "Content-Type": "application/json" });
      res.end(JSON.stringify({ error: "Error parsing form data" }));
      return;
    }
    const videoId = fields.videoId ? fields.videoId[0] : null;
    const mime = fields.mime ? fields.mime[0] : null;
    const userId = fields.userId ? fields.userId[0] : null;
    const file = files.file ? files.file[0] : null;
    const duration = fields.duration ? parseFloat(fields.duration[0]) : null;
    if (!videoId || !mime || !userId || !file) {
      res.writeHead(400, { "Content-Type": "application/json" });
      res.end(JSON.stringify({ error: "Missing required fields" }));
      return;
    }
    // Store file in ./storage folder
    const videoPath = `/Users/samad/Documents/MyFlutterProjects/govideoeditor/lib/backend/nodejs/storage/${videoId}.${mime}`;
    const tempPath = file.path;
    fs.rename(tempPath, videoPath, async (err) => {
      if (err) {
        console.error("Error saving file:", err);
        res.writeHead(500, { "Content-Type": "application/json" });
        res.end(JSON.stringify({ error: "Failed to save file" }));
        return;
      }
      console.log(`File saved at ${videoPath}`);
      await SaveUrlToDatabase(videoPath, userId, videoId, "upload");
    });
    const obj = {
      videoId: videoId,
      mime: mime,
      userId: userId,
      duration: duration,
      type: "upload",
    };
    processVideo(obj, res, req);
  });
};
module.exports = { upload };

const fs = require("fs");
const path = require("path");
const multiparty = require("multiparty");
const { processVideo } = require("../controller/process.js");
const { SaveUrlToDatabase } = require("../firebase.js");

let upload = (req, res) => {
  const form = new multiparty.Form();
  form.parse(req, async (err, fields, files) => {
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
    // console.log("inside the upload function");

    // Store file in ./storage folder
    const videoPath = `/Users/samad/Documents/MyFlutterProjects/govideoeditor/lib/backend/nodejs/storage/${videoId}.${mime}`;
    const outputPath = `/Users/samad/Documents/MyFlutterProjects/govideoeditor/lib/backend/nodejs/storage/${videoId}-thumbnail.jpg`;
    const tempPath = file.path;
    fs.rename(tempPath, videoPath, async (err) => {
      if (err) {
        console.error("Error saving file:", err);
        res.writeHead(500, { "Content-Type": "application/json" });
        res.end(JSON.stringify({ error: "Failed to save file" }));
        return;
      }
      console.log(`File saved at ${videoPath}`);
    });
    const obj = {
      inputPath: videoPath,
      outputPath: outputPath,
      videoId: videoId,
      mime: mime,
      userId: userId,
      duration: duration,
      type: "upload",
    };
    try {
      processVideo(obj, res, req).then(async (message) => {
       // await SaveUrlToDatabase(obj);
       // fs.rmSync(videoPath);
      });
    } catch (error) {
      console.log("process video function rejected");
    }
  });
};
module.exports = { upload };

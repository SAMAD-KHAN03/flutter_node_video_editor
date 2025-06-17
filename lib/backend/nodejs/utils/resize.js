const multiparty = require("multiparty");
const { processVideo } = require("../controller/process.js");
const { download } = require("../firebase.js");
let resize = async (req, res) => {
  const form = new multiparty.Form();
  form.parse(req, async (err, fields) => {
    if (err) {
      res.writeHead(400, { "Content-Type": "application/json" });
      res.end(JSON.stringify({ error: "Error parsing form data" }));
      return;
    }
    const videoId = fields.videoId ? fields.videoId[0] : null;
    const userId = fields.userId ? fields.userId[0] : null;
    const height = fields.height ? parseInt(fields.height[0]) : null;
    const width = fields.height ? parseInt(fields.height[0]) : null;
    let mime = fields.height ? fields.mime[0] : null;
    mime = mime.split("/")[1];
    const inputFilepath = `/Users/samad/Documents/MyFlutterProjects/govideoeditor/lib/backend/nodejs/storage/${videoId}.${mime}`;
    const outputFilepath = `/Users/samad/Documents/MyFlutterProjects/govideoeditor/lib/backend/nodejs/storage/${videoId}-resized-${height}x${width}.${mime}`;

    if (!videoId || !mime || !userId) {
      res.writeHead(400, { "Content-Type": "application/json" });
      res.end(JSON.stringify({ error: "Missing required fields" }));
      return;
    }
    const obj = {
      inputPath: inputFilepath,
      outputPath: outputFilepath,
      videoId: videoId,
      userId: userId,
      height: height,
      width: width,
      mime: mime,
      type: "resize",
      path:"video"
    };
    try {
      // await download(obj);
      await processVideo(obj, res, req);
      await SaveUrlToDatabase(obj);
    } catch (error) {
      console.log("process video function rejected");
      res.writeHead(400,"Something went wrong");
    }
  });
};
module.exports = { resize };

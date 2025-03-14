const multiparty = require("multiparty");
const { processVideo } = require("../controller/process.js");
let resize = (req, res) => {
  const form = new multiparty.Form();
  form.parse(req, (err, fields, files) => {
    if (err) {
      res.writeHead(400, { "Content-Type": "application/json" });
      res.end(JSON.stringify({ error: "Error parsing form data" }));
      return;
    }
    const videoId = fields.videoId ? fields.videoId[0] : null;
    const userId = fields.userId ? fields.userId[0] : null;
    const height = fields.height ? parseInt(fields.height[0]) : null;
    const width = fields.height ? parseInt(fields.height[0]) : null;
    if (!videoId || !mime || !userId || !file) {
      res.writeHead(400, { "Content-Type": "application/json" });
      res.end(JSON.stringify({ error: "Missing required fields" }));
      return;
    }
    const obj = {
      videoId: videoId,
      userId: userId,
      height: height,
      width: width,
    };
    processVideo(obj, res, req);
  });
};

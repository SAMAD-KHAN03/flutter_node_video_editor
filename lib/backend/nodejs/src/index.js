const http = require("http");
const { upload } = require("../utils/upload");
const PORT = 3000;
const IP = "0.0.0.0";
const { resize } = require("../utils/resize");

const server = http.createServer((req, res) => {
  if (req.method === "POST" && req.url === "/upload") {
    upload(req, res);
  } else if (req.method == "POST" && req.url === "/resize") {
    resize(req, res);
  } else {
    res.writeHead(404, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ error: "Not Found" }));
  }
});
server.on("connection", (stream) => {
  console.log("some one came");
});
server.listen(PORT, IP, () => {
  console.log(`Server running at http://${IP}:${PORT}/`);
});

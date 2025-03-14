const http = require("http");
const { upload } = require("../utils/upload");
const PORT = 3000;
const IP = "127.0.0.1";

const server = http.createServer((req, res) => {
  if (req.method === "POST" && req.url === "/upload") {
    upload(req, res);
  } else if (req.method == "POST" && req.url === "/resize") {
    resize(req.res);
  } else {
    res.writeHead(404, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ error: "Not Found" }));
  }
});

server.listen(PORT, IP, () => {
  console.log(`Server running at http://${IP}:${PORT}/`);
});

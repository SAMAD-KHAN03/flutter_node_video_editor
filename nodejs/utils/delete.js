const fs = require("node:fs/promises");

async function deleteFile(req, res) {
  try {
    let data = "";
    req.on("data", (chunk) => {
      data += chunk;
    });

    req.on("end", async () => {
      console.log("Request data:", data);
      const { videoId, mime } = JSON.parse(data);
      const fileExtension = mime.split("/")[1];
      const filePath = `../storage/${videoId}.${fileExtension}`;

      try {
        await fs.unlink(filePath);
        console.log("Deleted file:", filePath);
        res.writeHead(200, { "Content-Type": "application/json" });
        res.end(JSON.stringify({ status: "success", message: "File deleted" }));
      } catch (err) {
        console.error("Error deleting file:", err);
        res.writeHead(500, { "Content-Type": "application/json" });
        res.end(
          JSON.stringify({
            status: "error",
            message: "File not found or cannot delete",
          })
        );
      }
    });
  } catch (err) {
    console.error("Unexpected error:", err);
    res.writeHead(500, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ status: "error", message: "Server error" }));
  }
}

module.exports = { deleteFile };

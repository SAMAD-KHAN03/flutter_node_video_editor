const admin = require("firebase-admin");
const path = require("path");
const fs = require("fs");
const { getStorage } = require("firebase-admin/storage");

// Initialize Firebase Admin SDK
const serviceAccount = require("./go-video-editor-7bf75-firebase-adminsdk-fbsvc-8932579eaa.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: "gs://go-video-editor-7bf75.firebasestorage.app", // Firebase Storage bucket
});

const db = admin.firestore();
const bucket = getStorage().bucket();
const downloadbucket = admin.storage().bucket();

async function UploadToFirebase(obj) {
  try {
    let videopath = obj.outputPath;
    if (obj.type == "upload") videopath = obj.inputPath;
    if (!fs.existsSync(videopath)) {
      throw new Error(`File not found: ${videopath}`);
    }
    ///Users/samad/Documents/MyFlutterProjects/flutter_node_video_editor/lib/backend/nodejs/storage/4d4ea94fb7187c753bcaa3ecb8307ffe061619d03fbaf89a790e41ec1dcfaa38-resized-49x49.mp4
    // Extract file extension (e.g., "mp4", "jpg")

    const fileExtension = path.extname(videopath).substring(1).toLowerCase();

    // Determine content type and appropriate bucket
    let contentType = "application/octet-stream"; // Default MIME type
    // console.log("before using base name videopath", videopath);
    let filename = path.basename(videopath);

    // console.log("the file name to upload on firebase is ", filename);
    let storageFolder = "misc"; // Default folder

    if (
      [
        "mp4",
        "webm",
        "avi",
        "mkv",
        "mov",
        "wmv",
        "flv",
        "mpeg",
        "3gp",
        "ogg",
      ].includes(fileExtension)
    ) {
      contentType = `video/${fileExtension}`;
      storageFolder = "video";
    } else if (
      [
        "jpeg",
        "jpg",
        "png",
        "gif",
        "bmp",
        "webp",
        "svg",
        "tiff",
        "ico",
      ].includes(fileExtension)
    ) {
      contentType = `image/${fileExtension}`;
      storageFolder = "image";
    } else if (
      ["mp3", "wav", "ogg", "aac", "flac", "m4a", "wma"].includes(fileExtension)
    ) {
      contentType = `audio/${fileExtension}`;
      storageFolder = "audio";
    }

    // Construct the correct Firebase Storage path

    const firebaseFilePath = `${storageFolder}/${filename}`;

    // Upload file to Firebase Storage
    const file = bucket.file(firebaseFilePath);
    await bucket.upload(videopath, {
      destination: firebaseFilePath,
      metadata: {
        contentType: contentType,
      },
    });

    // Make the file publicly accessible (optional)
    await file.makePublic();

    // Generate download URL
    const downloadURL = `https://firebasestorage.googleapis.com/v0/b/${
      bucket.name
    }/o/${encodeURIComponent(firebaseFilePath)}?alt=media`;

    console.log("File uploaded successfully:", downloadURL);
    return { downloadURL, storageFolder };
  } catch (error) {
    console.error("Error uploading file:", error);
    throw error;
  }
}

async function SaveUrlToDatabase(object) {
  try {
    // const videopath = object.videopath;
    const { type, userId, videoId } = object;
    const { downloadURL, storageFolder } = await UploadToFirebase(object);
    console.log(
      "the file path received by save database function",
      object.outputPath
    );
    const obj = {
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    };
    switch (type) {
      case "upload":
        obj["parentvideo"] = downloadURL;
        obj["firebaseobjectname"] = "parentvideo";
        break;
      case "thumbnail":
        obj["thumbnail"] = downloadURL;
        obj["firebaseobjectname"] = "thumbnail";
        break;
      case "resize":
        obj[`resize-${object.height}-${object.width}`] = downloadURL;
        obj["firebaseobjectname"] = `resize-${object.height}-${object.width}`;
        break;
      case "audio":
        obj[`audio-${object.encoding}`] = downloadURL;
        obj[`firebaseobjectname`] = `audio-${object.encoding}`;
        break;
      default:
        break;
    }

    await db
      .collection("users")
      .doc(userId)
      .collection(videoId)
      .doc(obj.firebaseobjectname)
      .set(obj);

    console.log(
      `File URL saved in Firestore under users/${userId}/videos/${videoId}`
    );
    return downloadURL;
  } catch (error) {
    console.error("Error saving file URL:", error);
    throw error;
  }
}
async function download(obj) {
  const videoId = obj.videoId;
  const mime = obj.mime.split("/")[1];
  const path = obj.path;
  const downloadbucket = admin.storage().bucket(type);
  const file = downloadbucket.file(`${path}/${videoId}.${mime}`);
  try {
    await file.download({
      destination:
        "/Users/samad/Documents/MyFlutterProjects/flutter_node_video_editor/lib/backend/nodejs/storage",
    });
    console.log("file downloaded succesfully");
  } catch (error) {
    console.log("error in downloading file", error);
  }
}

module.exports = { SaveUrlToDatabase, download };

const admin = require("firebase-admin");
const path = require("path");
const fs = require("fs");
const { getStorage } = require("firebase-admin/storage");

// Initialize Firebase Admin SDK
const serviceAccount = require("/Users/samad/Documents/MyFlutterProjects/govideoeditor/lib/backend/govideoeditor-a1523-firebase-adminsdk-fbsvc-dc3724ec9c.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: "gs://govideoeditor-a1523.firebasestorage.app", // Firebase Storage bucket
});

const db = admin.firestore();
const bucket = getStorage().bucket();

async function UploadToFirebase(localFilePath, userId, videoId) {
  try {
    if (!fs.existsSync(localFilePath)) {
      throw new Error(`File not found: ${localFilePath}`);
    }

    // Extract file extension (e.g., "mp4", "jpg")
    const fileExtension = path
      .extname(localFilePath)
      .substring(1)
      .toLowerCase();

    // Determine content type and appropriate bucket
    let contentType = "application/octet-stream"; // Default MIME type
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
    const firebaseFilePath = `${storageFolder}/${videoId}.${fileExtension}`;

    // Upload file to Firebase Storage
    const file = bucket.file(firebaseFilePath);
    await bucket.upload(localFilePath, {
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

async function SaveUrlToDatabase(localFilePath, userId, videoId, type) {
  try {
    const { downloadURL, storageFolder } = await UploadToFirebase(
      localFilePath,
      userId,
      videoId
    );
    const obj = {
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    };
    switch (type) {
      case "upload":
        obj["parentVideo"] = downloadURL;
        break;
      case "thumbnail":
        obj["thumnail"] = downloadURL;
        break;
      case "thumbnail":
        obj["thumnail"] = downloadURL;
        break;
      case "resize":
        obj["resize"] = downloadURL;
        break;
      default:
        break;
    }

    await db
      .collection("users")
      .doc(userId)
      .collection(videoId)
      .doc(storageFolder)
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

module.exports = { SaveUrlToDatabase };

//this file is just for testing the download functionality of storage not for production....
const admin = require("firebase-admin");
const path = require("path");
const fs = require("fs");
const { getStorage } = require("firebase-admin/storage");

// Initialize Firebase Admin SDK
const serviceAccount = require("/Users/samad/Documents/MyFlutterProjects/govideoeditor/lib/backend/go-video-editor-7bf75-firebase-adminsdk-fbsvc-8932579eaa.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: "gs://go-video-editor-7bf75.firebasestorage.app", // Firebase Storage bucket
});

const db = admin.firestore();
const bucket = getStorage().bucket();
const downloadbucket = admin.storage().bucket();

async function download(obj) {
  const videoId = obj.videoId;
  const mime = obj.mime.split("/")[1];
  const path = obj.path;
  const downloadbucket = admin.storage().bucket(path);
  const file = downloadbucket.file(`${path}/${videoId}.${mime}`);
  try {
    await file.download({
      destination:
        "/Users/samad/Documents/MyFlutterProjects/govideoeditor/lib/backend/nodejs/storage",
    });
    console.log("file downloaded succesfully");
  } catch (error) {
    console.log("error in downloading file", error);
  }
}
const obj = {
  videoId: "6f4956c1d13bedb29b735434b606331bf6e6217ff16f057752348a89dca9ea7b",
  mime: "mp4",
  path: "videos",
};
download(obj);

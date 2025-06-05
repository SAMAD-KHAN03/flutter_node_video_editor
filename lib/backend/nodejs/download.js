//this file is just for testing the download functionality of storage not for production....
const admin = require("firebase-admin");
const path = require("path");
const fs = require("fs");
const { getStorage } = require("firebase-admin/storage");

// Initialize Firebase Admin SDK
const serviceAccount = require("/Users/samad/Documents/MyFlutterProjects/govideoeditor/lib/backend/govideoeditor-a1523-firebase-adminsdk-fbsvc-eb7b66dd69.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: "gs://govideoeditor-a1523.firebasestorage.app", // Firebase Storage bucket
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
  videoId: "4d4ea94fb7187c753bcaa3ecb8307ffe061619d03fbaf89a790e41ec1dcfaa38",
  mime: "mp4",
  path: "videos",
};
download(obj);

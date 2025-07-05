//this file is just for testing the download functionality of storage not for production....
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

async function fetchSubcollectionsAndDocs(req, res) {
  let userId = req.headers["userid"];
  console.log("user id received in download function is ", userId);

  const userDocRef = db.collection("users").doc(userId);
  try {
    const subcollections = await userDocRef.listCollections();
    const data = [];
    const datatosend = [];
    for (const subcol of subcollections) {
      const snapshot = await subcol.get();

      const docs = snapshot.docs.map((doc) => ({
        subcollection: subcol.id,
        docId: doc.id,
        content: doc.data(),
      }));
      // console.log(docs);

      data.push(docs);
    }

    data.forEach((element) => {
      console.log(element);
    });
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify(data)); // Send JSON string
  } catch (error) {
    console.error("Error fetching subcollections:", error);
    res.writeHead(500, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ error: "Failed to fetch data" }));
    console.log(error);
  }
}
// fetchSubcollectionsAndDocs();
module.exports = { fetchSubcollectionsAndDocs };

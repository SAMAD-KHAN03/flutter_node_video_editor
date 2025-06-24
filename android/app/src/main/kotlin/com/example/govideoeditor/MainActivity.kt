package com.example.govideoeditor

import io.flutter.embedding.android.FlutterActivity
import android.content.ContentValues
import android.content.Context
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.io.OutputStream
import android.webkit.MimeTypeMap
import java.net.URLConnection


class MainActivity: FlutterActivity(){
    private val CHANNEL = "com.example.govideoeditor/download"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "saveToDownloads") {
                val filePath = call.argument<String>("filePath")
                val fileName = call.argument<String>("fileName")
                if (filePath != null && fileName != null) {
                    try {
                        saveFileToDownloads(this, filePath, fileName)
                        result.success("File saved to Downloads")
                    } catch (e: Exception) {
                        result.error("SAVE_ERROR", "Failed to save file: ${e.message}", null)
                    }
                } else {
                    result.error("ARG_ERROR", "Missing arguments", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

private fun saveFileToDownloads(context: Context, filePath: String, fileName: String) {
    val inputFile = File(filePath)
    if (!inputFile.exists()) throw Exception("Source file does not exist")

    // Dynamically guess MIME type from file extension
    val mimeType = URLConnection.guessContentTypeFromName(fileName) ?: "application/octet-stream"

    val values = ContentValues().apply {
        put(MediaStore.Downloads.DISPLAY_NAME, fileName)
        put(MediaStore.Downloads.MIME_TYPE, mimeType)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            put(MediaStore.Downloads.IS_PENDING, 1)
        }
    }

    val resolver = context.contentResolver
    val collection = MediaStore.Downloads.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
    val uri = resolver.insert(collection, values)
        ?: throw Exception("Failed to create new MediaStore record")

    resolver.openOutputStream(uri)?.use { outStream ->
        FileInputStream(inputFile).use { inputStream ->
            inputStream.copyTo(outStream)
        }
    }

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
        values.clear()
        values.put(MediaStore.Downloads.IS_PENDING, 0)
        resolver.update(uri, values, null, null)
    }
}
}

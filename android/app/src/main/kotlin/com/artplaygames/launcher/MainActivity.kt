package com.artplaygames.launcher

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity: FlutterActivity() {
    private val CHANNEL = "launcher"

    init {
        System.loadLibrary("GTASA")
        System.loadLibrary("samp")
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "connectServer") {
                    val ip = call.argument<String>("ip")
                    val port = call.argument<Int>("port")

                    val file = File(getExternalFilesDir(null), "samp.cfg")
                    file.writeText("server=$ip:$port")

                    try {
                        val intent = packageManager.getLaunchIntentForPackage("com.rockstargames.gtasa")
                        if (intent != null) {
                            startActivity(intent)
                        }
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }

                    result.success("ok")
                } else {
                    result.notImplemented()
                }
            }
    }
}

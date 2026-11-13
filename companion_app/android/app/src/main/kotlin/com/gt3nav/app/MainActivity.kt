package com.gt3nav.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var wearEnginePlugin: WearEnginePlugin? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        wearEnginePlugin = WearEnginePlugin(this, flutterEngine.dartExecutor.binaryMessenger)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        wearEnginePlugin?.cleanup()
        wearEnginePlugin = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}

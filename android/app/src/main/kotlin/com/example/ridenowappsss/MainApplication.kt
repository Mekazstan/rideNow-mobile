package com.example.ridenowappsss

import android.app.Application
import android.util.Log

class MainApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        Log.d("MainApplication", "✅ Application initialized")
        // Note: Smile ID initialization is handled by the Flutter smile_id package
        // No native initialization is needed here
    }
}

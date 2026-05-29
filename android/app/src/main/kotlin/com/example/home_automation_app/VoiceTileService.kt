package com.example.home_automation_app

import android.content.Intent
import android.service.quicksettings.TileService

class VoiceTileService : TileService() {
    override fun onClick() {
        super.onClick()
        
        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("launch_voice", true)
        }
        
        try {
            startActivityAndCollapse(intent)
        } catch (e: Exception) {
            try {
                startActivity(intent)
            } catch (ex: Exception) {
                ex.printStackTrace()
            }
        }
    }
}

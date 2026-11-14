package com.example.love_ring

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.chemaaguiler.homewidget.HomeWidgetBackgroundIntent
import es.chemaaguiler.homewidget.HomeWidgetProvider

class LoveRingWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.love_ring_widget).apply {
                // Partner Name text
                val partnerName = widgetData.getString("partner_name", "LoveRing 💕")
                setTextViewText(R.id.widget_partner_name, partnerName)

                // Status Text
                val statusText = widgetData.getString("widget_status", "Tap to Ping 💗")
                setTextViewText(R.id.widget_status_text, statusText)

                // Pending Intent for background click execution
                val pendingIntent = HomeWidgetBackgroundIntent.getBroadcast(
                    context,
                    Uri.parse("loveRingWidget://sendPing")
                )
                setOnClickPendingIntent(R.id.widget_heart_btn, pendingIntent)
                setOnClickPendingIntent(R.id.widget_container, pendingIntent)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}

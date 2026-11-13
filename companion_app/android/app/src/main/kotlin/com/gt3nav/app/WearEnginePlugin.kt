package com.gt3nav.app

import android.content.Context
import android.os.Handler
import android.os.Looper
import com.huawei.hmf.tasks.OnFailureListener
import com.huawei.hmf.tasks.OnSuccessListener
import com.huawei.wearengine.HiWear
import com.huawei.wearengine.device.Device
import com.huawei.wearengine.device.DeviceClient
import com.huawei.wearengine.p2p.Message
import com.huawei.wearengine.p2p.P2pClient
import com.huawei.wearengine.p2p.SendCallback
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.nio.charset.StandardCharsets

/**
 * WearEnginePlugin — Cầu nối giữa Flutter và Huawei Wear Engine SDK trên Android
 */
class WearEnginePlugin(private val context: Context, messenger: BinaryMessenger) :
    MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    companion object {
        const val METHOD_CHANNEL = "com.gt3nav/wear_engine"
        const val EVENT_CHANNEL = "com.gt3nav/wear_engine_events"
        const val WATCH_BUNDLE_NAME = "com.navgt3se.watchapp"
    }

    private val methodChannel: MethodChannel = MethodChannel(messenger, METHOD_CHANNEL)
    private val eventChannel: EventChannel = EventChannel(messenger, EVENT_CHANNEL)
    private var eventSink: EventChannel.EventSink? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    private val deviceClient: DeviceClient = HiWear.getDeviceClient(context)
    private val p2pClient: P2pClient = HiWear.getP2pClient(context)

    private var connectedDevice: Device? = null

    init {
        methodChannel.setMethodCallHandler(this)
        eventChannel.setStreamHandler(this)
        p2pClient.setPeerPkgName(WATCH_BUNDLE_NAME)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "connect" -> connectToWatch(result)
            "disconnect" -> disconnectWatch(result)
            "sendNavUpdate" -> {
                val data = call.argument<String>("data")
                if (data != null) {
                    sendDataToWatch(data, result)
                } else {
                    result.error("INVALID_ARG", "Dữ liệu trống", null)
                }
            }
            "getConnectionStatus" -> {
                if (connectedDevice != null && connectedDevice!!.isConnected) {
                    result.success("connected")
                } else {
                    result.success("disconnected")
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun connectToWatch(result: MethodChannel.Result) {
        deviceClient.bondedDevices
            .addOnSuccessListener { devices ->
                if (devices != null && devices.isNotEmpty()) {
                    // Chọn đồng hồ GT3 SE đã ghép đôi
                    val targetDevice = devices[0]
                    connectedDevice = targetDevice
                    notifyStatus("connected", targetDevice.name)
                    result.success(true)
                } else {
                    notifyStatus("disconnected", null)
                    result.success(false)
                }
            }
            .addOnFailureListener { e ->
                notifyStatus("error", null)
                result.error("CONNECT_FAILED", "Không thể tìm thấy thiết bị: ${e.message}", null)
            }
    }

    private fun disconnectWatch(result: MethodChannel.Result) {
        connectedDevice = null
        notifyStatus("disconnected", null)
        result.success(true)
    }

    private fun sendDataToWatch(jsonString: String, result: MethodChannel.Result) {
        val device = connectedDevice
        if (device == null) {
            result.error("NO_DEVICE", "Chưa kết nối đồng hồ", null)
            return
        }

        val messageBuilder = Message.Builder()
        messageBuilder.setPayload(jsonString.toByteArray(StandardCharsets.UTF_8))
        val message = messageBuilder.build()

        p2pClient.send(device, message, object : SendCallback {
            override fun onSendResult(resultCode: Int) {
                mainHandler.post {
                    if (resultCode == 0) {
                        result.success(true)
                    } else {
                        result.success(false)
                    }
                }
            }

            override fun onSendProgress(progress: Long) {
                // Progress tracking if needed
            }
        })
    }

    private fun notifyStatus(status: String, deviceName: String?) {
        mainHandler.post {
            val event = HashMap<String, Any?>()
            event["status"] = status
            event["deviceName"] = deviceName
            eventSink?.success(event)
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    fun cleanup() {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }
}

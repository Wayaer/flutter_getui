package flutter.getui

import android.content.Context
import android.os.Handler
import android.os.Looper
import com.igexin.sdk.GTIntentService
import com.igexin.sdk.PushManager
import com.igexin.sdk.Tag
import com.igexin.sdk.message.GTCmdMessage
import com.igexin.sdk.message.GTNotificationMessage
import com.igexin.sdk.message.GTTransmitMessage
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel
import java.util.HashMap


class GeTuiPlugin : FlutterPlugin {

    companion object {
        lateinit var channel: MethodChannel
    }

    override fun onAttachedToEngine(plugin: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(plugin.binaryMessenger, "get_tui")
        val context = plugin.applicationContext
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "initPush" -> {
                    PushManager.getInstance().initialize(context)
                }
                "getClientId" -> result.success(PushManager.getInstance().getClientid(context))
                "startPush" -> PushManager.getInstance().turnOnPush(context)
                "stopPush" -> PushManager.getInstance().turnOffPush(context)
                "bindAlias" -> PushManager.getInstance().bindAlias(context, call.argument<Any>("alias").toString())
                "unbindAlias" ->
                    PushManager.getInstance().unBindAlias(context, call
                            .argument<Any>("alias").toString(), false)
                "setTag" -> {
                    val tags = call.arguments as List<*>
                    if (tags.isNotEmpty()) {
                        val tagArray = arrayOfNulls<Tag>(tags.size)
                        for (i in tags.indices) {
                            val tag = Tag()
                            tag.name = tags[i] as String?
                            tagArray[i] = tag
                        }
                        PushManager.getInstance().setTag(context, tagArray, "setTag")
                    }
                }
                else -> result.notImplemented()
            }
        }

    }


    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }


    class IntentService : GTIntentService() {

        private val handle = Handler(Looper.getMainLooper())

        override fun onReceiveServicePid(context: Context, pid: Int) {

        }

        // 接收 cid
        override fun onReceiveClientId(context: Context, clientid: String) {
            handle.post {
                channel.invokeMethod("onReceiveClientId", clientid)
            }
        }

        // 处理透传消息
        override fun onReceiveMessageData(context: Context, msg: GTTransmitMessage) {

            val payload: MutableMap<String?, Any?> = HashMap()
            payload["messageId"] = msg.messageId
            payload["payload"] = String(msg.payload)
            payload["payloadId"] = msg.payloadId
            payload["taskId"] = msg.taskId
            handle.post { channel.invokeMethod("onReceiveMessageData", payload) }
        }

        // cid 离线上线通知
        override fun onReceiveOnlineState(context: Context, bool: Boolean) {
            handle.post {
                channel.invokeMethod("onReceiveOnlineState", bool)
            }
        }

        // 各种事件处理回执
        override fun onReceiveCommandResult(context: Context, gtCmdMessage: GTCmdMessage) {

        }

        // 通知到达，只有个推通道下发的通知会回调此方法
        override fun onNotificationMessageArrived(context: Context, message: GTNotificationMessage) {
            val notification: MutableMap<String?, Any?> = HashMap()
            notification["messageId"] = message.messageId
            notification["taskId"] = message.taskId
            notification["title"] = message.title
            notification["content"] = message.content
            handle.post {
                channel.invokeMethod("onNotificationMessageArrived",
                        notification)
            }
        }

        // 通知点击，只有个推通道下发的通知会回调此方法
        override fun onNotificationMessageClicked(context: Context, message: GTNotificationMessage) {
            val notification: MutableMap<String?, Any?> = HashMap()
            notification["messageId"] = message.messageId
            notification["taskId"] = message.taskId
            notification["title"] = message.title
            notification["content"] = message.content
            handle.post {
                channel.invokeMethod("onNotificationMessageClicked",
                        notification)
            }
        }

    }
}
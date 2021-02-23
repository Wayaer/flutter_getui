package flutter.getui

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.igexin.sdk.GTIntentService
import com.igexin.sdk.message.GTCmdMessage
import com.igexin.sdk.message.GTNotificationMessage
import com.igexin.sdk.message.GTTransmitMessage
import flutter.getui.GeTuiPlugin.Companion.channel
import java.util.*

class IntentService : GTIntentService() {

    private val handle = Handler(Looper.getMainLooper())

    override fun onReceiveServicePid(context: Context, pid: Int) {
        Log.d(TAG, "onReceiveServicePid -> $pid")
    }


    override fun onReceiveClientId(context: Context, clientid: String) {
        handle.post {
            channel.invokeMethod("onReceiveClientId", clientid)
        }
    }

    override fun onReceiveMessageData(context: Context, msg: GTTransmitMessage) {

        Log.d(TAG, """
     onReceiveMessageData -> appId = ${msg.appid}
     taskId = ${msg.taskId}
     messageId = ${msg.messageId}
     pkg = ${msg.pkgName}
     cid = ${msg.clientId}
     payload:${String(msg.payload)}
     """.trimIndent())
        val payload: MutableMap<String?, Any?> = HashMap()
        payload["messageId"] = msg.messageId
        payload["payload"] = String(msg.payload)
        payload["payloadId"] = msg.payloadId
        payload["taskId"] = msg.taskId
        handle.post { channel.invokeMethod("onReceiveMessageData", payload) }
    }

    override fun onReceiveOnlineState(context: Context, bool: Boolean) {
        handle.post {
            channel.invokeMethod("onReceiveOnlineState", bool)
        }
    }

    override fun onReceiveCommandResult(context: Context, gtCmdMessage: GTCmdMessage) {

    }

    override fun onNotificationMessageArrived(context: Context, message: GTNotificationMessage) {
        Log.d(TAG, """
     onNotificationMessageArrived -> appId = ${message.appid}
     taskId = ${message.taskId}
     messageId = ${message.messageId}
     pkg = ${message.pkgName}
     cid = ${message.clientId}
     title = ${message.title}
     content = ${message.content}
     """.trimIndent())
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

    override fun onNotificationMessageClicked(context: Context, message: GTNotificationMessage) {
        Log.d(TAG, """
     onNotificationMessageClicked -> appId = ${message.appid}
     taskId = ${message.taskId}
     messageId = ${message.messageId}
     pkg = ${message.pkgName}
     cid = ${message.clientId}
     title = ${message.title}
     content = ${message.content}
     """.trimIndent())
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
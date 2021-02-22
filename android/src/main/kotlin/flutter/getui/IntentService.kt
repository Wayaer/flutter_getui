package flutter.getui

import android.content.Context
import android.util.Log
import com.igexin.sdk.GTIntentService
import com.igexin.sdk.message.GTCmdMessage
import com.igexin.sdk.message.GTNotificationMessage
import com.igexin.sdk.message.GTTransmitMessage
import flutter.getui.GeTuiPlugin.Companion.transmitMessageReceive
import java.util.*

class IntentService : GTIntentService() {
    override fun onReceiveServicePid(context: Context, pid: Int) {
        Log.d(TAG, "onReceiveServicePid -> $pid")
    }

    override fun onReceiveClientId(context: Context, clientid: String) {
        Log.e(TAG, "onReceiveClientId -> clientid = $clientid")
        transmitMessageReceive(clientid, "onReceiveClientId")
    }

    override fun onReceiveMessageData(context: Context, msg: GTTransmitMessage) {
        Log.d(TAG, """
     onReceiveMessageData -> appid = ${msg.appid}
     taskid = ${msg.taskId}
     messageid = ${msg.messageId}
     pkg = ${msg.pkgName}
     cid = ${msg.clientId}
     payload:${String(msg.payload)}
     """.trimIndent())
        val payload: MutableMap<String?, Any?> = HashMap()
        payload["messageId"] = msg.messageId
        payload["payload"] = String(msg.payload)
        payload["payloadId"] = msg.payloadId
        payload["taskId"] = msg.taskId
        transmitMessageReceive(payload, "onReceiveMessageData")
    }

    override fun onReceiveOnlineState(context: Context, b: Boolean) {
        transmitMessageReceive(b.toString(), "onReceiveOnlineState")
    }

    override fun onReceiveCommandResult(context: Context, gtCmdMessage: GTCmdMessage) {
        transmitMessageReceive(gtCmdMessage.toString(), "onReceiveCommandResult")
    }

    override fun onNotificationMessageArrived(context: Context, message: GTNotificationMessage) {
        Log.d(TAG, """
     onNotificationMessageArrived -> appid = ${message.appid}
     taskid = ${message.taskId}
     messageid = ${message.messageId}
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
        transmitMessageReceive(notification, "onNotificationMessageArrived")
    }

    override fun onNotificationMessageClicked(context: Context, message: GTNotificationMessage) {
        Log.d(TAG, """
     onNotificationMessageClicked -> appid = ${message.appid}
     taskid = ${message.taskId}
     messageid = ${message.messageId}
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
        transmitMessageReceive(notification, "onNotificationMessageClicked")
    }
}
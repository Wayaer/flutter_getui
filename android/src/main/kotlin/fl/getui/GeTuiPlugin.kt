package fl.getui

import android.content.Context
import android.os.Handler
import android.os.Looper
import com.igexin.sdk.*
import com.igexin.sdk.message.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel


class GeTuiPlugin : FlutterPlugin {

    companion object {
        lateinit var channel: MethodChannel
    }

    override fun onAttachedToEngine(plugin: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(plugin.binaryMessenger, "ge_tui")
        val context = plugin.applicationContext
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "initPush" -> {
                    PushManager.getInstance().initialize(context)
                    result.success(true)
                }
                "checkManifest" -> {
                    PushManager.getInstance().checkManifest(context)
                    result.success(true)
                }
                "getClientId" -> result.success(
                    PushManager.getInstance().getClientid(context)
                )
                "startPush" -> {
                    PushManager.getInstance().turnOnPush(context)
                    result.success(true)
                }
                "stopPush" -> {
                    PushManager.getInstance().turnOffPush(context)
                    result.success(true)
                }
                "isPushTurnedOn" -> result.success(
                    result.success(PushManager.getInstance().isPushTurnedOn(context))
                )
                "bindAlias" -> {
                    val status = PushManager.getInstance().bindAlias(
                        context,
                        call.argument("alias"), call.argument("sn")
                    )
                    result.success(status)
                }
                "unbindAlias" -> {
                    var isSelf = call.argument<Boolean>("isSelf")
                    val sn = call.argument<String>("sn")
                    if (isSelf == null) isSelf = false
                    val status = PushManager.getInstance()
                        .unBindAlias(context, call.argument("alias"), isSelf, sn)
                    result.success(status)
                }
                "setTag" -> {
                    val tags = call.argument<List<String>>("tags")
                    val sn = call.argument<String>("sn")
                    if (tags != null && tags.isNotEmpty()) {
                        val tagArray = arrayOfNulls<Tag>(tags.size)
                        for (i in tags.indices) {
                            val tag = Tag()
                            tag.name = tags[i]
                            tagArray[i] = tag
                        }
                        val status = PushManager.getInstance()
                            .setTag(context, tagArray, sn) == 0
                        result.success(status)
                    } else {
                        result.success(false)
                    }
                }
                "setBadge" -> {
                    val num = call.argument<Int>("badge")!!
                    val hwStatus = PushManager.getInstance().setHwBadgeNum(context, num)
                    val statusVIVO = PushManager.getInstance().setVivoAppBadgeNum(context, num)
                    val statusOPPO = PushManager.getInstance().setOPPOBadgeNum(context, num)
                    result.success(hwStatus || statusVIVO || statusOPPO)
                }
                "checkNotificationsEnabled" -> {
                    result.success(PushManager.getInstance().areNotificationsEnabled(context))
                }
                "openNotification" -> {

                    PushManager.getInstance().openNotification(context)
                    result.success(true)
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
        }

        // 处理透传消息
        override fun onReceiveMessageData(
            context: Context,
            msg: GTTransmitMessage
        ) {
            val data: MutableMap<String?, Any?> = HashMap()
            data["messageId"] = msg.messageId
            data["payload"] = String(msg.payload)
            data["payloadId"] = msg.payloadId
            data["taskId"] = msg.taskId
            handle.post { channel.invokeMethod("onReceiveMessageData", data) }
        }

        // cid 离线上线通知
        override fun onReceiveOnlineState(context: Context, state: Boolean) {
            handle.post {
                channel.invokeMethod("onReceiveOnlineState", state)
            }
        }

        // 各种事件处理回执
        override fun onReceiveCommandResult(
            context: Context,
            message: GTCmdMessage
        ) {
            val data: MutableMap<String?, Any?> = HashMap()
            when (message.action) {
                PushConsts.SET_TAG_RESULT -> {
                    data["sn"] = (message as SetTagCmdMessage).sn
                    data["code"] = message.code
                    data["isSuccess"] = "0" == message.code
                    handle.post {
                        channel.invokeMethod("onSetTag", data)
                    }
                }
                PushConsts.BIND_ALIAS_RESULT -> {
                    data["sn"] = (message as BindAliasCmdMessage).sn
                    data["code"] = message.code
                    data["isSuccess"] = "0" == message.code
                    handle.post {
                        channel.invokeMethod("onBindAlias", data)
                    }
                }
                PushConsts.UNBIND_ALIAS_RESULT -> {
                    data["sn"] = (message as UnBindAliasCmdMessage).sn
                    data["code"] = message.code
                    data["isSuccess"] = "0" == message.code
                    handle.post {
                        channel.invokeMethod("onUnBindAlias", data)
                    }
                }
            }
        }

        // 通知到达，只有个推通道下发的通知会回调此方法
        override fun onNotificationMessageArrived(
            context: Context,
            message: GTNotificationMessage
        ) {
            val data: MutableMap<String?, Any?> = HashMap()
            data["messageId"] = message.messageId
            data["taskId"] = message.taskId
            data["title"] = message.title
            data["content"] = message.content
            handle.post {
                channel.invokeMethod("onNotificationMessageArrived", data)
            }
        }

        // 通知点击，只有个推通道下发的通知会回调此方法
        override fun onNotificationMessageClicked(
            context: Context,
            message: GTNotificationMessage
        ) {
            val data: MutableMap<String?, Any?> = HashMap()
            data["messageId"] = message.messageId
            data["taskId"] = message.taskId
            data["title"] = message.title
            data["content"] = message.content
            handle.post {
                channel.invokeMethod("onNotificationMessageClicked", data)
            }
        }

        //// 获取厂商 Token
        override fun onReceiveDeviceToken(context: Context?, token: String?) {
            super.onReceiveDeviceToken(context, token)
            handle.post {
                channel.invokeMethod("onReceiveDeviceToken", token)
            }
        }

    }

    class GTPushService : PushService()
}
package flutter.getui

import android.content.Context
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.Message
import android.util.Log
import com.igexin.sdk.PushManager
import com.igexin.sdk.Tag
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import java.util.*

class GeTuiPlugin : FlutterPlugin, MethodCallHandler {
    internal enum class MessageType {
        Default, onReceiveMessageData, onNotificationMessageArrived, onNotificationMessageClicked
    }

    internal enum class StateType {
        Default, onReceiveClientId, onReceiveOnlineState
    }

    private var context: Context? = null
    private lateinit var channel: MethodChannel
    override fun onAttachedToEngine(plugin: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(plugin.binaryMessenger, "UMeng")
        channel.setMethodCallHandler(this)
        context = plugin.applicationContext
    }


    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    val callbackMap: Map<Int, MethodChannel.Result>

    init {
        callbackMap = HashMap()
        instance = this
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getPlatformVersion" -> result.success("Android " + Build.VERSION.RELEASE)
            "initGetuiPush" -> initGtSdk()
            "getClientId" -> result.success(clientId())
            "resume" -> resume()
            "stopPush" -> stopPush()
            "bindAlias" -> {
                Log.d(TAG, "bindAlias:" + call.argument<Any>("alias").toString())
                bindAlias(call.argument<Any>("alias").toString())
            }
            "unbindAlias" -> {
                Log.d(TAG, "unbindAlias:" + call.argument<Any>("alias").toString())
                unbindAlias(call.argument<Any>("alias").toString())
            }
            "setTag" -> {
                val tags = call.argument<List<String>>("tags")!!
                Log.d(TAG, "tags:$tags")
                setTag(tags)
            }
            "onActivityCreate" -> {
                Log.d(TAG, "do onActivityCreate")
                onActivityCreate()
            }
            else -> result.notImplemented()
        }
    }

    private fun initGtSdk() {
        Log.d(TAG, "init getui sdk...test")
        PushManager.getInstance().initialize(context, GTPushService::class
                .java)
        PushManager.getInstance().registerPushIntentService(context, IntentService::class.java)
    }

    private fun onActivityCreate() {
        try {
            val method = PushManager::class.java.getDeclaredMethod("registerPushActivity", Context::class.java, Class::class.java)
            method.isAccessible = true
            method.invoke(PushManager.getInstance(), context, GeTuiPluginActivity::class.java)
        } catch (e: Throwable) {
            e.printStackTrace()
        }
    }


    private fun clientId(): String? {
        Log.d(TAG, "resume push service")
        return PushManager.getInstance().getClientid(context)
    }

    private fun resume() {
        Log.d(TAG, "resume push service")
        PushManager.getInstance().turnOnPush(context)
    }

    private fun stopPush() {
        Log.d(TAG, "stop push service")
        PushManager.getInstance().turnOffPush(context)
    }

    /**
     * 绑定别名功能:后台可以根据别名进行推送
     *
     * @param alias 别名字符串
     */
    private fun bindAlias(alias: String) {
        PushManager.getInstance().bindAlias(context, alias)
    }

    /**
     * 取消绑定别名功能
     *
     * @param alias 别名字符串
     */
    private fun unbindAlias(alias: String?) {
        PushManager.getInstance().unBindAlias(context, alias, false)
    }

    /**
     * 给用户打标签 , 后台可以根据标签进行推送
     *
     * @param tags 别名数组
     */
    private fun setTag(tags: List<String>?) {
        if (tags == null || tags.isEmpty()) {
            return
        }
        val tagArray = arrayOfNulls<Tag>(tags.size)
        for (i in tags.indices) {
            val tag = Tag()
            tag.name = tags[i]
            tagArray[i] = tag
        }
        PushManager.getInstance().setTag(context, tagArray, "setTag")
    }

    companion object {

        private const val TAG = "GeTuiPlugin"
        private const val FLUTTER_CALL_BACK_CID = 1
        private const val FLUTTER_CALL_BACK_MSG = 2
        var instance: GeTuiPlugin? = null
        private val flutterHandler: Handler = object : Handler(Looper.getMainLooper()) {
            override fun handleMessage(msg: Message) {
                when (msg.what) {
                    FLUTTER_CALL_BACK_CID -> when (msg.arg1) {
                        StateType.onReceiveClientId.ordinal -> {
                            instance!!.channel.invokeMethod("onReceiveClientId", msg.obj)
                            Log.d("flutterHandler", "onReceiveClientId >>> " + msg.obj)
                        }
                        StateType.onReceiveOnlineState.ordinal -> {
                            instance!!.channel.invokeMethod("onReceiveOnlineState", msg.obj)
                            Log.d("flutterHandler", "onReceiveOnlineState >>> " + msg.obj)
                        }
                        else -> {
                            Log.d(TAG, "default state type...")
                        }
                    }
                    FLUTTER_CALL_BACK_MSG -> when (msg.arg1) {
                        MessageType.onReceiveMessageData.ordinal -> {
                            instance!!.channel.invokeMethod("onReceiveMessageData", msg.obj)
                            Log.d("flutterHandler", "onReceiveMessageData >>> " + msg.obj)
                        }
                        MessageType.onNotificationMessageArrived.ordinal -> {
                            instance!!.channel.invokeMethod("onNotificationMessageArrived", msg.obj)
                            Log.d("flutterHandler", "onNotificationMessageArrived >>> " + msg.obj)
                        }
                        MessageType.onNotificationMessageClicked.ordinal -> {
                            instance!!.channel.invokeMethod("onNotificationMessageClicked", msg.obj)
                            Log.d("flutterHandler", "onNotificationMessageClicked >>> " + msg.obj)
                        }
                        else -> {
                            Log.d(TAG, "default Message type...")
                        }
                    }
                    else -> {
                    }
                }
            }
        }

        fun transmitMessageReceive(message: String?, func: String) {
            if (instance == null) {
                Log.d(TAG, "Getui flutter plugin doesn't exist")
                return
            }
            val type: Int = when (func) {
                "onReceiveClientId" -> {
                    StateType.onReceiveClientId.ordinal
                }
                "onReceiveOnlineState" -> {
                    StateType.onReceiveOnlineState.ordinal
                }
                else -> {
                    StateType.Default.ordinal
                }
            }
            val msg = Message.obtain()
            msg.what = FLUTTER_CALL_BACK_CID
            msg.arg1 = type
            msg.obj = message
            flutterHandler.sendMessage(msg)
        }

        @JvmStatic
        fun transmitMessageReceive(message: Map<String?, Any?>?, func: String?) {
            if (instance == null) {
                Log.d(TAG, "Getui flutter plugin doesn't exist")
                return
            }
            val type: Int = when (func) {
                "onReceiveMessageData" -> MessageType.onReceiveMessageData.ordinal
                "onNotificationMessageArrived" -> MessageType.onNotificationMessageArrived.ordinal
                "onNotificationMessageClicked" -> MessageType.onNotificationMessageClicked.ordinal
                else -> MessageType.Default.ordinal
            }
            val msg = Message.obtain()
            msg.what = FLUTTER_CALL_BACK_MSG
            msg.arg1 = type
            msg.obj = message
            flutterHandler.sendMessage(msg)
        }
    }


}
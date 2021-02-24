package flutter.getui

import android.content.Context
import com.igexin.sdk.PushManager
import com.igexin.sdk.Tag
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler


class GeTuiPlugin : FlutterPlugin, MethodCallHandler {

    companion object {
        lateinit var channel: MethodChannel
    }

    private var context: Context? = null

    override fun onAttachedToEngine(plugin: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(plugin.binaryMessenger, "get_tui")
        channel.setMethodCallHandler(this)
        context = plugin.applicationContext
    }


    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }


    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
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
                val tags = call.argument<List<String>>("tags")!!
                setTag(tags)
            }
            else -> result.notImplemented()
        }
    }

    /**
     * 给用户打标签 , 后台可以根据标签进行推送
     *
     * @param tags 别名数组
     */
    private fun setTag(tags: List<String>?) {
        if (tags == null || tags.isEmpty())
            return
        val tagArray = arrayOfNulls<Tag>(tags.size)
        for (i in tags.indices) {
            val tag = Tag()
            tag.name = tags[i]
            tagArray[i] = tag
        }
        PushManager.getInstance().setTag(context, tagArray, "setTag")
    }


}
package flutter.getui

import com.igexin.sdk.PushManager
import com.igexin.sdk.Tag
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel


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
                    val tags = call.argument<List<String>>("tags")!!
                    if (tags.isNotEmpty()) {
                        val tagArray = arrayOfNulls<Tag>(tags.size)
                        for (i in tags.indices) {
                            val tag = Tag()
                            tag.name = tags[i]
                            tagArray[i] = tag
                        }
                        //     * 给用户打标签 , 后台可以根据标签进行推送
                        //     *
                        //     * @param tags 别名数组
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


}
-dontwarn com.igexin.**
-keep class com.igexin.** { *; }
-keep class org.json.** { *; }
-dontwarn com.getui.**
-keep class com.getui.** { *; }


# Gson 自定义数据模型的bean目录
-keep class com.google.gson.stream.** { *; }
-keepattributes EnclosingMethod
-keep class com.getui.demo.net.request.** {*;}
-keep class com.getui.demo.net.response.** {*;}
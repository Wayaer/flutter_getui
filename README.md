# flutter_getui

### 配置

### Android:
#### 1.添加相关配置：

支持电子围栏功能

Android 可选权限
在 `/android/app/src/main/AndroidManifest.xml` 中添加下列代码：

```xml

    <uses-permission android:name="android.permission.BLUETOOTH"/>
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN"/>
    <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION”/>

```

在 `/android/app/build.gradle` 中添加下列代码：

```groovy
android: {
 
  defaultConfig {
    applicationId ""
    
    manifestPlaceholders = [
    	 GETUI_APPID    : "USER_APP_ID",
    	 GETUI_APP_KEY   : "USER_APP_KEY",
    	 GETUI_APP_SECRET: "USER_APP_SECRET",
         // 下面是多厂商配置，如需要开通使用请联系技术支持
         // 如果不需要使用，预留空字段即可
         XIAOMI_APP_ID   : "",
         XIAOMI_APP_KEY  : "",
         MEIZU_APP_ID    : "",
         MEIZU_APP_KEY   : "",
         HUAWEI_APP_ID   : "",
         OPPO_APP_KEY   : "",
         OPPO_APP_SECRET  : "",
         VIVO_APP_ID   : "",
         VIVO_APP_KEY  : ""
    ]
  }    
}
```


### 集成 HMS SDK

#### - 添加应用的 AppGallery Connect 配置文件

1. 登录 AppGallery Connect 网站，选择“我的应用”。找到应用所在的产品，点击应用名称。

2. 选择“开发 > 概览”，单击“应用”栏下的“agconnect-services.json”下载配置文件。

3. 将 agconnect-services.json 文件拷贝到应用级根目录下。如下：

   ```
   android/
     |- app/ （项目主模块）
     |  ......
     |    |- build.gradle （模块级 gradle 文件）
     |    |- agconnect-services.json 
     |- gradle/
     |- build.gradle （顶层 gradle 文件）
     |- settings.gradle
     | ......
   ```

#### - 配置相应依赖

1.配置签名信息：将步骤一【创建华为应用】中官方文档**生成签名证书指纹步骤中生成的签名文件拷贝到工程的 app 目录下**，在 app/build
.gradle 文件中配置签名。如下（具体请根据您当前项目的配置修改）：

```
signingConfigs {
     config {
         keyAlias 'pushdemo'
         keyPassword '123456789'
         storeFile file('pushdemo.jks')
         storePassword '123456789'
     }
 }
 buildTypes {
     debug {
         signingConfig signingConfigs.config
     }
     release {
         signingConfig signingConfigs.config
     }
 }
```

##### iOS:
1. 必须开启Push Notification能力。找到应用Target设置中的Signing & Capabilities，点击左上角 +Capability 添加。如果没有开启该开关，应用将获取不到DeviceToken

2. 为了更好支持消息推送，提供更多的推送样式，提高消息到达率，需要配置后台运行权限：

 并保证"Background Modes"中的"Remote notifications"处于选中状态
 
3. 使用NotificationService，同样开启Access WiFi Information设置。  + Capability
 添加 "Push Notifications"

### 使用
```dart
import 'package:flutter_getui/flutter_getui.dart';

```

### - 初始化个推sdk

```dart
   void main(){
     initGeTui(
         appId: 'appId',
         appKey: 'appKey',
         appSecret: 'appSecret');
    }
```

### - 公用 API
```dart
    ///   0：成功
    ///   10099：SDK 未初始化成功
    ///   30001：解绑别名失败，频率过快，两次调用的间隔需大于 5s
    ///   30002：解绑别名失败，参数错误
    ///   30003：解绑别名请求被过滤
    ///   30004：解绑别名失败，未知异常
    ///   30005：解绑别名时，cid 未获取到
    ///   30006：解绑别名时，发生网络错误
    ///   30007：别名无效
    ///   30008：sn 无效

    ///  绑定别名功能:后台可以根据别名进行推送
    ///  @param alias 别名字符串
    ///  @param aSn   绑定序列码, Android中无效，仅在iOS有效

    bindGeTuiAlias(alias, sn);

    unbindGeTuiAlias(alias, sn);

    /// 给用户打标签 , 后台可以根据标签进行推送
    /// @param tags 别名数组


    ///   code 值说明
    ///     0：成功
    ///    10099：SDK 未初始化成功
    ///    20001：tag 数量过大（单次设置的 tag 数量不超过 100)
    ///    20002：调用次数超限（默认一天只能成功设置一次）
    ///    20003：标签重复
    ///    20004：服务初始化失败
    ///    20005：setTag 异常
    ///    20006：tag 为空
    ///    20007：sn 为空
    ///    20008：离线，还未登陆成功
    ///    20009：该 appid 已经在黑名单列表（请联系技术支持处理）
    ///    20010：已存 tag 数目超限
    ///    20011：tag 内容格式不正确 *

    setGeTuiTag(tags);

     Future<void> initPush() async {
       addGeTuiEventHandler(
         onReceiveOnlineState: (bool? state) {
           text = 'Android Push online Status $state';
         },
         onReceiveMessageData: (GTMessageModel? msg) async {
           print('onReceiveMessageData ${msg?.toMap ?? 'null'}');
         },
         onNotificationMessageArrived: (GTMessageModel? msg) async {
           print('onNotificationMessageArrived ${msg?.toMap ?? 'null'}');
         },
         onNotificationMessageClicked: (GTMessageModel? msg) async {
           print('onNotificationMessageClicked ${msg?.toMap ?? 'null'}');
         },
         onReceiveDeviceToken: (String? token) {
           print('onReceiveDeviceToken $token');
         },
         onAppLinkPayload: (String? message) {
           text = 'onAppLinkPayload $message';
         },
         onRegisterVoIpToken: (String? message) {
           text = 'onRegisterVoIpToken $message';
         },
         onReceiveVoIpPayLoad: (Map<dynamic, dynamic>? message) {
           text = 'onReceiveVoIpPayLoad $message';
         },
       );
     }


```
### - Android APi
```dart
     ///  停止SDK服务

     stopGeTuiPush();

     ///  开启SDK服务
     startGeTuiPush();

     ///  检查集成结果
     checkAndroidManifest();

     ///  检测android 推送服务状态
     isAndroidPushStatus();

     /// 设置华为 badge
     setAndroidBadge();

```

### iOS API

```dart
     ///  同步服务端角标
     setIOSGeTuiBadge(badge);

     ///  复位服务端角标
     resetIOSGeTuiBadge();

      ///  同步App本地角标
     setIOSGeTuiLocalBadge(badge); 

      ///  获取冷启动Apns参数
     getIOSGeTuiLaunchNotification();

     ///  注册 voip 推送服务
     voIpRegistrationForIOS();

```



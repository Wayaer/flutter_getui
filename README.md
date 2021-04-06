# flutter_getui

### 配置

### Android:
#### 1.添加相关配置：

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

#### 1. 添加应用的 AppGallery Connect 配置文件

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

#### 2. 配置相应依赖

1.该步骤需要在模块级别 `app/build.gradle` 中文件头配置 `apply plugin: 'com.huawei.agconnect
'` 以及在 `dependencies` 块配置 HMS Push 依赖 `implementation 'com.huawei.hms:push:${version}'`，如下：

```
apply plugin: 'com.android.application'
apply plugin: 'com.huawei.agconnect'
android { 
    ......
}
dependencies { 
    ......
    implementation 'com.huawei.hms:push:5.0.2.300'
}
```

2.配置签名信息：将步骤一【创建华为应用】中官方文档**生成签名证书指纹步骤中生成的签名文件拷贝到工程的 app 目录下**，在 app/build
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
         minifyEnabled false
         proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
     }
 }
```


### 使用
```dart
import 'package:flutter_getui/flutter_getui.dart';

```

### 初始化个推sdk

```dart
   void main(){
     initGeTui(
         appId: 'appId',
         appKey: 'appKey',
         appSecret: 'appSecret');
    }
```

### 公用 API
```dart
    ///  绑定别名功能:后台可以根据别名进行推送
    ///  @param alias 别名字符串
    ///  @param aSn   绑定序列码, Android中无效，仅在iOS有效

    bindGeTuiAlias(alias, sn);

    unbindGeTuiAlias(alias, sn);

    /// 给用户打标签 , 后台可以根据标签进行推送
    /// @param tags 别名数组

    setGeTuiTag(tags);

```
### Android APi
```dart
     ///  停止SDK服务

     stopGeTuiPush();

     ///  开启SDK服务
     startGeTuiPush();

```

### iOS API

```dart
     ///  同步服务端角标

     setBadgeWithGeTui(badge);

     ///  复位服务端角标

     resetBadgeWithGeTui();

      ///  同步App本地角标
 
     setLocalBadgeWithGeTui(badge); 


      ///  获取冷启动Apns参数

     getGeTuiLaunchNotification();

```



import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

typedef EventHandler = void Function(String? res);
typedef EventHandlerBool = void Function(bool? online);
typedef EventHandlerMap = void Function(Map<dynamic, dynamic>? event);
typedef EventHandlerMessageModel = void Function(GTMessageModel message);
typedef EventHandlerGTResultModel = void Function(GTResultModel result);

class FlGeTui {
  factory FlGeTui() => _singleton ??= FlGeTui._();

  FlGeTui._();

  static FlGeTui? _singleton;

  final MethodChannel _channel = const MethodChannel('ge_tui');

  /// 初始化sdk
  Future<bool> init({String? appId, String? appKey, String? appSecret}) async {
    if (!_supportPlatform) return false;
    bool? state = false;
    if (_isAndroid) {
      state = await _channel.invokeMethod<bool?>('initPush');
    } else if (_isIOS) {
      assert(appId != null);
      assert(appKey != null);
      assert(appSecret != null);
      state = await _channel.invokeMethod<bool?>('initSDK',
          {'appId': appId, 'appKey': appKey, 'appSecret': appSecret});
    }
    return state ?? false;
  }

  /// ios注册 voip 推送服务
  Future<bool> voIpRegistrationForIOS() async {
    if (!_isIOS) return false;
    final bool? state = await _channel.invokeMethod<bool?>('voipRegistration');
    return state ?? false;
  }

  /// 检查集成结果 仅支持Android
  Future<bool> checkManifestWithAndroid() async {
    if (!_isAndroid) return false;
    final bool? state = await _channel.invokeMethod<bool?>('checkManifest');
    return state ?? false;
  }

  /// android 打开通知权限页面
  Future<bool> openNotificationWithAndroid() async {
    if (!_isAndroid) return false;
    final bool? state = await _channel.invokeMethod<bool?>('openNotification');
    return state ?? false;
  }

  /// 检测android 是否开启通知权限
  Future<bool> checkNotificationsEnabledWithAndroid() async {
    if (!_isAndroid) return false;
    final bool? state =
        await _channel.invokeMethod<bool?>('checkNotificationsEnabled');
    return state ?? false;
  }

  /// 获取 clientId
  Future<String?> getClientID() async {
    if (!_supportPlatform) return null;
    return await _channel.invokeMethod<String?>('getClientId');
  }

  /// 绑定 Alias
  /// sn  绑定序列码 默认为 ''
  /// 绑定结果请调用 [addEventHandler];
  Future<bool> bindAlias(String alias, String sn) async {
    if (!_supportPlatform) return false;
    final bool? state = await _channel
        .invokeMethod<bool?>('bindAlias', {'alias': alias, 'sn': sn});
    return state ?? false;
  }

  /// 解绑 Alias
  /// alias 别名字符串
  /// sn  绑定序列码 默认为 ''
  /// isSelf  是否只对当前cid有效，如果是true，只对当前cid做解绑；如果是false，对所有绑定该别名的cid列表做解绑
  /// 解绑结果请调用 [addEventHandler];
  Future<bool> unbindAlias(String alias, String sn,
      {bool isSelf = true}) async {
    if (!_supportPlatform) return false;
    final bool? state = await _channel.invokeMethod<bool?>(
        'unbindAlias', {'alias': alias, 'sn': sn, 'isSelf': isSelf});
    return state ?? false;
  }

  /// 设置Tag
  /// sn：用户自定义的序列号，用来唯一标识该动作
  /// 设置结果请调用 [addEventHandler];
  Future<bool> setTag(List<String> tags, String sn) async {
    if (!_supportPlatform) return false;
    assert(tags.isNotEmpty, 'tags 不能为空');
    bool? status =
        await _channel.invokeMethod<bool?>('setTag', {'tags': tags, 'sn': sn});
    return status ?? false;
  }

  /// 开启推送
  Future<bool> startPush() async {
    bool? status = await _channel.invokeMethod<bool?>('startPush');
    return status ?? false;
  }

  /// 关闭推送
  Future<bool> stopPush() async {
    bool? status = await _channel.invokeMethod<bool?>('stopPush');
    return status ?? false;
  }

  /// 检测android 推送服务状态
  Future<bool> getPushStatusWithAndroid() async {
    if (!_isAndroid) return false;
    final bool? status = await _channel.invokeMethod<bool?>('isPushTurnedOn');
    return status ?? false;
  }

  /// setBadge
  /// 支持ios android
  /// android 仅支持华为 vivo oppo
  Future<bool> setBadge(int badge, {bool badgeWithIOSIcon = true}) async {
    if (!_supportPlatform) return false;
    final bool? status = await _channel.invokeMethod<bool?>(
        'setBadge', {'badge': badge, 'badgeWithIOSIcon': badgeWithIOSIcon});
    return status ?? false;
  }

  /// only ios
  Future<bool> resetBadgeWithIOS() async {
    if (_isIOS) {
      final bool? status = await _channel.invokeMethod<bool?>('resetBadge');
      return status ?? false;
    }
    return false;
  }

  /// only ios
  /// 清空下拉通知栏全部通知,并将角标置“0”，不显示角标
  Future<bool> clearAllNotificationForNotificationBarWithIOS() async {
    if (_isIOS) {
      final bool? status = await _channel
          .invokeMethod<bool?>('clearAllNotificationForNotificationBar');
      return status ?? false;
    }
    return false;
  }

  /// only ios
  /// 是否允许SDK 后台运行（默认值：NO） 备注：可以未启动SDK就调用该方法
  /// 支持当APP进入后台后，个推是否运行,YES.允许
  /// 注意：开启后台运行时，需同时开启Signing & Capabilities > Background Modes > Auido, Airplay and Picture in Picture 才能保持长期后台在线，该功能会和音乐播放冲突，使用时请注意。 本方法有缓存，如果要关闭后台运行，需要调用[GeTuiSdk runBackgroundEnable:NO]
  Future<bool> runBackgroundEnableWithIOS(bool enable) async {
    if (_isIOS) {
      final bool? status =
          await _channel.invokeMethod<bool?>('runBackgroundEnable', enable);
      return status ?? false;
    }
    return false;
  }

  /// only ios
  /// 销毁SDK，并且释放资源
  Future<bool> destroyWithIOS() async {
    if (_isIOS) {
      final bool? status = await _channel.invokeMethod<bool?>('destroy');
      return status ?? false;
    }
    return false;
  }

  /// only ios
  Future<Map<dynamic, dynamic>?> getLaunchNotificationWithIOS() async {
    if (_isIOS) return await _channel.invokeMethod('getLaunchNotification');
    return null;
  }

  /// 消息监听
  void addEventHandler({
    /// Android 集成了厂商推送通道 获取厂商token
    /// ios deviceToken  deviceToken 不为空 表示个推服务注册成功
    EventHandler? onReceiveDeviceToken,

    /// android ios 收到的透传内容
    EventHandlerMessageModel? onReceiveMessageData,

    /// android   通知到达，只有个推通道下发的通知会回调此方法
    /// ios 收到APNS消息
    EventHandlerMessageModel? onNotificationMessageArrived,

    /// cid 在线状态 支持 android  ios
    EventHandlerBool? onReceiveOnlineState,

    /// android 通知点击，只有个推通道下发的通知会回调此方法
    EventHandlerMessageModel? onNotificationMessageClicked,

    /// ios voIpToken
    EventHandler? onRegisterVoIpToken,

    /// ios 收到AppLink消息
    EventHandler? onAppLinkPayload,

    /// ios 收到VoIP消息
    EventHandlerMap? onReceiveVoIpPayLoad,

    /// tag 绑定结果回调  支持 android  ios
    EventHandlerGTResultModel? onSetTagResult,

    /// 绑定别名结果回调  支持 android  ios
    EventHandlerGTResultModel? onBindAliasResult,

    /// 解绑别名结果回调  支持 android  ios
    EventHandlerGTResultModel? onUnBindAliasResult,
  }) {
    if (!_supportPlatform) return;
    _channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'onReceiveOnlineState':
          onReceiveOnlineState?.call(call.arguments as bool?);
          break;
        case 'onReceiveMessageData':
          onReceiveMessageData?.call(GTMessageModel.fromJson(call.arguments));
          break;
        case 'onNotificationMessageArrived':
          onNotificationMessageArrived
              ?.call(GTMessageModel.fromJson(call.arguments));
          break;
        case 'onNotificationMessageClicked':
          onNotificationMessageClicked
              ?.call(GTMessageModel.fromJson(call.arguments));
          break;
        case 'onReceiveDeviceToken':
          onReceiveDeviceToken?.call(call.arguments?.toString());
          break;
        case 'onAppLinkPayload':
          onAppLinkPayload?.call(call.arguments?.toString());
          break;
        case 'onRegisterVoIpToken':
          onRegisterVoIpToken?.call(call.arguments?.toString());
          break;
        case 'onReceiveVoIpPayLoad':
          onReceiveVoIpPayLoad?.call(call.arguments);
          break;
        case 'onSetTag':
          onSetTagResult?.call(GTResultModel.fromJson(call.arguments));
          break;
        case 'onBindAlias':
          onBindAliasResult?.call(GTResultModel.fromJson(call.arguments));
          break;
        case 'onUnBindAlias':
          onUnBindAliasResult?.call(GTResultModel.fromJson(call.arguments));
          break;
        default:
          throw UnsupportedError('Unrecognized Event');
      }
    });
  }
}

class GTMessageModel {
  GTMessageModel(
      {this.messageId,
      this.payload,
      this.payloadId,
      this.taskId,
      this.title,
      this.offLine,
      this.content});

  GTMessageModel.fromJson(Map<dynamic, dynamic> json) {
    offLine = json['offLine'] as bool?;
    fromGeTui = json['fromGeTui'] as bool?;
    messageId = json['messageId'] as String?;
    title = json['title'] as String?;
    payload = json['payload'] as String?;
    payloadId = json['payloadId'] as String?;
    taskId = json['taskId'] as String?;
    content = json['content'] as String?;
    final Map<dynamic, dynamic>? aps = json['aps'] as Map<dynamic, dynamic>?;
    if (aps != null) {
      final _ApsModel apsModel = _ApsModel.fromJson(aps);
      title = apsModel.alert?.title;
      content = apsModel.alert?.body;
      sound = apsModel.sound;
    }
  }

  /// 推送消息的messageid
  String? messageId;

  /// 推送消息的任务id
  String? taskId;
  String? title;
  String? content;
  String? payload;

  /// only Android
  String? payloadId;

  /// only ios
  ///
  /// 是否是离线消息  true 是离线消息
  bool? offLine;

  /// true 个推通道  false 苹果apns通道
  bool? fromGeTui;
  String? sound;

  Map<String, dynamic> toMap() => {
        'messageId': messageId,
        'title': title,
        'content': content,
        'payload': payload,
        'payloadId': payloadId,
        'taskId': taskId,
        'offLine': offLine,
        'fromGeTui': fromGeTui,
        'sound': sound
      };
}

class GTResultModel {
  GTResultModel.fromJson(Map<dynamic, dynamic> json) {
    isSuccess = json['isSuccess'] as bool?;
    code = json['code'] as String?;
    sn = json['sn'] as String?;
  }

  bool? isSuccess;
  String? code;
  String? sn;

  Map<String, dynamic> toMap() =>
      {'isSuccess': isSuccess, 'code': code, 'sn': sn};
}

class _ApsModel {
  _ApsModel.fromJson(Map<dynamic, dynamic> json) {
    mutableContent = json['mutable-content'] as int?;
    alert = json['alert'] != null
        ? _AlertModel.fromJson(json['alert'] as Map<dynamic, dynamic>)
        : null;
    badge = json['badge'] as int?;
    sound = json['sound'] as String?;
  }

  int? mutableContent;
  _AlertModel? alert;
  int? badge;
  String? sound;
}

class _AlertModel {
  _AlertModel.fromJson(Map<dynamic, dynamic> json) {
    subtitle = json['subtitle'] as String?;
    title = json['title'] as String?;
    body = json['body'] as String?;
  }

  String? subtitle;
  String? title;
  String? body;
}

bool get _supportPlatform {
  if (!kIsWeb && (_isAndroid || _isIOS)) return true;
  debugPrint('Not support platform for $defaultTargetPlatform');
  return false;
}

bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;

bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;

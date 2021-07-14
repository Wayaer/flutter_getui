import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

typedef EventHandler = void Function(String? res);
typedef EventHandlerBool = void Function(bool? online);
typedef EventHandlerMap = void Function(Map<dynamic, dynamic>? event);
typedef EventHandlerMessageModel = void Function(GTMessageModel? message);

const MethodChannel _channel = MethodChannel('ge_tui');

/// 初始化sdk
Future<bool> initGeTui(
    {String? appId, String? appKey, String? appSecret}) async {
  if (!_supportPlatform) return false;
  bool? state = false;
  if (_isAndroid) {
    state = await _channel.invokeMethod<bool?>('initPush');
  } else if (_isIOS) {
    assert(appId != null);
    assert(appKey != null);
    assert(appSecret != null);
    state = await _channel.invokeMethod<bool?>('initSDK', <String, dynamic>{
      'appId': appId,
      'appKey': appKey,
      'appSecret': appSecret
    });
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
Future<bool> checkAndroidManifest() async {
  if (!_isAndroid) return false;
  final bool? state = await _channel.invokeMethod<bool?>('checkManifest');
  return state ?? false;
}

/// 获取 clientId
Future<String?> getGeTuiClientID() async {
  if (!_supportPlatform) return null;
  return await _channel.invokeMethod<String?>('getClientId');
}

/// 绑定 Alias
/// sn  绑定序列码 默认为 ‘’
Future<bool> bindGeTuiAlias(String alias, {String sn = ''}) async {
  if (!_supportPlatform) return false;
  final bool? state = await _channel.invokeMethod<bool?>(
      'bindAlias', <String, dynamic>{'alias': alias, 'aSn': sn});
  return state ?? false;
}

/// 解绑 Alias
/// alias 别名字符串
/// sn  绑定序列码 默认为 ‘’
/// isSelf  是否只对当前cid有效，如果是true，只对当前cid做解绑；如果是false，对所有绑定该别名的cid列表做解绑
Future<bool> unbindGeTuiAlias(String alias,
    {String sn = '', bool isSelf = true}) async {
  if (!_supportPlatform) return false;
  final bool? state = await _channel.invokeMethod<bool?>('unbindAlias',
      <String, dynamic>{'alias': alias, 'aSn': sn, 'isSelf': isSelf});
  return state ?? false;
}

/// 设置Tag
/// sn 序列号 仅支持Android
/// return code = 0 为成功，其他状态🐴 Android
/// ios 成功为0， 失败为 1
/// android 失败为 1
Future<int?> setGeTuiTag(List<String> tags, {String sn = ''}) async {
  if (!_supportPlatform) return null;
  assert(tags.isNotEmpty, 'tags 不能为空');
  if (_isAndroid) {
    return await _channel.invokeMethod<int?>(
        'setTag', <String, dynamic>{'tags': tags, 'sn': sn});
  } else if (_isIOS) {
    final bool? status = await _channel.invokeMethod<bool?>(
        'setTag', <String, dynamic>{'tags': tags, 'sn': sn});
    return (status ?? false) ? 0 : 1;
  }
  return 0;
}

/// 开启推送 only android
Future<bool> startAndroidGeTuiPush() async {
  bool? status = false;
  if (_isAndroid) status = await _channel.invokeMethod<bool?>('startPush');
  return status ?? false;
}

/// 关闭推送 only android
Future<bool> stopAndroidGeTuiPush() async {
  bool? status = false;
  if (_isAndroid) status = await _channel.invokeMethod<bool?>('stopPush');
  return status ?? false;
}

/// 检测android 推送服务状态
Future<bool> isAndroidPushStatus() async {
  if (!_isAndroid) return false;
  final bool? status = await _channel.invokeMethod<bool?>('isPushTurnedOn');
  return status ?? false;
}

/// setGeTuiBadge
/// 支持ios android
/// android 仅支持华为
Future<bool> setGeTuiBadge(int badge) async {
  if (!_supportPlatform) return false;
  final bool? status = await _channel.invokeMethod<bool?>('setBadge', badge);
  return status ?? false;
}

/// only ios
Future<bool> resetIOSGeTuiBadge() async {
  if (_isIOS) {
    final bool? status = await _channel.invokeMethod<bool?>('resetBadge');
    return status ?? false;
  }
  return false;
}

/// only ios
Future<bool> setIOSGeTuiLocalBadge(int badge) async {
  if (_isIOS) {
    final bool? status =
        await _channel.invokeMethod<bool?>('setLocalBadge', badge);
    return status ?? false;
  }
  return false;
}

/// only ios
Future<Map<dynamic, dynamic>?> getIOSGeTuiLaunchNotification() async {
  if (_isIOS) return await _channel.invokeMethod('getLaunchNotification');
  return null;
}

/// 消息监听
void addGeTuiEventHandler({
  /// Android 集成了厂商推送通道 获取厂商token
  /// ios deviceToken  deviceToken 不为空 表示个推服务注册成功
  EventHandler? onReceiveDeviceToken,

  /// android ios 收到的透传内容
  EventHandlerMessageModel? onReceiveMessageData,

  /// android   通知到达，只有个推通道下发的通知会回调此方法
  /// ios 收到APNS消息
  EventHandlerMessageModel? onNotificationMessageArrived,

  /// android 在线状态
  EventHandlerBool? onReceiveOnlineState,

  /// android 通知点击，只有个推通道下发的通知会回调此方法
  EventHandlerMessageModel? onNotificationMessageClicked,

  /// ios voIpToken
  EventHandler? onRegisterVoIpToken,

  /// ios 收到AppLink消息
  EventHandler? onAppLinkPayload,

  /// ios 收到VoIP消息
  EventHandlerMap? onReceiveVoIpPayLoad,
}) {
  if (!_supportPlatform) return;
  _channel.setMethodCallHandler((MethodCall call) async {
    switch (call.method) {
      case 'onReceiveOnlineState':
        if (onReceiveOnlineState == null) return;
        return onReceiveOnlineState(call.arguments as bool?);
      case 'onReceiveMessageData':
        if (onReceiveMessageData == null) return;
        final Map<dynamic, dynamic>? map =
            call.arguments as Map<dynamic, dynamic>?;
        if (map != null)
          return onReceiveMessageData(GTMessageModel.fromJson(map));
        return onReceiveMessageData(null);
      case 'onNotificationMessageArrived':
        if (onNotificationMessageArrived == null) return;
        final Map<dynamic, dynamic>? map =
            call.arguments as Map<dynamic, dynamic>?;
        if (map != null)
          return onNotificationMessageArrived(GTMessageModel.fromJson(map));
        return onNotificationMessageArrived(null);

      case 'onNotificationMessageClicked':
        if (onNotificationMessageClicked == null) return;
        final Map<dynamic, dynamic>? map =
            call.arguments as Map<dynamic, dynamic>?;
        if (map != null)
          return onNotificationMessageClicked(GTMessageModel.fromJson(map));
        return onNotificationMessageClicked(null);

      case 'onReceiveDeviceToken':
        if (onReceiveDeviceToken == null) return;
        return onReceiveDeviceToken(call.arguments.toString());

      case 'onAppLinkPayload':
        if (onAppLinkPayload == null) return;
        return onAppLinkPayload(call.arguments.toString());

      case 'onRegisterVoIpToken':
        if (onRegisterVoIpToken == null) return;
        return onRegisterVoIpToken(call.arguments.toString());

      case 'onReceiveVoIpPayLoad':
        if (onReceiveVoIpPayLoad == null) return;
        return onReceiveVoIpPayLoad(call.arguments as Map<dynamic, dynamic>?);
      default:
        throw UnsupportedError('Unrecognized Event');
    }
  });
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
      final _ApsModel _apsModel = _ApsModel.fromJson(aps);
      title = _apsModel.alert?.title;
      content = _apsModel.alert?.body;
      sound = _apsModel.sound;
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

  Map<String, dynamic> get toMap => <String, dynamic>{
        'messageId': messageId,
        'title': title,
        'content': content,
        'payload': payload,
        'payloadId': payloadId,
        'taskId': taskId
      };
}

class _ApsModel {
  _ApsModel({this.mutableContent, this.alert, this.badge, this.sound});

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
  _AlertModel({this.subtitle, this.title, this.body});

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
  print('not support Platform');
  return false;
}

bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;

bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;

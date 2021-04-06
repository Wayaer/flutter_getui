import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

typedef EventHandler = void Function(String res);
typedef EventHandlerBool = void Function(bool online);
typedef EventHandlerMap = void Function(Map<dynamic, dynamic> event);

const MethodChannel _channel = MethodChannel('get_tui');

/// 初始化sdk
Future<void> initGeTui(
    {String? appId, String? appKey, String? appSecret}) async {
  if (Platform.isAndroid) {
    return await _channel.invokeMethod<dynamic>('initPush');
  } else if (Platform.isIOS) {
    assert(appId != null);
    assert(appKey != null);
    assert(appSecret != null);
    return await _channel.invokeMethod<dynamic>('initSDK', <String, dynamic>{
      'appId': appId,
      'appKey': appKey,
      'appSecret': appSecret
    });
  }
}

/// 获取 clientId
Future<String?> getGeTuiClientID() => _channel.invokeMethod('getClientId');

/// 开启推送 only android
Future<void> startGeTuiPush() async {
  if (Platform.isAndroid) await _channel.invokeMethod<dynamic>('startPush');
}

/// 关闭推送 only android
Future<void> stopGeTuiPush() async {
  if (Platform.isAndroid) await _channel.invokeMethod<dynamic>('stopPush');
}

/// 绑定 Alias
Future<void> bindGeTuiAlias(String alias, String sn) async {
  if (Platform.isAndroid) {
    await _channel
        .invokeMethod<dynamic>('bindAlias', <String, dynamic>{'alias': alias});
  } else if (Platform.isIOS) {
    await _channel.invokeMethod<dynamic>(
        'bindAlias', <String, dynamic>{'alias': alias, 'aSn': sn});
  }
}

/// 解绑 Alias
Future<void> unbindGeTuiAlias(String alias, String sn, bool isSelf) async {
  if (Platform.isAndroid) {
    await _channel.invokeMethod<dynamic>(
        'unbindAlias', <String, dynamic>{'alias': alias});
  } else if (Platform.isIOS) {
    await _channel.invokeMethod<dynamic>('unbindAlias',
        <String, dynamic>{'alias': alias, 'aSn': sn, 'isSelf': isSelf});
  }
}

/// only ios
Future<void> setGeTuiBadge(int badge) async {
  if (Platform.isIOS) await _channel.invokeMethod<dynamic>('setBadge', badge);
}

/// only ios
Future<void> get resetBadgeWithGeTui async {
  if (Platform.isIOS) await _channel.invokeMethod<dynamic>('resetBadge');
}

/// only ios
Future<void> setLocalBadgeWithGeTui(int badge) async {
  if (Platform.isIOS)
    await _channel.invokeMethod<dynamic>('setLocalBadge', badge);
}

/// only ios
Future<Map<dynamic, dynamic>?> getGeTuiLaunchNotification() async {
  if (Platform.isIOS)
    return await _channel.invokeMethod('getLaunchNotification');
  return null;
}

void setGeTuiTag(List<String> tags) =>
    _channel.invokeMethod<dynamic>('setTag', <String, dynamic>{'tags': tags});

/// 消息监听
void addGeTuiEventHandler({
  /// 注册收到 cid 的回调
  EventHandler? onReceiveClientId,

  /// android 在线状态
  EventHandlerBool? onReceiveOnlineState,

  /// android 收到消息回调
  EventHandlerMap? onNotificationMessageArrived,

  /// android 点击消息回调
  EventHandlerMap? onNotificationMessageClicked,

  /// android 透传消息
  EventHandlerMap? onReceiveMessageData,

  /// ios deviceToken
  EventHandler? onRegisterDeviceToken,

  /// ios voIpToken
  EventHandler? onRegisterVoIpToken,

  /// ios 收到的透传内容
  EventHandlerMap? onReceivePayload,

  /// ios 收到APNS消息 点击通知
  EventHandlerMap? onReceiveNotificationResponse,

  /// ios 收到AppLink消息
  EventHandler? onAppLinkPayload,

  /// ios 收到VoIP消息
  EventHandlerMap? onReceiveVoIpPayLoad,
}) {
  _channel.setMethodCallHandler((MethodCall call) async {
    switch (call.method) {
      case 'onReceiveClientId':
        if (onReceiveClientId == null) return;
        return onReceiveClientId(call.arguments.toString());
      case 'onReceiveOnlineState':
        if (onReceiveOnlineState == null) return;
        return onReceiveOnlineState(call.arguments as bool);
      case 'onReceiveMessageData':
        if (onReceiveMessageData != null) {
          final Map<String, dynamic> map =
              call.arguments as Map<String, dynamic>;
          return onReceiveMessageData(map);
        }
        break;
      case 'onNotificationMessageArrived':
        if (onNotificationMessageArrived == null) return;
        final Map<String, dynamic> map = call.arguments as Map<String, dynamic>;
        return onNotificationMessageArrived(map);

      case 'onNotificationMessageClicked':
        if (onNotificationMessageClicked == null) return;
        final Map<String, dynamic> map = call.arguments as Map<String, dynamic>;
        return onNotificationMessageClicked(map);

      case 'onRegisterDeviceToken':
        if (onRegisterDeviceToken == null) return;
        return onRegisterDeviceToken(call.arguments.toString());

      case 'onReceivePayload':
        if (onReceivePayload == null) return;
        final Map<String, dynamic> map = call.arguments as Map<String, dynamic>;
        return onReceivePayload(map);

      case 'onReceiveNotificationResponse':
        if (onReceiveNotificationResponse == null) return;
        final Map<String, dynamic> map = call.arguments as Map<String, dynamic>;
        return onReceiveNotificationResponse(map);

      case 'onAppLinkPayload':
        if (onAppLinkPayload == null) return;
        return onAppLinkPayload(call.arguments.toString());

      case 'onRegisterVoIpToken':
        if (onRegisterVoIpToken == null) return;
        return onRegisterVoIpToken(call.arguments.toString());

      case 'onReceiveVoIpPayLoad':
        if (onReceiveVoIpPayLoad == null) return;
        final Map<String, dynamic> map = call.arguments as Map<String, dynamic>;
        return onReceiveVoIpPayLoad(map);
      default:
        throw UnsupportedError('Unrecognized Event');
    }
  });
}

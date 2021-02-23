import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

typedef EventHandler = void Function(String res);
typedef EventHandlerBool = void Function(bool online);
typedef EventHandlerMap = void Function(Map<String, dynamic> event);

const MethodChannel _channel = MethodChannel('get_tui');

/// 初始化sdk
Future<void> initGeTuiSdk(
    {String appId, String appKey, String appSecret}) async {
  if (Platform.isAndroid) {
    return await _channel.invokeMethod<dynamic>('initPush');
  } else {
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

///获取 clientId
Future<String> get getGeTuiClientId => _channel.invokeMethod('getClientId');

Future<Map<dynamic, dynamic>> get getGeTuiLaunchNotification async {
  if (Platform.isIOS)
    return await _channel.invokeMethod('getLaunchNotification');
  return null;
}

/// 开启推送
Future<void> get startGeTuiPush => _channel.invokeMethod<dynamic>('startPush');

/// 关闭推送
Future<void> get stopGeTuiPush async {
  if (Platform.isAndroid) await _channel.invokeMethod<dynamic>('stopPush');
}

Future<void> bindGeTuiAlias(String alias, String sn) async {
  if (Platform.isAndroid) {
    await _channel
        .invokeMethod<dynamic>('bindAlias', <String, dynamic>{'alias': alias});
  } else if (Platform.isIOS) {
    await _channel.invokeMethod<dynamic>(
        'bindAlias', <String, dynamic>{'alias': alias, 'aSn': sn});
  }
}

Future<void> unbindGeTuiAlias(String alias, String sn, bool isSelf) async {
  if (Platform.isAndroid) {
    await _channel.invokeMethod<dynamic>(
        'unbindAlias', <String, dynamic>{'alias': alias});
  } else if (Platform.isIOS) {
    await _channel.invokeMethod<dynamic>('unbindAlias',
        <String, dynamic>{'alias': alias, 'aSn': sn, 'isSelf': isSelf});
  }
}

Future<void> setGeTuiBadge(int badge) async {
  if (Platform.isIOS)
    await _channel
        .invokeMethod<dynamic>('setBadge', <String, dynamic>{'badge': badge});
}

Future<void> get resetGeTuiBadge async {
  if (Platform.isIOS) await _channel.invokeMethod<dynamic>('resetBadge');
}

Future<void> setGeTuiLocalBadge(int badge) async {
  if (Platform.isIOS)
    await _channel.invokeMethod<dynamic>(
        'setLocalBadge', <String, dynamic>{'badge': badge});
}

void setGeTuiTag(List<dynamic> tags) =>
    _channel.invokeMethod<dynamic>('setTag', <String, dynamic>{'tags': tags});

void addGeTuiEventHandler({
  /// 注册收到 cid 的回调
  EventHandler onReceiveClientId,
  EventHandlerMap onReceiveMessageData,
  EventHandlerBool onReceiveOnlineState,
  EventHandlerMap onNotificationMessageArrived,
  EventHandlerMap onNotificationMessageClicked,

  /// deviceToken
  EventHandler onRegisterDeviceToken,

  /// voIpToken
  EventHandler onRegisterVoIpToken,

  /// ios 收到的透传内容
  EventHandlerMap onReceivePayload,

  /// ios 收到APNS消息
  EventHandlerMap onReceiveNotificationResponse,

  /// ios 收到AppLink消息
  EventHandler onAppLinkPayload,

  /// ios 收到VoIP消息
  EventHandlerMap onReceiveVoIpPayLoad,
}) {
  _channel.setMethodCallHandler((MethodCall call) async {
    switch (call.method) {
      case 'onReceiveClientId':
        if (onReceiveClientId != null)
          return onReceiveClientId(call.arguments.toString());
        break;
      case 'onReceiveOnlineState':
        if (onReceiveOnlineState != null)
          return onReceiveOnlineState(call.arguments as bool);
        break;
      case 'onReceiveMessageData':
        final Map<String, dynamic> map = call.arguments as Map<String, dynamic>;
        if (onReceiveMessageData != null) return onReceiveMessageData(map);
        break;
      case 'onNotificationMessageArrived':
        final Map<String, dynamic> map = call.arguments as Map<String, dynamic>;
        if (onNotificationMessageArrived != null)
          return onNotificationMessageArrived(map);
        break;
      case 'onNotificationMessageClicked':
        final Map<String, dynamic> map = call.arguments as Map<String, dynamic>;
        if (onNotificationMessageClicked != null)
          return onNotificationMessageClicked(map);
        break;
      case 'onRegisterDeviceToken':
        if (onRegisterDeviceToken != null)
          return onRegisterDeviceToken(call.arguments.toString());
        break;
      case 'onReceivePayload':
        final Map<String, dynamic> map = call.arguments as Map<String, dynamic>;
        if (onReceivePayload != null) return onReceivePayload(map);
        break;
      case 'onReceiveNotificationResponse':
        final Map<String, dynamic> map = call.arguments as Map<String, dynamic>;
        if (onReceiveNotificationResponse != null)
          return onReceiveNotificationResponse(map);
        break;
      case 'onAppLinkPayload':
        if (onAppLinkPayload != null)
          return onAppLinkPayload(call.arguments.toString());
        break;
      case 'onRegisterVoIpToken':
        if (onRegisterVoIpToken != null)
          return onRegisterVoIpToken(call.arguments.toString());
        break;
      case 'onReceiveVoIpPayLoad':
        final Map<String, dynamic> map = call.arguments as Map<String, dynamic>;
        if (onReceiveVoIpPayLoad != null) return onReceiveVoIpPayLoad(map);
        break;
      default:
        throw UnsupportedError('Unrecognized Event');
    }
  });
}

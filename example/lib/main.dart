import 'package:flutter/material.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_getui/flutter_getui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// 初始化
  final bool status = await FlGeTui()
      .init(appId: 'appid', appKey: 'appKey', appSecret: 'appSecret');
  debugPrint('是否初始化成功 = $status');

  runApp(const MaterialApp(
      debugShowCheckedModeBanner: false, title: '个推', home: HomePage()));
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String text = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((Duration timeStamp) => initPush());
  }

  Future<void> initPush() async {
    FlGeTui().addEventHandler(
      onReceiveOnlineState: (bool? state) {
        text = 'Android Push online Status $state';
        setState(() {});
      },
      onReceiveMessageData: (GTMessageModel? msg) async {
        text = 'onReceiveMessageData ${msg?.toMap() ?? 'null'}';
        debugPrint('onReceiveMessageData ${msg?.toMap() ?? 'null'}');
        setState(() {});
      },
      onNotificationMessageArrived: (GTMessageModel? msg) async {
        text = 'onNotificationMessageArrived ${msg?.toMap() ?? 'null'}';
        debugPrint('onNotificationMessageArrived ${msg?.toMap() ?? 'null'}');
        setState(() {});
      },
      onNotificationMessageClicked: (GTMessageModel? msg) async {
        text = 'onNotificationMessageClicked ${msg?.toMap() ?? 'null'}';
        debugPrint('onNotificationMessageClicked ${msg?.toMap() ?? 'null'}');
        setState(() {});
      },
      onReceiveDeviceToken: (String? token) {
        text = 'onReceiveDeviceToken $token';
        debugPrint('onReceiveDeviceToken $token');
        setState(() {});
      },
      onAppLinkPayload: (String? message) {
        text = 'onAppLinkPayload $message';
        debugPrint('onAppLinkPayload $message');
        setState(() {});
      },
      onRegisterVoIpToken: (String? message) {
        text = 'onRegisterVoIpToken $message';
        debugPrint('onRegisterVoIpToken $message');
        setState(() {});
      },
      onReceiveVoIpPayLoad: (Map<dynamic, dynamic>? message) {
        text = 'onReceiveVoIpPayLoad $message';
        debugPrint('onReceiveVoIpPayLoad $message');
        setState(() {});
      },
      onSetTagResult: (GTResultModel result) {
        text = 'onSetTagResult ${result.toMap()}';
        debugPrint('onSetTagResult ${result.toMap()}');
        setState(() {});
      },
      onBindAliasResult: (GTResultModel result) {
        text = 'onBindAliasResult ${result.toMap()}';
        debugPrint('onBindAliasResult ${result.toMap()}');
        setState(() {});
      },
      onUnBindAliasResult: (GTResultModel result) {
        text = 'onUnBindAliasResult ${result.toMap()}';
        debugPrint('onUnBindAliasResult ${result.toMap()}');
        setState(() {});
      },
    );
  }

  Future<void> getLaunchNotification() async {
    final Map<dynamic, dynamic>? info =
        await FlGeTui().getLaunchNotificationWithIOS();
    debugPrint(info.toString());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('GeTui Example')),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: <
            Widget>[
          Container(
              padding: const EdgeInsets.all(10),
              alignment: Alignment.center,
              height: 100,
              color: Colors.grey.withOpacity(0.2),
              margin: const EdgeInsets.all(10),
              child: Text(text)),
          Wrap(
              runSpacing: 10,
              spacing: 10,
              alignment: WrapAlignment.center,
              children: <Widget>[
                ElevatedText(
                    text: 'getClientID',
                    onPressed: () async {
                      final String? cid = await FlGeTui().getClientID();
                      text = 'getClientID: $cid';
                      setState(() {});
                    }),
                ElevatedText(
                    onPressed: () {
                      FlGeTui().setTag(['test1', 'test2'], 'sn');
                    },
                    text: 'setTag'),
                ElevatedText(
                    onPressed: () {
                      FlGeTui().bindAlias('test', 'sn');
                    },
                    text: 'bindAlias'),
                ElevatedText(
                    onPressed: () {
                      FlGeTui().unbindAlias('test', 'sn');
                    },
                    text: 'unbindAlias'),
                ElevatedText(
                    onPressed: () async {
                      final bool status = await FlGeTui().startPush();
                      text = 'startPush  $status';
                      setState(() {});
                    },
                    text: 'start push'),
                ElevatedText(
                    onPressed: () async {
                      final bool status = await FlGeTui().stopPush();
                      text = 'stopPush $status';
                      setState(() {});
                    },
                    text: 'stop push'),
              ]),
          if (isAndroid)
            Wrap(
                runSpacing: 10,
                spacing: 10,
                alignment: WrapAlignment.center,
                children: <Widget>[
                  ElevatedText(
                      onPressed: () async {
                        final bool status = await FlGeTui().setBadge(10);
                        text = 'setBadge  $status';
                        setState(() {});
                      },
                      text: 'setBadge （Android 支持华为 Vivo OPPO）'),
                  ElevatedText(
                      onPressed: () async {
                        final bool status = await FlGeTui()
                            .checkNotificationsEnabledWithAndroid();
                        text = 'checkNotificationsEnabledWithAndroid  $status';
                        setState(() {});
                      },
                      text: 'checkNotificationsEnabledWithAndroid'),
                  ElevatedText(
                      onPressed: () async {
                        final bool status =
                            await FlGeTui().openNotificationWithAndroid();
                        text = 'openNotificationWithAndroid  $status';
                        setState(() {});
                      },
                      text: 'openNotificationWithAndroid'),
                  ElevatedText(
                      onPressed: () async {
                        final bool status =
                            await FlGeTui().getPushStatusWithAndroid();
                        text = 'getPushStatusWithAndroid  $status';
                        setState(() {});
                      },
                      text: 'getPushStatusWithAndroid'),
                ]),
          if (isIOS)
            Wrap(
                runSpacing: 10,
                spacing: 10,
                alignment: WrapAlignment.center,
                children: <Widget>[
                  ElevatedText(
                      onPressed: () async {
                        final bool status = await FlGeTui().setBadge(5);
                        text = 'setBadge  $status';
                        setState(() {});
                      },
                      text: 'setBadge(5)'),
                  ElevatedText(
                      onPressed: getLaunchNotification,
                      text: 'getLaunchNotificationWithIOS'),
                  ElevatedText(
                      onPressed: FlGeTui().resetBadgeWithIOS,
                      text: 'resetBadgeWithIOS'),
                  ElevatedText(
                      onPressed: () async {
                        final bool status = await FlGeTui()
                            .clearAllNotificationForNotificationBarWithIOS();
                        text =
                            'clearAllNotificationForNotificationBarWithIOS  $status';
                        setState(() {});
                      },
                      text: 'clearAllNotificationForNotificationBarWithIOS'),
                  ElevatedText(
                      onPressed: () async {
                        final bool status =
                            await FlGeTui().runBackgroundEnableWithIOS(true);
                        text = 'runBackgroundEnableWithIOS  $status';
                        setState(() {});
                      },
                      text: 'runBackgroundEnableWithIOS'),
                  ElevatedText(
                      onPressed: () async {
                        final bool status = await FlGeTui().destroyWithIOS();
                        text = 'destroyWithIOS  $status';
                        setState(() {});
                      },
                      text: 'destroyWithIOS'),
                ]),
        ]),
      ));
}

class ElevatedText extends StatelessWidget {
  const ElevatedText({Key? key, this.onPressed, required this.text})
      : super(key: key);
  final VoidCallback? onPressed;
  final String text;

  @override
  Widget build(BuildContext context) =>
      ElevatedButton(onPressed: onPressed, child: Text(text));
}

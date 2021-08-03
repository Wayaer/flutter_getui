import 'package:flutter/material.dart';
import 'package:flutter_getui/flutter_getui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// 初始化
  final bool status = await FlGeTui.instance
      .init(appId: 'appid', appKey: 'appKey', appSecret: 'appSecret');
  print('是否初始化成功 = $status');

  runApp(MaterialApp(
      debugShowCheckedModeBanner: false, title: '个推', home: HomePage()));
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String text = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!
        .addPostFrameCallback((Duration timeStamp) => initPush());
  }

  Future<void> initPush() async {
    FlGeTui.instance.addEventHandler(
      onReceiveOnlineState: (bool? state) {
        text = 'Android Push online Status $state';
        setState(() {});
      },
      onReceiveMessageData: (GTMessageModel? msg) async {
        text = 'onReceiveMessageData ${msg?.toMap ?? 'null'}';
        print('onReceiveMessageData ${msg?.toMap ?? 'null'}');
        setState(() {});
      },
      onNotificationMessageArrived: (GTMessageModel? msg) async {
        text = 'onNotificationMessageArrived ${msg?.toMap ?? 'null'}';
        print('onNotificationMessageArrived ${msg?.toMap ?? 'null'}');
        setState(() {});
      },
      onNotificationMessageClicked: (GTMessageModel? msg) async {
        text = 'onNotificationMessageClicked ${msg?.toMap ?? 'null'}';
        print('onNotificationMessageClicked ${msg?.toMap ?? 'null'}');
        setState(() {});
      },
      onReceiveDeviceToken: (String? token) {
        text = 'onReceiveDeviceToken $token';
        print('onReceiveDeviceToken $token');
        setState(() {});
      },
      onAppLinkPayload: (String? message) {
        text = 'onAppLinkPayload $message';
        setState(() {});
      },
      onRegisterVoIpToken: (String? message) {
        text = 'onRegisterVoIpToken $message';
        setState(() {});
      },
      onReceiveVoIpPayLoad: (Map<dynamic, dynamic>? message) {
        text = 'onReceiveVoIpPayLoad $message';
        setState(() {});
      },
    );
  }

  Future<void> getLaunchNotification() async {
    final Map<dynamic, dynamic>? info =
        await FlGeTui.instance.getLaunchNotificationWithIOS();
    print(info);
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
                ElevatedButton(
                    onPressed: () async {
                      final String? cid = await FlGeTui.instance.getClientID();
                      text = 'getClientID: $cid';
                      print(cid);
                      setState(() {});
                    },
                    child: const Text('getClientID')),
                ElevatedButton(
                    onPressed: () async {
                      final int? status = await FlGeTui.instance
                          .setTag(<String>['test1', 'test2']);
                      if (status == null) return;
                      text = 'setTag  code=$status';
                      setState(() {});
                    },
                    child: const Text('setTag')),
                ElevatedButton(
                    onPressed: () async {
                      final bool? status =
                          await FlGeTui.instance.bindAlias('test');
                      if (status == null) return;
                      text = 'bindAlias  $status';
                      setState(() {});
                    },
                    child: const Text('bindAlias')),
                ElevatedButton(
                    onPressed: () async {
                      final bool? status =
                          await FlGeTui.instance.unbindAlias('test');
                      if (status == null) return;
                      text = 'unbindAlias  $status';
                      setState(() {});
                    },
                    child: const Text('unbindAlias')),
                ElevatedButton(
                    onPressed: () async {
                      final bool status = await FlGeTui.instance.setBadge(10);
                      text = 'setBadge  $status';
                      setState(() {});
                    },
                    child: const Text('setBadge （Android 仅支持华为）')),
              ]),
          const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text('Android Public Function',
                  style: TextStyle(color: Colors.lightBlue, fontSize: 18.0))),
          Wrap(
              runSpacing: 10,
              spacing: 10,
              alignment: WrapAlignment.center,
              children: <Widget>[
                ElevatedButton(
                    onPressed: () async {
                      final bool status =
                          await FlGeTui.instance.startPushWithAndroid();
                      text = 'startPushWithAndroid  $status';
                      setState(() {});
                    },
                    child: const Text('start push')),
                ElevatedButton(
                    onPressed: () async {
                      final bool status =
                          await FlGeTui.instance.stopPushWithAndroid();
                      text = 'stopPushWithAndroid  $status';
                      setState(() {});
                    },
                    child: const Text('stop push')),
                ElevatedButton(
                    onPressed: () async {
                      final bool status =
                          await FlGeTui.instance.getPushStatusWithAndroid();
                      text = 'getPushStatusWithAndroid  $status';
                      setState(() {});
                    },
                    child: const Text('getPushStatusWithAndroid')),
              ]),
          const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text('IOS Public Function',
                  style: TextStyle(color: Colors.lightBlue, fontSize: 18.0))),
          Wrap(
              runSpacing: 10,
              spacing: 10,
              alignment: WrapAlignment.center,
              children: <Widget>[
                ElevatedButton(
                    onPressed: getLaunchNotification,
                    child: const Text('getLaunchNotificationWithIOS')),
                ElevatedButton(
                    onPressed: () => FlGeTui.instance.resetBadgeWithIOS(),
                    child: const Text('resetBadgeWithIOS')),
                ElevatedButton(
                    onPressed: () async {
                      await FlGeTui.instance.setLocalBadgeWithIOS(5);
                      text = 'setLocalBadgeWithIOS = 5';
                    },
                    child: const Text('setLocalBadge(5)')),
                ElevatedButton(
                    onPressed: () async {
                      await FlGeTui.instance.setLocalBadgeWithIOS(0);
                      text = 'setLocalBadgeWithIOS = 0';
                    },
                    child: const Text('setLocalBadge(0)')),
              ]),
        ]),
      ));
}

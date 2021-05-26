import 'package:flutter/material.dart';
import 'package:flutter_getui/flutter_getui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// 初始化
  final bool status =
      await initGeTui(appId: 'appid', appKey: 'appKey', appSecret: 'appSecret');

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
    addGeTuiEventHandler(
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
    final Map<dynamic, dynamic>? info = await getIOSGeTuiLaunchNotification();
    print(info);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('GeTui Example')),
      body: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
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
                          final String? cid = await getGeTuiClientID();
                          text = 'getGeTuiClientID: $cid';
                          print(cid);
                          setState(() {});
                        },
                        child: const Text('getGeTuiClientID')),
                    ElevatedButton(
                        onPressed: () async {
                          final int? status =
                              await setGeTuiTag(<String>['test1', 'test2']);
                          if (status == null) return;
                          text = 'setGeTuiTag  code=$status';
                          setState(() {});
                        },
                        child: const Text('setGeTuiTag')),
                    ElevatedButton(
                        onPressed: () async {
                          final bool? status = await bindGeTuiAlias('test');
                          if (status == null) return;
                          text = 'bindGeTuiAlias  $status';
                          setState(() {});
                        },
                        child: const Text('bindGeTuiAlias')),
                    ElevatedButton(
                        onPressed: () async {
                          final bool? status = await unbindGeTuiAlias('test');
                          if (status == null) return;
                          text = 'unbindGeTuiAlias  $status';
                          setState(() {});
                        },
                        child: const Text('unbindGeTuiAlias')),
                  ]),
              const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text('Android Public Function',
                      style:
                          TextStyle(color: Colors.lightBlue, fontSize: 18.0))),
              Wrap(
                  runSpacing: 10,
                  spacing: 10,
                  alignment: WrapAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                        onPressed: () => startAndroidGeTuiPush(),
                        child: const Text('start push')),
                    ElevatedButton(
                        onPressed: () => stopAndroidGeTuiPush(),
                        child: const Text('stop push')),
                    ElevatedButton(
                        onPressed: () async {
                          final bool? status = await isAndroidPushStatus();
                          if (status == null) return;
                          text = 'isAndroidPushStatus  $status';
                          setState(() {});
                        },
                        child: const Text('isAndroidPushStatus')),
                  ]),
              const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text('ios Public Function',
                      style:
                          TextStyle(color: Colors.lightBlue, fontSize: 18.0))),
              Wrap(
                  runSpacing: 10,
                  spacing: 10,
                  alignment: WrapAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                        onPressed: getLaunchNotification,
                        child: const Text('getLaunchNotification')),
                    ElevatedButton(
                        onPressed: () => setIOSGeTuiBadge(10),
                        child: const Text('setBadge(10)')),
                    ElevatedButton(
                        onPressed: () => resetIOSGeTuiBadge,
                        child: const Text('resetBadge')),
                    ElevatedButton(
                        onPressed: () async {
                          await setIOSGeTuiLocalBadge(5);
                          text = 'setIOSGeTuiLocalBadge = 5';
                        },
                        child: const Text('setLocalBadge(5)')),
                    ElevatedButton(
                        onPressed: () async {
                          await setIOSGeTuiLocalBadge(0);
                          text = 'setIOSGeTuiLocalBadge = 0';
                        },
                        child: const Text('setLocalBadge(0)')),
                  ]),
            ]),
      ));
}

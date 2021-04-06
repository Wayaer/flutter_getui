import 'package:flutter/material.dart';
import 'package:flutter_getui/flutter_getui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// 初始化
  initGeTui(
      appId: 'cy0d7CICux7YKvteM5cy87',
      appKey: 'DGb52WTbzf8QX2Joji9bJ5',
      appSecret: 'ZpUhvjyrGv8d24tFCa4y95');

  runApp(MaterialApp(
      debugShowCheckedModeBanner: false, title: '个推', home: HomePage()));
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String payloadInfo = 'default';
  String notificationState = 'default';
  String getClientId = '';
  String getDeviceToken = '';
  String getVoIpToken = '';
  String onReceivePayload = '';
  String onReceiveNotificationResponse = '';
  String onAppLinkPayLoad = '';
  String? onReceiveVoIpPayLoad;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!
        .addPostFrameCallback((Duration timeStamp) => initPlatformState());
  }

  Future<void> initPlatformState() async {
    addGeTuiEventHandler(
      onReceiveClientId: (String message) async {
        print('flutter onReceiveClientId: $message');
        getClientId = message;
        setState(() {});
      },
      onReceiveOnlineState: (bool state) {
        print('flutter onReceiveOnlineState: $state');
      },
      onReceiveMessageData: (Map<dynamic, dynamic> msg) async {
        print('flutter onReceiveMessageData: $msg');
        payloadInfo = msg['payload'].toString();
        setState(() {});
      },
      onNotificationMessageArrived: (Map<dynamic, dynamic> msg) async {
        print('flutter onNotificationMessageArrived');
        notificationState = 'Arrived';
        setState(() {});
      },
      onNotificationMessageClicked: (Map<dynamic, dynamic> msg) async {
        print('flutter onNotificationMessageClicked');
        notificationState = 'Clicked';
        setState(() {});
      },
      onRegisterDeviceToken: (String message) {
        print('flutter onRegisterDeviceToken: $message');
        getDeviceToken = message;
        setState(() {});
      },
      onReceivePayload: (Map<dynamic, dynamic> message) {
        print('flutter onReceivePayload: $message');
        onReceivePayload = message.toString();
        setState(() {});
      },
      onReceiveNotificationResponse: (Map<dynamic, dynamic> message) {
        print('flutter onReceiveNotificationResponse: $message');
        onReceiveNotificationResponse = '$message';
        setState(() {});
      },
      onAppLinkPayload: (String message) {
        onAppLinkPayLoad = message;
        setState(() {});
      },
      onRegisterVoIpToken: (String message) {
        getVoIpToken = message;
        setState(() {});
      },
      onReceiveVoIpPayLoad: (Map<dynamic, dynamic> message) {
        onReceiveVoIpPayLoad = message.toString();
        setState(() {});
      },
    );
  }

  Future<void> getLaunchNotification() async {
    final Map<dynamic, dynamic> info = (await getGeTuiLaunchNotification())!;
    print(info);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('GeTui Example')),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text('ClientId: $getClientId'),
              const Text('SDK Public Function',
                  style: TextStyle(color: Colors.lightBlue, fontSize: 18.0)),
              Wrap(runSpacing: 10, spacing: 10, children: <Widget>[
                ElevatedButton(
                    onPressed: () async {
                      final String getClientId = (await getGeTuiClientID())!;
                      print(getClientId);
                    },
                    child: const Text('getClientId')),
                ElevatedButton(
                    onPressed: () => startGeTuiPush(),
                    child: const Text('start push')),
                ElevatedButton(
                    onPressed: () => stopGeTuiPush(),
                    child: const Text('stop push')),
                ElevatedButton(
                    onPressed: () => bindGeTuiAlias('test', ''),
                    child: const Text('bindAlias')),
                ElevatedButton(
                    onPressed: () => unbindGeTuiAlias('test', '', true),
                    child: const Text('unbindAlias')),
                ElevatedButton(
                    onPressed: () {
                      final List<String> test = <String>[];
                      test.add('abc');
                      setGeTuiTag(test);
                    },
                    child: const Text('setTag')),
              ]),
              const Text('Android Public Function',
                  style: TextStyle(color: Colors.lightBlue, fontSize: 18.0)),
              Text('payload: $payloadInfo'),
              Text('notification state: $notificationState'),
              const SizedBox(height: 20),
              const Text('ios Public Function',
                  style: TextStyle(color: Colors.lightBlue, fontSize: 18.0)),
              Wrap(runSpacing: 10, spacing: 10, children: <Widget>[
                ElevatedButton(
                    onPressed: getLaunchNotification,
                    child: const Text('getLaunchNotification')),
                ElevatedButton(
                    onPressed: () => setGeTuiBadge(5),
                    child: const Text('setBadge')),
                ElevatedButton(
                    onPressed: () => resetBadgeWithGeTui,
                    child: const Text('resetBadge')),
                ElevatedButton(
                    onPressed: () => setLocalBadgeWithGeTui(5),
                    child: const Text('setLocalBadge(5)')),
                ElevatedButton(
                    onPressed: () => setLocalBadgeWithGeTui(0),
                    child: const Text('setLocalBadge(0)'))
              ]),
              Text('DeviceToken: $getDeviceToken'),
              Text('VoIpToken: $getVoIpToken'),
              Text('payload: $onReceivePayload'),
              Text(
                  'onReceiveNotificationResponse: $onReceiveNotificationResponse'),
              Text('onAppLinkPayload: $onAppLinkPayLoad'),
              Text('onReceiveVoIpPayLoad: $onReceiveVoIpPayLoad'),
            ]),
      ));
}

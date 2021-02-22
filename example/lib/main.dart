import 'package:flutter/material.dart';
import 'package:flutter_getui/flutter_ge_tui.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
    title: '个推 example',
    theme: ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    home: HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _payloadInfo = 'Null';
  String _notificationState = '';
  String _getClientId = '';
  String _getDeviceToken = '';
  String _getVoIpToken = '';
  String _onReceivePayload = '';
  String _onReceiveNotificationResponse = '';
  String _onAppLinkPayLoad = '';
  String _onReceiveVoIpPayLoad;
  GeTui geTui;

  @override
  void initState() {
    super.initState();
    geTui = GeTui();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    const String payloadInfo = 'default';
    const String notificationState = 'default';

    geTui.initSdk(
        appId: 'iMahVVxurw6BNr7XSn9EF2',
        appKey: 'yIPfqwq6OMAPp6dkqgLpG5',
        appSecret: 'G0aBqAD6t79JfzTB6Z5lo5');

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _payloadInfo = payloadInfo;
      _notificationState = notificationState;
    });

    geTui.addEventHandler(
      onReceiveClientId: (String message) async {
        print('flutter onReceiveClientId: $message');
        setState(() {
          _getClientId = 'ClientId: $message';
        });
      },
      onReceiveMessageData: (Map<String, dynamic> msg) async {
        print('flutter onReceiveMessageData: $msg');
        _payloadInfo = msg['payload'].toString();
        setState(() {});
      },
      onNotificationMessageArrived: (Map<String, dynamic> msg) async {
        print('flutter onNotificationMessageArrived');

        _notificationState = 'Arrived';
        setState(() {});
      },
      onNotificationMessageClicked: (Map<String, dynamic> msg) async {
        print('flutter onNotificationMessageClicked');
        _notificationState = 'Clicked';
        setState(() {});
      },
      onRegisterDeviceToken: (String message) {
        _getDeviceToken = message;
        setState(() {});
      },
      onReceivePayload: (Map<String, dynamic> message) {
        print('flutter onReceivePayload: $message');
        _onReceivePayload = message.toString();
        setState(() {});
      },
      onReceiveNotificationResponse: (Map<String, dynamic> message) {
        print('flutter onReceiveNotificationResponse: $message');
        _onReceiveNotificationResponse = '$message';
        setState(() {});
      },
      onAppLinkPayload: (String message) {
        _onAppLinkPayLoad = message;
        setState(() {});
      },
      onRegisterVoIpToken: (String message) {
        _getVoIpToken = message;
        setState(() {});
      },
      onReceiveVoIpPayLoad: (Map<String, dynamic> message) {
        _onReceiveVoIpPayLoad = message.toString();
        setState(() {});
      },
    );
  }

  Future<void> getClientId() async {
    String getClientId;
    try {
      getClientId = await geTui.getClientId;
      print(getClientId);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> getLaunchNotification() async {
    Map<dynamic, dynamic> info;
    try {
      info = await geTui.getLaunchNotification;
      print(info);
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Plugin example app')),
      body: Center(
        child: Column(children: <Widget>[
          Text('clientId: $_getClientId\n'),
          const Text(
            'Android Public Function',
            style: TextStyle(color: Colors.lightBlue, fontSize: 20.0),
          ),
          Text('payload: $_payloadInfo\n'),
          Text('notification state: $_notificationState\n'),
          const Text('SDK Public Function',
              style: TextStyle(color: Colors.lightBlue, fontSize: 20.0)),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                RaisedButton(
                  onPressed: () {
                    // geTui.onActivityCreate();
                  },
                  child: const Text('onActivityCreate'),
                ),
                RaisedButton(
                  onPressed: getLaunchNotification,
                  child: const Text('getLaunchNotification'),
                )
              ]),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                RaisedButton(
                    onPressed: getClientId, child: const Text('getClientId')),
                RaisedButton(
                  onPressed: () => geTui.turnOffPush,
                  child: const Text('stop push'),
                ),
                RaisedButton(
                    onPressed: () => geTui.turnOnPush,
                    child: const Text('start push')),
              ]),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                RaisedButton(
                    onPressed: () => geTui.bindAlias('test', ''),
                    child: const Text('bindAlias')),
                RaisedButton(
                    onPressed: () => geTui.unbindAlias('test', '', true),
                    child: const Text('unbindAlias')),
                RaisedButton(
                  onPressed: () {
                    final List<String> test = <String>[];
                    test.add('abc');
                    geTui.setTag(test);
                  },
                  child: const Text('setTag'),
                )
              ]),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                RaisedButton(
                  onPressed: () => geTui.setBadge(5),
                  child: const Text('setBadge'),
                ),
                RaisedButton(
                    onPressed: () => geTui.resetBadge,
                    child: const Text('resetBadge')),
              ]),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                RaisedButton(
                    onPressed: () => geTui.setLocalBadge(5),
                    child: const Text('setLocalBadge(5)')),
                RaisedButton(
                    onPressed: () => geTui.setLocalBadge(0),
                    child: const Text('setLocalBadge(0)'))
              ]),
          const Text('ios Public Function',
              style: TextStyle(color: Colors.redAccent, fontSize: 20.0)),
          Text('DeviceToken: $_getDeviceToken'),
          Text('VoIpToken: $_getVoIpToken'),
          Text('payload: $_onReceivePayload'),
          Text(
              'onReceiveNotificationResponse: $_onReceiveNotificationResponse'),
          Text('onAppLinkPayload: $_onAppLinkPayLoad'),
          Text('onReceiveVoIpPayLoad: $_onReceiveVoIpPayLoad'),
        ]),
      ));
}

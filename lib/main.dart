import 'dart:async';
import 'events.dart';
import 'package:flutter/material.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sockets Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PusherApp(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();
  String _log = 'output:\n';
  final _apiKey = TextEditingController();
  final _cluster = TextEditingController();
  final _channelName = TextEditingController();
  final _eventName = TextEditingController();
  final _channelFormKey = GlobalKey<FormState>();
  final _eventFormKey = GlobalKey<FormState>();
  final _listViewController = ScrollController();
  final _data = TextEditingController();
  int _counter = 0;
  void log(String text) {
    print("LOG: $text");
    setState(() {
      _log += text + "\n";
      Timer(
          const Duration(milliseconds: 100),
              () => _listViewController
              .jumpTo(_listViewController.position.maxScrollExtent));
    });
  }



  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  void onConnectPressed() async{
    if (!_channelFormKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).requestFocus(FocusNode());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("apiKey", _apiKey.text);
    prefs.setString("cluster", _cluster.text);
    prefs.setString("channelName", _channelName.text);

    try {
      await pusher.init(
        apiKey: _apiKey.text,
        cluster: _cluster.text,
        onConnectionStateChange: onConnectionStateChange,
        onError: onError,
        onSubscriptionSucceeded: onSubscriptionSucceeded,
        onEvent: onEvent,
        onSubscriptionError: onSubscriptionError,
        onDecryptionFailure: onDecryptionFailure,
        onMemberAdded: onMemberAdded,
        onMemberRemoved: onMemberRemoved,
        // authEndpoint: "<Your Authendpoint Url>",
        // onAuthorizer: onAuthorizer
      );
      await pusher.subscribe(channelName: _channelName.text);
      await pusher.connect();
    } catch (e) {
      log("ERROR: $e");
    }

  }


  void onTriggerEventPressed() async {
    var eventFormValidated = _eventFormKey.currentState!.validate();

    if (!eventFormValidated) {
      return;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("eventName", _eventName.text);
    prefs.setString("data", _data.text);
    pusher.trigger(PusherEvent(
        channelName: _channelName.text,
        eventName: _eventName.text,
        data: _data.text));
  }

  void onConnectionStateChange(dynamic currentState, dynamic previousState) {
    log("Connection: $currentState");
  }
  void onError(String message, int? code, dynamic e) {
    log("onError: $message code: $code exception: $e");
  }
  void onEvent(PusherEvent event) {
    log("onEvent: $event");
  }
  void onSubscriptionSucceeded(String channelName, dynamic data) {
    log("onSubscriptionSucceeded: $channelName data: $data");
    final me = pusher.getChannel(channelName)?.me;
    log("Me: $me");
  }
  void onSubscriptionError(String message, dynamic e) {
    log("onSubscriptionError: $message Exception: $e");
  }
  void onDecryptionFailure(String event, String reason) {
    log("onDecryptionFailure: $event reason: $reason");
  }
  void onMemberAdded(String channelName, PusherMember member) {
    log("onMemberAdded: $channelName user: $member");
  }
  void onMemberRemoved(String channelName, PusherMember member) {
    log("onMemberRemoved: $channelName user: $member");
  }
  Future<void> initPlatformState() async {
    if (!mounted) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiKey.text = prefs.getString("apiKey") ?? '';
      _cluster.text = prefs.getString("cluster") ?? 'eu';
      _channelName.text = prefs.getString("channelName") ?? 'presence-channel';
      _eventName.text = prefs.getString("eventName") ?? 'client-event';
      _data.text = prefs.getString("data") ?? 'test';
    });
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(pusher.connectionState == 'DISCONNECTED'
              ? 'Pusher Channels Example'
              : _channelName.text),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
              controller: _listViewController,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              children: <Widget>[
                if (pusher.connectionState != 'CONNECTED')
                  Form(
                      key: _channelFormKey,
                      child: Column(children: <Widget>[
                        TextFormField(
                          controller: _apiKey,
                          validator: (String? value) {
                            return (value != null && value.isEmpty)
                                ? 'Please enter your API key.'
                                : null;
                          },
                          decoration:
                          const InputDecoration(labelText: 'API Key'),
                        ),
                        TextFormField(
                          controller: _cluster,
                          validator: (String? value) {
                            return (value != null && value.isEmpty)
                                ? 'Please enter your cluster.'
                                : null;
                          },
                          decoration: const InputDecoration(
                            labelText: 'Cluster',
                          ),
                        ),
                        TextFormField(
                          controller: _channelName,
                          validator: (String? value) {
                            return (value != null && value.isEmpty)
                                ? 'Please enter your channel name.'
                                : null;
                          },
                          decoration: const InputDecoration(
                            labelText: 'Channel',
                          ),
                        ),
                        ElevatedButton(
                          onPressed: onConnectPressed,
                          child: const Text('Connect'),
                        )
                      ]))
                else
                  Form(
                    key: _eventFormKey,
                    child: Column(children: <Widget>[
                      // ListView.builder(
                      //     scrollDirection: Axis.vertical,
                      //     shrinkWrap: true,
                      //     itemCount: pusher
                      //         .channels[_channelName.text]?.members.length,
                      //     itemBuilder: (context, index) {
                      //       final member = pusher
                      //           .channels[_channelName.text]!.members
                      //           .elementAt(index);
                      //       return ListTile(
                      //           title: Text(member.userInfo.toString()),
                      //           subtitle: Text(member.userId));
                      //     }),
                      TextFormField(
                        controller: _eventName,
                        validator: (String? value) {
                          return (value != null && value.isEmpty)
                              ? 'Please enter your event name.'
                              : null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Event',
                        ),
                      ),
                      TextFormField(
                        controller: _data,
                        decoration: const InputDecoration(
                          labelText: 'Data',
                        ),
                      ),
                      ElevatedButton(
                        onPressed: onTriggerEventPressed,
                        child: const Text('Trigger Event'),
                      ),
                    ]),
                  ),
                SingleChildScrollView(
                    scrollDirection: Axis.vertical, child: Text(_log)),
              ]),
        ),
      ),
    );
  }
}

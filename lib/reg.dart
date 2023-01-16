import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';


void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'Auth';



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
        appBar: AppBar(title: const Text(_title)),
        body: const MyStatefulWidget(),
      ),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _listViewController = ScrollController();
  bool _loading=false;
  String _log = 'output:\n';

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



  Future<void> _performlogin(name,password) async {
    PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();


    await pusher.init(
        apiKey: "e0951f610f43e2b73e0f",
        cluster: "mt1"
    );

    await pusher.connect();

    var myChannel = await pusher.subscribe(
        channelName: "254704800563",
        onEvent: "balance",
    );
  }

  @override
  void initState() {
    super.initState();
    _performlogin("user","karim");

  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      home: SafeArea(
        child: Scaffold(
          body:  _loading ? Center (child: CircularProgressIndicator())
              :Padding(
              padding: const EdgeInsets.all(10),
              child: ListView(
                children: <Widget>[
                  Container(

                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(10),
                      child: const Text(
                        'Client to Server',
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                            fontSize: 30),
                      )),
                  Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(10),
                      child: const Text(
                        'pusher',
                        style: TextStyle(fontSize: 20),
                      )),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Username',
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: TextField(
                      obscureText: true,
                      controller: passwordController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Password',
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      //forgot password screen
                      _performlogin(nameController.text,passwordController.text);
                    },
                    child: const Text('Forgot Password',),
                  ),
                  Container(
                      height: 50,
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: ElevatedButton(
                        child: const Text('Send message'),
                        onPressed: () {

                           _performlogin(nameController.text,passwordController.text);

                        },
                      )
                  ),
                  Row(
                    children: <Widget>[
                      const Text('Does not have account?'),
                      TextButton(
                        child: const Text(
                          'Signin',
                          style: TextStyle(fontSize: 20),
                        ),
                        onPressed: () {
                          //signup screen
                        },
                      )
                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
                ],
              )),
        ),
      ),
    );
  }


}
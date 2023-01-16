import 'package:flutter/material.dart';

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  late String _email, _password;

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
        home: SafeArea(
          child: Scaffold(
            body: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (input) => !input!.contains('@') ? 'Please enter a valid email' : null,
                  onSaved: (input) => _email = input!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  validator: (input) => input!.length < 6 ? 'Must be at least 6 characters' : null,
                  onSaved: (input) => _password = input!,
                  obscureText: true,
                ),
                ElevatedButton(
                  onPressed: _submit,
                  child: Text('Submit'),
                ),
              ],
            ),
    ),
          ),
        ),
      );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Perform login
    }
  }
}

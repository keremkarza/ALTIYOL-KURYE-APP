import 'package:altiyol_kurye/providers/auth_provider.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'login_screen.dart';

class ResetPassword extends StatefulWidget {
  static const String id = 'reset-password-screen';

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _formKey = GlobalKey<FormState>();
  //var _passwordTextController = TextEditingController();
  //var _cPasswordTextController = TextEditingController();
  var _emailTextController = TextEditingController();
  String email;
  String password;
  bool _loading = false;
  @override
  Widget build(BuildContext context) {
    final _authData = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Reset Passoword',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actionsIconTheme: IconThemeData(color: Colors.white),
        actions: [
          Icon(Icons.vpn_key_outlined),
          SizedBox(width: 20),
        ],
      ),
      body: Builder(
        builder: (context) => Form(
          key: _formKey,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  //mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(
                      'images/forgot_password.png',
                      height: 250,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    RichText(
                      text: TextSpan(text: '', children: [
                        TextSpan(
                          text: 'Forgot Password  ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                        TextSpan(
                            style: TextStyle(
                                color: Colors.redAccent, fontSize: 11),
                            text:
                                'Do not worry, provide us your registered Email. We will send you an email to reset your password.'),
                      ]),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: _emailTextController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Enter Email Address';
                        }
                        final bool _isValid =
                            EmailValidator.validate(_emailTextController.text);
                        if (!_isValid) {
                          return 'Invalid Email Format';
                        }
                        setState(() {
                          this.email = value;
                        });

                        return null;
                      },
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.mail_outline,
                          color: Theme.of(context).primaryColor,
                        ),
                        labelText: 'Email Address',
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 2,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        focusColor: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            style: TextButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).primaryColor),
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                setState(() {
                                  _loading = true;
                                });
                                _authData.resetBoyPassword(email);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Check your email ${_emailTextController.text} for reset link.',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                );
                              }
                              Future.delayed(const Duration(seconds: 2), () {
                                Navigator.pushReplacementNamed(
                                    context, LoginScreen.id);
                              });
                            },
                            child: _loading
                                ? LinearProgressIndicator(
                                    backgroundColor: Colors.transparent,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  )
                                : Text(
                                    'Reset Passoword',
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// Padding(
// padding: const EdgeInsets.all(3.0),
// child: TextFormField(
// controller: _passwordTextController,
// obscureText: true,
// validator: (value) {
// if (value.isEmpty) {
// return 'Enter New Password';
// }
// if (value.length < 6) {
// return 'Password should have at least 6 character';
// }
// return null;
// },
// decoration: InputDecoration(
// prefixIcon: Icon(
// Icons.vpn_key_outlined,
// color: Theme.of(context).primaryColor,
// ),
// labelText: 'New Password',
// contentPadding: EdgeInsets.zero,
// enabledBorder: OutlineInputBorder(),
// focusedBorder: OutlineInputBorder(
// borderSide: BorderSide(
// width: 2,
// color: Theme.of(context).primaryColor,
// ),
// ),
// focusColor: Theme.of(context).primaryColor,
// ),
// ),
// ),
// Padding(
// padding: const EdgeInsets.all(3.0),
// child: TextFormField(
// controller: _cPasswordTextController,
// obscureText: true,
// validator: (value) {
// if (value.isEmpty) {
// return 'Enter Confirm Password';
// }
// if (value.length < 6) {
// return 'Password should have at least 6 character';
// }
// if (_passwordTextController.text !=
// _cPasswordTextController.text) {
// return 'Password does not match';
// }
// setState(() {
// this.password = value;
// });
// return null;
// },
// decoration: InputDecoration(
// prefixIcon: Icon(
// Icons.vpn_key_outlined,
// color: Theme.of(context).primaryColor,
// ),
// labelText: 'Confirmation Password',
// contentPadding: EdgeInsets.zero,
// enabledBorder: OutlineInputBorder(),
// focusedBorder: OutlineInputBorder(
// borderSide: BorderSide(
// width: 2,
// color: Theme.of(context).primaryColor,
// ),
// ),
// focusColor: Theme.of(context).primaryColor,
// ),
// ),
// ),

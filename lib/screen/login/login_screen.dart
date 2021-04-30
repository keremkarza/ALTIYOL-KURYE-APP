import 'package:altiyol_kurye/providers/auth_provider.dart';
import 'package:altiyol_kurye/services/firebase_services.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

import '../home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'screen.login-screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  FirebaseServices _services = FirebaseServices();
  final _formKey = GlobalKey<FormState>();
  Icon icon;
  bool _visible = true;
  var _emailTextController = TextEditingController();
  var _passwordTextController = TextEditingController();
  String email;
  String password;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    Color _visibleColor = Theme.of(context).primaryColor;
    Color _invisibleColor = Colors.grey;
    final _authData = Provider.of<AuthProvider>(context);
    return SafeArea(
      child: Scaffold(
        body: Builder(
          builder: (context) => Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Center(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'GIRIS YAP',
                              style: TextStyle(
                                fontFamily: 'Anton',
                                fontSize: 30,
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            ClipOval(
                              child: Image.asset(
                                'images/logo_t.png',
                                height: 80,
                                width: 80,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Visibility(
                              visible: false,
                              child: InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, RegisterScreen.id);
                                },
                                child: Text(
                                  'KAYIT OL',
                                  style: TextStyle(
                                      fontFamily: 'Anton', fontSize: 30),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: _emailTextController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Email gir';
                          }
                          final bool _isValid = EmailValidator.validate(
                              _emailTextController.text);
                          if (!_isValid) {
                            return 'Emailde hata var';
                          }
                          if (mounted) {
                            setState(() {
                              this.email = value;
                            });
                          }
                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(),
                          contentPadding: EdgeInsets.zero,
                          hintText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 2,
                          )),
                          focusColor: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: _passwordTextController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Sifre giriniz';
                          }
                          if (value.length < 6) {
                            return 'En az 6 hane olacak';
                          }
                          if (mounted) {
                            setState(() {
                              this.password = value;
                            });
                          }
                          return null;
                        },
                        obscureText: _visible,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            color: _visible ? _invisibleColor : _visibleColor,
                            icon: Icon(Icons.remove_red_eye_outlined),
                            onPressed: () {
                              if (mounted) {
                                setState(() {
                                  _visible = !_visible;
                                });
                              }
                            },
                          ),
                          enabledBorder: OutlineInputBorder(),
                          contentPadding: EdgeInsets.zero,
                          hintText: 'Sifre',
                          prefixIcon: Icon(Icons.vpn_key_outlined),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 2,
                          )),
                          focusColor: Theme.of(context).primaryColor,
                        ),
                      ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.end,
                      //   children: [
                      //     TextButton(
                      //       onPressed: () {
                      //         Navigator.pushNamed(context, ResetPassword.id);
                      //       },
                      //       child: Text(
                      //         'Forgot Password ?',
                      //         style: TextStyle(
                      //             color: Colors.blue,
                      //             fontWeight: FontWeight.bold),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              style: TextButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).primaryColor),
                              onPressed: () {
                                if (_formKey.currentState.validate()) {
                                  EasyLoading.show(
                                      status: 'Lutfen bekleyin...');
                                  _services.validateUser(email).then((value) {
                                    if (value.exists) {
                                      if (value.data()['password'] ==
                                          password) {
                                        // EasyLoading.show(
                                        //     status: 'Logging in..');
                                        _authData
                                            .loginBoy(email, password)
                                            .then((credential) {
                                          if (credential != null) {
                                            EasyLoading.showSuccess(
                                                    'Islem basarili')
                                                .then((value) {
                                              Navigator.pushReplacementNamed(
                                                  context, HomeScreen.id);
                                            });
                                          } else {
                                            EasyLoading.showInfo(
                                                    'Kayit olma islemini bitirmek gerekiyor.')
                                                .then((value) {
                                              if (mounted) {
                                                _authData.getEmail(email);
                                                Navigator.pushNamed(
                                                    context, RegisterScreen.id);
                                              }
                                            });
                                            // Scaffold.of(context).showSnackBar(
                                            //     SnackBar(
                                            //         content:
                                            //             Text(_authData.error)));
                                          }
                                        });
                                      } else {
                                        EasyLoading.showError('Gecersiz sifre');
                                      }
                                    } else {
                                      EasyLoading.showError(
                                          '$email kayit olmamis');
                                    }
                                  });
                                }
                              },
                              child: _loading
                                  ? LinearProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                      backgroundColor: Colors.transparent,
                                    )
                                  : Text(
                                      'Giris Yap',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
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
      ),
    );
  }
}

import 'package:altiyol_kurye/screen/login/login_screen.dart';
import 'package:altiyol_kurye/screen/splash_screen.dart';
import 'package:altiyol_kurye/services/firebase_services.dart';
import 'package:altiyol_kurye/widgets/order_summary_card.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home-screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseServices _services = FirebaseServices();
  String status;
  User user = FirebaseAuth.instance.currentUser;
  int tag = 0;
  bool isOpen = false;
  List<String> options = [
    'All',
    'Accepted',
    'Picked Up',
    'On the way',
    'Delivered',
  ];
  List<String> optionsForText = [
    'Tümü',
    'Kabul Edildi',
    'Hazırlanıyor',
    'Yolda',
    'Teslim Edildi',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          child: Text(
            'GELEN SİPARİŞLER - ${isOpen == false ? 'KAPALI' : 'AÇIK'}',
            style: TextStyle(color: Colors.white),
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          Container(
            child: IconButton(
              icon: Icon(
                Icons.power_settings_new_outlined,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  isOpen = !isOpen;
                  print(isOpen);
                  _services.updateCarrierDataToDb(value: isOpen);
                });
              },
            ),
          ),
          Container(
            child: IconButton(
              icon: Icon(
                Icons.logout,
                color: Colors.white,
              ),
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return SplashScreen();
                }));
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 56,
            width: MediaQuery.of(context).size.width,
            child: ChipsChoice<int>.single(
              choiceStyle:
                  C2ChoiceStyle(borderRadius: BorderRadius.circular(3)),
              value: tag,
              onChanged: (val) {
                if (val == 0) {
                  setState(() {
                    status = null;
                  });
                }
                setState(() {
                  tag = val;

                  if (tag > 0) {
                    status = options[val];
                  }
                });
              },
              choiceItems: C2Choice.listFrom<int, String>(
                source: optionsForText,
                value: (i, v) => i,
                label: (i, v) => v,
              ),
            ),
          ),
          Container(
            child: StreamBuilder<QuerySnapshot>(
              stream: _services.orders
                  .where('deliveryBoy.email', isEqualTo: user.email)
                  .where('seller.orderStatus',
                      isEqualTo: tag == 0 ? null : status)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('birseyler ters gitti');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.data.size == 0) {
                  return Center(
                      child: Text('${optionsForText[tag]} siparis yok'));
                }
                if (!snapshot.hasData) {
                  return Center(child: Text('siparis yok'));
                }

                return Expanded(
                  child: new ListView(
                    children:
                        snapshot.data.docs.map((DocumentSnapshot document) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: new OrderSummaryCard(
                          document: document,
                          isOrder: true,
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget signOutButton() {
    return Container(
      width: 100,
      child: TextButton(
        onPressed: () async {
          await FirebaseAuth.instance.signOut().whenComplete(() {
            FirebaseAuth.instance.authStateChanges().listen((User user) {
              //print(user.toString());
              if (mounted) {
                setState(() {
                  if (user == null) {
                    print('user null');
                    Navigator.pushReplacementNamed(context, LoginScreen.id);
                  }
                });
              }
            });
          });
        },
        child: Text(
          'Cikis Yap',
          style: TextStyle(color: Colors.white),
        ),
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.resolveWith((states) => Colors.orange),
        ),
      ),
    );
  }
}

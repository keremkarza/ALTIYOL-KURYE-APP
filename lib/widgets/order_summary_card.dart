import 'package:altiyol_kurye/services/firebase_services.dart';
import 'package:altiyol_kurye/services/order_services.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderSummaryCard extends StatefulWidget {
  final DocumentSnapshot document;
  final bool isOrder;
  OrderSummaryCard({this.document, this.isOrder});

  @override
  _OrderSummaryCardState createState() => _OrderSummaryCardState();
}

class _OrderSummaryCardState extends State<OrderSummaryCard> {
  FirebaseServices _firebaseServices = FirebaseServices();

  GeoPoint shopLocation;
  DocumentSnapshot customerDocument;
  //GeoPoint customerLocation;
  @override
  void initState() {
    _firebaseServices
        .getCustomerDetails(widget.document.data()['userId'])
        .then((value) {
      if (value != null) {
        if (mounted) {
          if (widget.isOrder) {
            setState(() {
              customerDocument = value;
              //customerLocation = customerDocument.data()['location'];
            });
          }
        }
      } else {
        print('no data');
      }
    });
    super.initState();
  }

  _callNumber(number) async {
    //const number = '08592119XXXX'; //set the number here
    bool res = await FlutterPhoneDirectCaller.callNumber(number);
  }

  Future<void> _launchCall(String number) async {
    if (await canLaunch(number)) {
      await launch(number);
    } else {
      throw 'Could not launch $number';
    }
  }

  Color statusColor(DocumentSnapshot document) {
    if (document.data()['seller']['orderStatus'] == 'Accepted') {
      return Colors.blueGrey[400];
    } else if (document.data()['seller']['orderStatus'] == 'Rejected') {
      return Colors.red;
    } else if (document.data()['seller']['orderStatus'] == 'Picked Up') {
      return Colors.pink[900];
    } else if (document.data()['seller']['orderStatus'] == 'On the way') {
      return Colors.purple[900];
    } else if (document.data()['seller']['orderStatus'] == 'Delivered') {
      return Colors.green;
    } else {
      return Colors.orangeAccent;
    }
  }

  Icon statusIcon(DocumentSnapshot document) {
    if (document.data()['seller']['orderStatus'] == 'Accepted') {
      return Icon(Icons.check, color: statusColor(document), size: 18);
    } else if (document.data()['seller']['orderStatus'] == 'Rejected') {
      return Icon(Icons.highlight_remove_outlined,
          color: statusColor(document));
    } else if (document.data()['seller']['orderStatus'] == 'Picked Up') {
      return Icon(Icons.upgrade_outlined,
          color: statusColor(document), size: 18);
    } else if (document.data()['seller']['orderStatus'] == 'On the way') {
      return Icon(Icons.delivery_dining,
          color: statusColor(document), size: 18);
    } else if (document.data()['seller']['orderStatus'] == 'Delivered') {
      return Icon(Icons.shopping_bag_outlined,
          color: statusColor(document), size: 18);
    } else {
      return Icon(Icons.assignment_turned_in_outlined,
          color: statusColor(document), size: 18);
    }
  }

  Widget statusContainer(
      DocumentSnapshot document, OrderServices _orderServices, context) {
    //if (!widget.isOrder) {
    GeoPoint carrierLocation = document.data()['deliveryBoy'] == null
        ? GeoPoint(0, 0)
        : document.data()['deliveryBoy']['location'];
    double distanceInMeters = shopLocation == null
        ? 0.0
        : Geolocator.distanceBetween(
            shopLocation.latitude,
            shopLocation.longitude,
            carrierLocation.latitude,
            carrierLocation.longitude,
          );
    if (document.data()['deliveryBoy'] == null
        ? false
        : document.data()['deliveryBoy']['name'].length > 1) {
      if (document.data()['seller']['orderStatus'] == 'Accepted') {
        return Container(
          color: Colors.grey[200],
          height: 40,
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: TextButton(
                    child: Text(
                      'Hazırlanıyor',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      EasyLoading.show(status: 'Updating the status..');
                      _firebaseServices
                          .updateOrder(id: document.id, status: 'Picked Up')
                          .then((value) {
                        EasyLoading.showSuccess(
                            'Order Status is now Picked Up');
                      });
                      // // display delivery carriers
                      // showDialog(
                      //     context: context,
                      //     builder: (BuildContext context) {
                      //       return DeliveryCarriersList(
                      //           document: widget.document);
                      //     });
                      //
                      // print('assign');
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.all(8),
                      backgroundColor: statusColor(document),
                      elevation: 4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      if (document.data()['seller']['orderStatus'] == 'Picked Up') {
        return Container(
          color: Colors.grey[200],
          height: 40,
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: TextButton(
                    child: Text(
                      'Yolda',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      EasyLoading.show(status: 'Updating the status..');
                      _firebaseServices
                          .updateOrder(id: document.id, status: 'On the way')
                          .then((value) {
                        EasyLoading.showSuccess(
                            'Order Status is now On the way');
                      });
                      // // display delivery carriers
                      // showDialog(
                      //     context: context,
                      //     builder: (BuildContext context) {
                      //       return DeliveryCarriersList(
                      //           document: widget.document);
                      //     });
                      //
                      // print('assign');
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.all(8),
                      backgroundColor: statusColor(document),
                      elevation: 4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      if (document.data()['seller']['orderStatus'] == 'On the way') {
        return Container(
          color: Colors.grey[200],
          height: 40,
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: TextButton(
                    child: Text(
                      'Teslim Edildi',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      if (document.data()['cod'] == 1 ||
                          document.data()['cod'] == 2) {
                        showMyDialog('Ödemeyi Al', context, 'Delivered',
                            _orderServices, document.id);
                      }
                      //normal kısım
                      // EasyLoading.show(status: 'Updating the status..');
                      // _firebaseServices
                      //     .updateOrder(id: document.id, status: 'Delivered')
                      //     .then((value) {
                      //   EasyLoading.showSuccess(
                      //       'Order Status is now On the way');
                      // });

                      // // display delivery carriers
                      // showDialog(
                      //     context: context,
                      //     builder: (BuildContext context) {
                      //       return DeliveryCarriersList(
                      //           document: widget.document);
                      //     });
                      //
                      // print('assign');
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.all(8),
                      backgroundColor: statusColor(document),
                      elevation: 4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      if (document.data()['seller']['orderStatus'] == 'Delivered') {
        return Container(
          color: Colors.grey[200],
          height: 40,
          child: Row(
            children: [
              Expanded(
                child: TextButton(
                  child: Text(
                    'Sipariş Bitti',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    // if (document.data()['cod'] == 1) {
                    //   showMyDialog('Receive Payment', context, 'Delivered',
                    //       _orderServices, document.id);
                    // }
                    // EasyLoading.show(status: 'Updating the status..');
                    // _firebaseServices
                    //     .updateOrder(id: document.id, status: 'Delivered')
                    //     .then((value) {
                    //   EasyLoading.showSuccess('Order Status is now On the way');
                    // });
                    // // display delivery carriers
                    // showDialog(
                    //     context: context,
                    //     builder: (BuildContext context) {
                    //       return DeliveryCarriersList(
                    //           document: widget.document);
                    //     });
                    //
                    // print('assign');
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.all(8),
                    backgroundColor: statusColor(document),
                    elevation: 4,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      // bu kısım eskiden kalma ve vendora carrieri gösteriyor, bunun müşteriyi carriera göstereni olabilir.
      if (distanceInMeters > 2000) {
        return Container();
      }
      return document.data()['deliveryBoy'] == null
          ? Container()
          : ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 15,
                child: document.data()['deliveryBoy']['image'] == ''
                    ? Icon(
                        Icons.delivery_dining,
                        size: 24,
                        color: Colors.blue,
                      )
                    : Image.network(document.data()['deliveryBoy']['image']),
              ),
              trailing: Container(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {
                        MapsLauncher.launchCoordinates(carrierLocation.latitude,
                            carrierLocation.longitude);
                      },
                      icon: Icon(Icons.map,
                          color: Theme.of(context).primaryColor),
                    ),
                    IconButton(
                      onPressed: () {
                        _launchCall('tel:${document.data()['mobile']}');
                      },
                      icon: Icon(Icons.phone,
                          color: Theme.of(context).primaryColor),
                    ),
                  ],
                ),
              ),
              title: new Text(document.data()['deliveryBoy']['name']),
              // subtitle: Text(document
              //     .data()['${distanceInMeters.toStringAsFixed(2)} Metre']),
            );
    }
    //}

    return Container(
      color: Colors.grey[200],
      height: 40,
      child: Padding(
        padding: const EdgeInsets.only(left: 8, right: 8),
        child: Row(
          children: [
            Expanded(
              child: TextButton(
                child: Text(
                  'Kabul Et',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  showMyDialog('Accept Order', context, 'Accepted',
                      _orderServices, document.id);
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.all(8),
                  backgroundColor: Colors.blueGrey,
                  elevation: 4,
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: AbsorbPointer(
                absorbing:
                    document.data()['seller']['orderStatus'] == 'Rejected'
                        ? true
                        : false,
                child: TextButton(
                  child: Text(
                    'Reddet',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    showMyDialog('Reject Order', context, 'Rejected',
                        _orderServices, document.id);
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.all(8),
                    backgroundColor:
                        document.data()['seller']['orderStatus'] == 'Rejected'
                            ? Colors.grey
                            : Colors.red,
                    elevation: 4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print(widget.isOrder);
    OrderServices _orderServices = OrderServices();
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          //TODO: delete all isOrder related things
          widget.isOrder
              ? ListTile(
                  title: AutoSizeText(
                    _orderServices.statusString(widget.document),
                    style: TextStyle(
                      fontSize: 12,
                      color: statusColor(widget.document),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: AutoSizeText(
                    'Tarih : ${DateFormat.yMMMd().format(DateTime.parse(widget.document.data()['seller']['timeStamp']))}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 15,
                    child: statusIcon(widget.document),
                  ),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AutoSizeText(
                        'Ödeme Tipi : ${widget.document.data()['cod'] == 0 ? 'Online' : widget.document.data()['cod'] == 2 ? 'Kapıda Nakit' : 'Kapıda Kartla'}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AutoSizeText(
                        'Miktar : ${widget.document.data()['total']} TL',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              : Container(),
          customerDocument != null
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 0.1),
                    ),
                    child: ListTile(
                      title: Text(
                        'Musteri : ${customerDocument.data()['firstName']} ${customerDocument.data()['lastName']}',
                        style: TextStyle(color: Colors.black87),
                      ),
                      subtitle: Text(
                        'Adres : ${customerDocument.data()['address']}',
                        style: TextStyle(
                            fontFamily: 'Lato-Regular.ttf', fontSize: 13),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () {
                              _callNumber(
                                  'tel:${customerDocument.data()['number']}');
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: statusColor(widget.document),
                                ),
                                child: Icon(
                                  Icons.phone,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          InkWell(
                            onTap: () {
                              MapsLauncher.launchCoordinates(
                                  customerDocument.data()['latitude'],
                                  customerDocument.data()['longitude']);
                            },
                            child: Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: statusColor(widget.document),
                              ),
                              child: Icon(
                                Icons.map,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Container(),
          widget.isOrder
              ? ExpansionTile(
                  title: Text(
                    'Sipariş detaylari',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    'Sipariş detayi goruntule',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  children: [
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: ClipOval(
                              child: Image.network(widget.document
                                  .data()['products'][index]['productImage']),
                            ),
                          ),
                          title: Text(
                            widget.document.data()['products'][index]
                                ['productName'],
                            style: TextStyle(fontSize: 12),
                          ),
                          subtitle: Text(
                            '${widget.document.data()['products'][index]['qty']} x ${widget.document.data()['products'][index]['price'].toStringAsFixed(2)} TL = ${widget.document.data()['products'][index]['total'].toStringAsFixed(2)} TL',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                      itemCount: widget.document.data()['products'].length,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 12, right: 12, top: 8, bottom: 8),
                      child: Card(
                        elevation: 4,
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Satıcı : ',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    widget.document.data()['seller']
                                        ['shopName'],
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Indirim : ',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        '${widget.document.data()['discount']}',
                                        style: TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Text(
                                        'Indirim Kodu : ',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        widget.document
                                                    .data()['discountCode'] ==
                                                null
                                            ? 'YOK'
                                            : widget.document
                                                .data()['discountCode'],
                                        style: TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Text(
                                    'Teslimat Ucreti : ',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    '${widget.document.data()['deliveryFee'].toStringAsFixed(2)} TL',
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Container(),
          Divider(height: 3, color: Colors.grey),
          statusContainer(widget.document, _orderServices, context),
          Divider(height: 3, color: Colors.grey),
        ],
      ),
    );
  }

  showMyDialog(
      title, context, status, OrderServices _orderServices, documentId) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text('Ödemeyi aldığından emin ol ?'),
            actions: [
              TextButton(
                onPressed: () {
                  EasyLoading.show(status: 'Updating..');
                  _firebaseServices
                      .updateOrder(status: 'Delivered', id: documentId)
                      .then((value) {
                    EasyLoading.showSuccess('Order status is now Delivered');
                    Navigator.pop(context);
                  });
                },
                child: Text('ALDIM',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('HAYIR',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        });
  }
}

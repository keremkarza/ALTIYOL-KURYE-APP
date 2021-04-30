import 'package:cloud_firestore/cloud_firestore.dart';

class OrderServices {
  String statusString(DocumentSnapshot document) {
    if (document.data()['seller']['orderStatus'] == 'Accepted') {
      return "Kabul Edildi";
    } else if (document.data()['seller']['orderStatus'] == 'Rejected') {
      return "Reddedildi";
    } else if (document.data()['seller']['orderStatus'] == 'Picked Up') {
      return "Hazırlanıyor";
    } else if (document.data()['seller']['orderStatus'] == 'On the way') {
      return "Yolda";
    } else if (document.data()['seller']['orderStatus'] == 'Delivered') {
      return "Teslim Edildi";
    } else {
      return "Sipariş Verildi";
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseServices {
  CollectionReference boys = FirebaseFirestore.instance.collection('boys');
  CollectionReference orders = FirebaseFirestore.instance.collection('orders');
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<DocumentSnapshot> validateUser(id) async {
    DocumentSnapshot result = await boys.doc(id).get();
    return result;
  }

  Future<DocumentSnapshot> getCustomerDetails(userId) async {
    DocumentSnapshot doc = await users.doc(userId).get();
    return doc;
  }

  Future<void> updateCarrierDataToDb({value}) {
    User user = FirebaseAuth.instance.currentUser;
    DocumentReference _boys =
        FirebaseFirestore.instance.collection('boys').doc(user.email);
    _boys.update({
      'boyOpen': value, //sonra
    });
    return null;
  }

  Future<void> updateOrder({id, status}) {
    return orders.doc(id).update({
      'seller.orderStatus': status,
    });
  }
}

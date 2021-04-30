import 'dart:io';

import 'package:altiyol_kurye/screen/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';

class AuthProvider extends ChangeNotifier {
  File image;
  final picker = ImagePicker();
  String pickerError = '';
  bool isPicAvailable = false;
  String error = '';

  // shop data
  double boyLatitude;
  double shopLongitude;
  String boyAddress;
  String placeName;
  String email = '';
  String password = '';
  bool loading = false;

  CollectionReference _boys = FirebaseFirestore.instance.collection('boys');

  getEmail(email) {
    this.email = email;
    notifyListeners();
  }

  // isLoading() {
  //   this.loading = true;
  //   notifyListeners();
  // }

  Future<File> getImage() async {
    final pickedFile =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 15);
    if (pickedFile != null) {
      this.image = File(pickedFile.path);
      notifyListeners();
    } else {
      this.pickerError = 'No image selected.';
      print('No image selected.');
      notifyListeners();
    }
    return this.image;
  }

  Future getCurrentAddress() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    this.boyLatitude = _locationData.latitude;
    this.shopLongitude = _locationData.longitude;
    notifyListeners();

    // From coordinates
    final coordinates =
        new Coordinates(_locationData.latitude, _locationData.longitude);
    var _addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var shopAddress = _addresses.first;
    this.boyAddress = shopAddress.addressLine;
    this.placeName = shopAddress.featureName;
    notifyListeners();
    return shopAddress;
  }

  Future<UserCredential> registerBoys(email, password) async {
    this.email = email;
    notifyListeners();
    UserCredential userCredential;
    try {
      userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        this.error = 'The password provided is too weak.';
        notifyListeners();
      } else if (e.code == 'email-already-in-use') {
        this.error = 'The account already exists for that email.';
        notifyListeners();
      }
    } catch (e) {
      this.error = e.toString();
      notifyListeners();
      print(e);
    }
    return userCredential;
  }

  Future<UserCredential> loginBoy(email, password) async {
    this.email = email;
    notifyListeners();
    UserCredential userCredential;
    try {
      userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      this.error = e.code;
      notifyListeners();
    } catch (e) {
      this.error = e.code;
      notifyListeners();
      print(e);
    }
    return userCredential;
  }

  Future<void> resetBoyPassword(email) async {
    this.email = email;
    notifyListeners();
    UserCredential userCredential;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );
    } on FirebaseAuthException catch (e) {
      this.error = e.code;
      notifyListeners();
    } catch (e) {
      this.error = e.code;
      notifyListeners();
      print(e);
    }
    return userCredential;
  }

  Future<void> saveBoyDataToDb(
      {String url, String name, String mobile, String password, context}) {
    User user = FirebaseAuth.instance.currentUser;
    _boys.doc(this.email).update({
      'uid': user.uid,
      'url': url,
      'name': name,
      'password': password,
      'mobile': mobile,
      'address': '${this.placeName}: ${this.boyAddress}',
      'location': GeoPoint(this.boyLatitude, this.shopLongitude),
      'accVerified': false, // yalnızca kabul edilen kurye satış yapabilir
      'boyOpen': false, // kurye sistemi açıp kapatabilir
    }).whenComplete(() {
      // tüm bu süreçten sonra ana ekrana yönlendirecek
      Navigator.pushReplacementNamed(context, HomeScreen.id);
    });
    return null;
  }
}

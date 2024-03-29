import 'dart:io';

import 'package:altiyol_kurye/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShopPicCard extends StatefulWidget {
  @override
  _ShopPicCardState createState() => _ShopPicCardState();
}

class _ShopPicCardState extends State<ShopPicCard> {
  File _image;
  @override
  Widget build(BuildContext context) {
    final _authData = Provider.of<AuthProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: InkWell(
        onTap: () {
          _authData.getImage().then((image) {
            setState(() {
              _image = image;
              if (image != null) {
                _authData.isPicAvailable = true;
              }
              //print(_image.path);
            });
          });
        },
        child: SizedBox(
          height: 150,
          width: 150,
          child: Card(
              child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: _image == null
                ? Center(
                    child: Text(
                      'Resim Ekle', // resim yokken
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : Image.file(_image, fit: BoxFit.fill), // resim geldikten sonra
          )),
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:image_gallery/image_gallery.dart';
import 'package:simple_permissions/simple_permissions.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => MyAppState();

}

class MyAppState extends State<MyApp> {

  List<String> imagesPath;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: <Widget>[
            RaisedButton(
                onPressed: _fetchPhotos,
                child: new Text("Request permission")
            ),
            _buildGridView(),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView() {
    if (this.imagesPath != null) {
      return Expanded(
        child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 1,
              mainAxisSpacing: 1,
              childAspectRatio: (124 / 124),
            ),
            padding: EdgeInsets.all(1),
            itemCount: this.imagesPath.length,
            itemBuilder: (context, index) {
              return _getImage(index);
            }
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _getImage(int index) {
    return FutureBuilder<Image>(
      future: _openImageFromDisk(index),
      builder: (BuildContext context, AsyncSnapshot<Image> snapshot) {
        return snapshot.data ?? CircularProgressIndicator();
      });
  }

  Future<Image> _openImageFromDisk(int index) async {
    return Image.file(
      File(this.imagesPath[index]),
      fit: BoxFit.cover,
    );
  }

  void _requestPermissionAndFetchPhotos() async {
    bool hasPermission = await SimplePermissions.checkPermission(Permission.ReadExternalStorage);
    if (hasPermission) {
      _fetchPhotos();
    } else {
      final response = await SimplePermissions.requestPermission(Permission.ReadExternalStorage);
      if (response == PermissionStatus.authorized) {
        _fetchPhotos();
      }
    }
  }

  void _fetchPhotos() async {
    final images = await ImageGallery.imagesFromGallery;
    /*final imagesPath = <String>[];
    galleryImages.forEach((galleryImage) {
      imagesPath.addAll(galleryImage.imagesPath);
    });*/
    setState(() {
      this.imagesPath = images;
    });
  }

}
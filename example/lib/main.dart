import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_gallery/image_gallery.dart';

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

  void _fetchPhotos() async {
    final images = await ImageGallery.imagesFromGallery;
    setState(() {
      this.imagesPath = images;
    });
  }

}
import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _pickedImage;
  Uint8List webImage=Uint8List(8);

  Future<void> handleImagePicker() async {
    // print("K is web");
    if(!kIsWeb){
      final permStatus=await Permission.mediaLibrary.request();
      if(!permStatus.isGranted){
        print("Cannot access photo gallery");
        return;
      }
      final ImagePicker _picker=ImagePicker();
      XFile? image= await _picker.pickImage(source: ImageSource.gallery);
      if(image!=null){
        var selected=File(image.path);
        setState(() {
          _pickedImage=selected;
        });
      }else{
        print("No image has been picked");
      }
    }else if(kIsWeb){
      final ImagePicker _picker=ImagePicker();
      XFile? image= await _picker.pickImage(source: ImageSource.gallery);
      if(image!=null){
        var file=await image.readAsBytes();
        setState(() {
          // webImage=file;
          _pickedImage=File.fromRawPath(file);
        });
      }else{
        print("No image has been picked");
      }
    }else{
      print("Something went wrong");
    }

  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double _getSize(defaultSize, minSize, maxSize){
      double currentSize=defaultSize*width;
      if(currentSize<minSize) return minSize;
      else if(currentSize>maxSize) return maxSize;
      else return currentSize;
    }
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Click the button to select an image',
            ),
            const SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  width: _getSize(0.5, 100, 300),
                  height: _getSize(0.5, 100, 300),
                  color: Colors.grey.withAlpha(30),
                  child: Center(
                    child: IconButton(
                      onPressed: (){
                        handleImagePicker();
                      },
                      iconSize: 50,
                      icon: const Icon(
                        Icons.add,
                        // size: 50,
                      ),
                    ),
                  ),
                ),
                if(_pickedImage!=null)
                Container(
                  width: _getSize(0.5, 100, 300),
                  height: _getSize(0.5, 100, 300),
                  child: Image.network(_pickedImage!.path, fit: BoxFit.fill),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

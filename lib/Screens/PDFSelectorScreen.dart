import 'dart:io';
import 'dart:html' as html;
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';

import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import "package:file_picker/file_picker.dart";
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';

class PDFSelectorScreen extends StatefulWidget {
  const PDFSelectorScreen({super.key});

  @override
  State<StatefulWidget> createState() => _PDFSelecterScreen();
}

class _PDFSelecterScreen extends State<PDFSelectorScreen> {
  String fileName = "";
  bool isFilePicked=false;
  Uint8List fileBytes=Uint8List(8);
  String path="";

  Future<void> handlePDFPicker() async {
    FilePickerResult? pickedFile=await FilePicker.platform.pickFiles();

    if (pickedFile != null) {
      if(!kIsWeb){
        File file=File(pickedFile.files.single.path.toString());
        fileBytes=file.readAsBytesSync();
        String name=file.path.split('/').last;
        path=file.path.toString();

        print('Name: $name\nSize: ${fileBytes.length}');
        setState(() {
          fileName=name;
          isFilePicked=true;
        });
      }else{
        PlatformFile file = pickedFile.files.first;
        fileBytes=file.bytes!;
        print('Name: ${file.name}\nSize: ${file.size}');
        setState(() {
          fileName=file.name;
          isFilePicked=true;
        });
      }
    } else {
      print("Unable to pick files");
    }
  }

  Future<void> uploadFile() async {
    var uri=Uri.parse("http://localhost:5000/image_upload");
    try{
      if(!isFilePicked) {
        throw Exception("No file is picked");
      }
      var request=MultipartRequest('POST', uri)
        ..fields['data']='this is the data'
        ..files.add(MultipartFile.fromBytes('image', fileBytes,
            filename: fileName,
            contentType: MediaType("application", "pdf")
        )
        );
      var response=await request.send();
      if(response.statusCode==200) {
        print("File uploaded successfully");
      }
    }catch(error){
      print(error);
    }
  }
  Future<void> handleViewPdf() async{
    try{
      if(kIsWeb){
        final blob = html.Blob([fileBytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.window.open(url,'_blank');
        html.Url.revokeObjectUrl(url);
      }else{
        print('[85]: $path');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PdfView(path: path)
          )
        );
      }
    }catch(e){
      print(e);
    }

  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    double _getSize(defaultSize, minSize, maxSize) {
      double currentSize = defaultSize * width;
      if (currentSize < minSize) {
        return minSize;
      } else if (currentSize > maxSize) {
        return maxSize;
      } else {
        return currentSize;
      }
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Click the button to select a PDF ',
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
                  width: _getSize(0.4, 100, 300),
                  height: _getSize(0.4, 100, 300),
                  color: Colors.grey.withAlpha(30),
                  child: Center(
                    child: IconButton(
                      onPressed: () async {
                       await handlePDFPicker();
                      },
                      iconSize: 50,
                      icon: const Icon(
                        Icons.add,
                        // size: 50,
                      ),
                    ),
                  ),
                ),
                if (isFilePicked)
                  Container(
                    color: Colors.grey.withAlpha(30),
                    margin:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    width: _getSize(0.4, 100, 300),
                    height: _getSize(0.4, 100, 300),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.picture_as_pdf_rounded,
                          size: 50,
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        SizedBox(
                          width: 200,
                          child: Center(
                            child:TextButton(
                                onPressed: handleViewPdf,
                                child: Text(fileName)
                            ),
                          ),
                        )

                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            TextButton(
                onPressed: uploadFile,
                child: const Text('Upload PDF file to the server'))
          ],
        ),
      ),
    );
  }
}

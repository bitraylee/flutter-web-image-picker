import 'package:flutter/material.dart';
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';

class PdfViewer extends StatelessWidget {
  const PdfViewer({Key? key,required this.path}) : super(key: key);
  final String path;

  @override
  Widget build(BuildContext context) {
    return PdfView(path: path);
  }
}
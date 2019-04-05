import 'package:flutter/material.dart';
import 'package:ml_app/screens/home_screen.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:ml_app/models/recognizer_model.dart';

void main() async {
  RecognizerModel model = RecognizerModel();
  model.loadModel();
  await model.getCameras();
  runApp(MLApp(
    model: model,
  ));
}

class MLApp extends StatelessWidget {
  final RecognizerModel model;

  const MLApp({Key key, this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: this.model,
      child: MaterialApp(
        title: "Image Recognizer",
        home: HomeScreen(),
        theme: ThemeData(
          primaryColor: const Color(0xFF304FFE),
          accentColor: const Color(0xFFFFEA00),
          fontFamily: 'Google Sans',
        ),
      ),
    );
  }
}

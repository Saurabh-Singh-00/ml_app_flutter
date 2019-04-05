import 'dart:io';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:ml_app/models/recognizer_model.dart';
import 'package:camera/camera.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File _file;

  Future<String> takePicture(RecognizerModel model) async {
    if (!model.cameraController.value.isInitialized) {
      return null;
    }
    final Directory extDir = await model.imagePath;
    final String dirPath = '${extDir.path}/Pictures/';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${DateTime.now().toIso8601String()}.jpg';

    if (model.cameraController.value.isTakingPicture) {
      return null;
    }

    try {
      await model.cameraController.takePicture(filePath);
      File _file = await File(filePath).create(recursive: true);
    } on CameraException catch (e) {
      return null;
    }
    return filePath;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<RecognizerModel>(
      builder: (BuildContext context, Widget child, RecognizerModel model) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Image Recognizer"),
            centerTitle: true,
            elevation: .0,
          ),
          body: !model.cameraController.value.isInitialized
              ? Container(
                  child: Center(
                    child: Text("Camera Not Initialized"),
                  ),
                )
              : Flex(
                  direction: Axis.vertical,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: model.cameraController.value.aspectRatio,
                        child: CameraPreview(model.cameraController),
                      ),
                    ),
                  ],
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              String _imagePath = await takePicture(model);
              if (_imagePath != null) {
                model.isRecognizing
                    ? CircularProgressIndicator()
                    : showModalBottomSheet(
                        context: context,
                        builder: (BuildContext ctx) {
                          return FutureBuilder(
                              future: model.classifyImage(File(_imagePath)),
                              builder: (BuildContext fCtx,
                                  AsyncSnapshot<List> snapshot) {
                                if (snapshot.hasData) {
                                  if (snapshot.data.isEmpty) {
                                    return Center(
                                        child: Text("Cannot recognize Image"));
                                  } else {
                                    return ListView.separated(
                                        physics: ClampingScrollPhysics(),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 4.0),
                                        separatorBuilder: (sCtx, pos) =>
                                            Divider(
                                              height: 2.0,
                                            ),
                                        itemCount: snapshot.data.length,
                                        itemBuilder: (lCtx, pos) {
                                          return Material(
                                            child: ListTile(
                                              title: Text(snapshot.data[pos]
                                                  ['detectedClass']),
                                              trailing: Text((snapshot.data[pos]
                                                              [
                                                              'confidenceInClass'] *
                                                          100)
                                                      .toString() +
                                                  "%"),
                                            ),
                                          );
                                        });
                                  }
                                } else if (snapshot.hasError) {
                                  return Center(
                                    child: Text(
                                        "There's some problem, Please try again"),
                                  );
                                }
                                return CircularProgressIndicator();
                              });
                        });
              }
            },
            elevation: .5,
            child: Icon(
              Icons.photo_camera,
              color: Colors.black87,
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }
}

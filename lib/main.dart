import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'Shreyash TechnoSoft'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future _futureGetPath;
  List<dynamic> listImagePath = List<dynamic>();
  var _permissionStatus;
  var path;
  var folderName = "assignment_task";
  String firstButtonText;
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _createFolder();
    _listenForPermissionStatus();
    _futureGetPath = _getPath();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.blue),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
              child: FutureBuilder(
                future: _futureGetPath,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    var dir = Directory(snapshot.data);
                    if (_permissionStatus) _fetchFiles(dir);
                    if(listImagePath.length == 0 ||listImagePath.isEmpty){
                      return Center(
                        child: Text("No Images in Folder ... ", style: TextStyle(
                            color: Colors.blue
                        ),),
                      );
                    }else
                    return GridView.count(
                      primary: false,
                      padding: const EdgeInsets.all(0),
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                      crossAxisCount: 2,
                      children: _getListImg(listImagePath),
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getImage(ImageSource.camera);
        },
        child: Icon(
          Icons.camera,
          color: Colors.white,
          size: 29,
        ),
        backgroundColor: Colors.blue,
        tooltip: 'Capture Picture',
        elevation: 5,
        splashColor: Colors.grey,
      ),
    );
  }

  void getImage(ImageSource imageSource) async {
    PickedFile imageFile = await picker.getImage(source: imageSource);
    if (imageFile == null) return;
    File tmpFile = File(imageFile.path);
    final appDir = await getApplicationDocumentsDirectory();
    var localFile = await tmpFile.copy(
        'storage/emulated/0/assignment_task/${listImagePath.length + 1}.jpg');
    setState(() {
      var _image = localFile;
      print(_image);
    });
  }

  _createFolder() async {
    path = Directory("storage/emulated/0/$folderName");
    if ((await path.exists())) {
      // TODO:
      print("exist");
    } else {
      // TODO:
      print("not exist");
      path.create();
    }
  }

  void _listenForPermissionStatus() async {
    final status = await Permission.storage.request().isGranted;
    setState(() => _permissionStatus = status);
  }

  Future<String> _getPath() {
    return ExtStorage.getExternalStoragePublicDirectory(folderName);
  }

  _fetchFiles(Directory dir) {
    List<dynamic> listImage = List<dynamic>();
    dir.list().forEach((element) {
      RegExp regExp =
          new RegExp("\.(gif|jpe?g|tiff?|png|webp|bmp)", caseSensitive: false);
      if (regExp.hasMatch('$element')) listImage.add(element);
      setState(() {
        listImagePath = listImage;
      });
    });
    listImage.reversed;
  }

  List<Widget> _getListImg(List<dynamic> listImagePath) {
    List<Widget> listImages = List<Widget>();
    for (var imagePath in listImagePath) {
      listImages.add(
        Container(
          //padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
          color: Colors.transparent,
          child: Card(
              elevation: 0,
              color: Colors.transparent,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(24.0),
                  child: Image.file(imagePath, fit: BoxFit.cover))),
        ),
      );
    }
    return listImages;
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class UploadPage extends StatefulWidget {
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File? file;

  captureImageWithCamera() async{
    Navigator.pop(context);
    PickedFile? imageFile = await ImagePicker().getImage(
        source: ImageSource.camera,
        imageQuality: 50
    );
    setState(() {
      file = File(imageFile!.path);
    });
  }

  pickImageFromGallery() async{
    Navigator.pop(context);
    PickedFile? imageFile = await ImagePicker().getImage(
        source: ImageSource.gallery,
        imageQuality: 50
    );
    setState(() {
      file = File(imageFile!.path);
    });
  }

  takeImage(mContext){
    return showDialog(
        context: mContext,
        builder: (context){
          return SimpleDialog(
            title: const Text("New Post", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            children: <Widget>[
              SimpleDialogOption(
                child: const Text("Capture Image with Camera", style: TextStyle(color: Colors.black, fontSize: 18.0)),
                onPressed: captureImageWithCamera,
              ),
              SimpleDialogOption(
                child: const Text("Select Image from Gallery", style: TextStyle(color: Colors.black, fontSize: 18.0)),
                onPressed: pickImageFromGallery,
              ),
              SimpleDialogOption(
                child: const Text("Cancel", style: TextStyle(color: Colors.black, fontSize: 18.0)),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        }
    );
  }

  Widget displayUploadScreen(){
    return Container(
      color: Theme.of(context).primaryColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(Icons.add_photo_alternate, color: Colors.black, size: 200.0),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: ElevatedButton(
              style:ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(9.0)),
                  ),
                backgroundColor:MaterialStateProperty.all(Colors.blue)
              ),
              child: const Text("Upload Image", style: TextStyle(color: Colors.black, fontSize: 20.0)),
              onPressed: () => takeImage(context),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return displayUploadScreen();
  }
}

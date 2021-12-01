import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:netpix/models/user.dart';
import 'package:image/image.dart' as ImD;
import 'package:netpix/widgets/progress_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'home_page.dart';

class UploadPage extends StatefulWidget {
  final User gCurrentUser;

  UploadPage({required this.gCurrentUser});

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> with AutomaticKeepAliveClientMixin<UploadPage>{
  File? file;
  bool uploading = false;
  String postId = const Uuid().v4();
  TextEditingController descriptionTextEditingController = TextEditingController();

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

  clearPostInfo(){
    descriptionTextEditingController.clear();

    setState(() {
      file = null;
    });
  }

  compressingPhoto() async{
    final tDirectory = await getTemporaryDirectory();
    final path = tDirectory.path;
    ImD.Image? mImageFile = ImD.decodeImage(file!.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')..writeAsBytesSync(ImD.encodeJpg(mImageFile!, quality: 60));
    setState(() {
      file = compressedImageFile;
    });
  }

  savePostInfoToFireStore({required String url, required String description}){
    postsReference.doc(widget.gCurrentUser.id).collection("userPosts").doc(postId).set({
      "postId": postId,
      "ownerId": widget.gCurrentUser.id,
      "timestamp": DateTime.now(),
      "likes": {},
      "profileName": widget.gCurrentUser.profileName,
      "username": widget.gCurrentUser.username,
      "description": description,
      "url": url
    });
    savePostsToTimeline(postId);
  }

  savePostsToTimeline(String id) async {
    QuerySnapshot querySnapshot = await followersReference.doc(currentUser!.id).collection("userFollowers").get();
    DocumentSnapshot post = await postsReference.doc(currentUser!.id).collection("userPosts").doc(id).get();
    for (var document in querySnapshot.docs) {
      if(document.exists){
        timelineReference.doc(document.id).collection("timelinePosts").doc(postId).set(post.data() as Map<String, dynamic>);
      }
    }
  }

  controlUploadAndSave() async {
    setState(() {
      uploading = true;
    });
    await compressingPhoto();
    String downloadUrl = await uploadPhoto(file);
    savePostInfoToFireStore(url: downloadUrl, description: descriptionTextEditingController.text);
    descriptionTextEditingController.clear();
    setState(() {
      file = null;
      uploading = false;
      postId = const Uuid().v4();
    });
  }

  Future <String> uploadPhoto(mImageFile) async {
    UploadTask storageUploadTask = storageReference.child("post_$postId.jpg").putFile(mImageFile);
    TaskSnapshot storageTaskSnapshot = await storageUploadTask;
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }


  Widget displayUploadFormScreen(){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: clearPostInfo),
        title: const Text("New Post", style: TextStyle(fontSize: 24.0, color: Colors.white, fontWeight: FontWeight.bold)),
        actions: <Widget>[
          TextButton(
            onPressed: uploading ? null : () => controlUploadAndSave(),
            child: const Text("Share", style: TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.bold, fontSize: 16.0)),
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          uploading ? linearProgress() : const Text(""),
          SizedBox(
            height: 230.0,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16/9,
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(image: FileImage(file!), fit: BoxFit.cover)
                  ),
                ),
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.only(top: 12.0)),
          ListTile(
            leading: CircleAvatar(backgroundImage: CachedNetworkImageProvider(widget.gCurrentUser.url)),
            title: Container(
              width: 250.0,
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent),
                  borderRadius: const BorderRadius.all(Radius.circular(5))
              ),
              child: TextField(
                style: const TextStyle(color: Colors.black),
                controller: descriptionTextEditingController,
                decoration: const InputDecoration(
                  hintText: "Write a caption...",
                  hintStyle: TextStyle(color: Colors.black),
                  border: InputBorder.none,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return file == null ? displayUploadScreen(): displayUploadFormScreen();
  }
}

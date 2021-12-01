import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:netpix/widgets/header_page.dart';
import 'package:netpix/widgets/progress_widget.dart';
import 'package:timeago/timeago.dart' as tAgo;

import 'home_page.dart';

class CommentsPage extends StatefulWidget {
  final String postId, postOwnerId, postImageUrl;

  CommentsPage({required this.postId, required this.postOwnerId, required this.postImageUrl});

  @override
  CommentsPageState createState() => CommentsPageState(postId: this.postId, postOwnerId: this.postOwnerId, postImageUrl: this.postImageUrl);
}

class CommentsPageState extends State<CommentsPage> {

  final String postId, postOwnerId, postImageUrl;
  TextEditingController commentTextEditingController = TextEditingController();

  CommentsPageState({required this.postId, required this.postOwnerId, required this.postImageUrl});

  retrieveComments(){
    return StreamBuilder<QuerySnapshot>(
      stream: commentsReference.doc(postId).collection("comments").orderBy("timestamp", descending: false).snapshots(),
      builder: (context, dataSnapshot){
        if(!dataSnapshot.hasData){
          return circularProgress();
        }

        List<Comment> comments = [];
        for (var document in dataSnapshot.data!.docs) {
          comments.add(Comment.fromDocument(document));
        }

        return ListView(
          children: comments,
        );
      },
    );
  }

  saveComment(){
    commentsReference.doc(postId).collection("comments").add({
      "profileName": currentUser!.profileName,
      "userId": currentUser!.id,
      "comment": commentTextEditingController.text,
      "url": currentUser!.url,
      "timestamp": DateTime.now(),
    });

    bool isNotPostOwner = currentUser!.id != postOwnerId;

    if(isNotPostOwner){
      activityFeedReference.doc(postOwnerId).collection("feedItems").add({
        "type": "comment",
        "commentData": commentTextEditingController.text,
        "postId": postId,
        "userId": currentUser!.id,
        "profileName": currentUser!.profileName,
        "userProfileImg": currentUser!.url,
        "url": postImageUrl,
        "timestamp": DateTime.now()
      });
    }
    commentTextEditingController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, strTitle: "Comments"),
      body: Column(
        children: <Widget>[
          Expanded(child: retrieveComments(),),
          const Divider(),
          ListTile(
            title: TextFormField(
              controller: commentTextEditingController,
              decoration: const InputDecoration(
                  labelText: "Write your comment here...",
                  labelStyle: TextStyle(color: Colors.black),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black))
              ),
              style: const TextStyle(color: Colors.black),
            ),
            trailing: OutlineButton(
              onPressed: saveComment,
              borderSide: BorderSide.none,
              child: const Text("Publish", style: TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String profileName, userId, url, comment;
  final Timestamp timestamp;

  Comment({required this.profileName, required this.userId, required this.url, required this.comment, required this.timestamp});

  factory Comment.fromDocument(DocumentSnapshot documentSnapshot){
    return Comment(
      profileName: documentSnapshot["profileName"],
      userId: documentSnapshot["userId"],
      comment: documentSnapshot["comment"],
      url: documentSnapshot["url"],
      timestamp: documentSnapshot["timestamp"],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.0),
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text(profileName + ":   " + comment, style: const TextStyle(fontSize: 18.0, color: Colors.black)),
              leading: CircleAvatar(backgroundImage: CachedNetworkImageProvider(url)),
              subtitle: Text(tAgo.format(timestamp.toDate()), style: const TextStyle(color: Colors.black)),
            )
          ],
        ),
      ),
    );
  }
}
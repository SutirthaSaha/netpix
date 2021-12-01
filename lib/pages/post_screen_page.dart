import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:netpix/widgets/header_page.dart';
import 'package:netpix/widgets/post_widget.dart';
import 'package:netpix/widgets/progress_widget.dart';

import 'home_page.dart';

class PostScreenPage extends StatelessWidget {
  final String userId, postId;
  PostScreenPage({required this.userId, required this.postId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: postsReference.doc(userId).collection("userPosts").doc(postId).get(),
      builder: (context, dataSnapshot){
        if(!dataSnapshot.hasData){
          return circularProgress();
        }
        Post post = Post.fromDocument(dataSnapshot.data!);
        return Center(
          child: Scaffold(
            appBar: header(context, strTitle: post.description),
            body: ListView(
              children: <Widget>[
                Container(
                  child: post,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
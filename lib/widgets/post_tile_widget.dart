import 'package:flutter/material.dart';
import 'package:netpix/pages/post_screen_page.dart';
import 'package:netpix/widgets/post_widget.dart';

class PostTile extends StatelessWidget {
  final Post post;

  PostTile({required this.post});

  displayFullPost(context){
    Navigator.push(context, MaterialPageRoute(builder: (context)=> PostScreenPage(postId: post.postId, userId: post.ownerId)));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=> displayFullPost(context),
      child: Image.network(post.url),
    );
  }
}
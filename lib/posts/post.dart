import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_forum/components/comment_button.dart';
import 'package:school_forum/components/like_button.dart';
import 'package:school_forum/helper/helper.dart';

import '../components/comment.dart';

class Post extends StatefulWidget {
  final String message;
  final String user;
  final String postId;
  final String time;
  final List<String> likes;

  const Post({
    super.key,
    required this.message,
    required this.user,
    required this.postId,
    required this.likes,
    required this.time,
  });

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  late bool isLiked =false;
  late int likeCount;

  //comment text controller
  final _commentTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
    likeCount = widget.likes.length;
  }

  // toggle like
  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
      if (isLiked) {
        likeCount++;
      } else {
        likeCount--;
      }
    });

    // Access the document in Firebase
    DocumentReference postRef =
    FirebaseFirestore.instance.collection('User_Posts').doc(widget.postId);

    if (isLiked) {
      // if post is liked now, add the user's email to the 'Likes' field
      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser.email])
      });
    } else {
      // if post is unliked, remove the user's email from the 'Likes' field
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser.email])
      });
    }
  }
//add a comment
  void addComment(String commentText){
    //write the comment to fire store under the comment collection  for this post
    FirebaseFirestore.instance
        .collection("User_Posts")
        .doc(widget.postId)
        .collection("Comments")
        .add({
      "CommentText": commentText,
      "CommentedBy": currentUser.email,
      "CommentTime": Timestamp.now() //remember to format this when displaying
    });
  }


//show a dialog box for adding comment
void showCommentDialog(){
    showDialog(context: context, builder: (context) => AlertDialog(
      title: Text ("Add Comment"),
      content: TextField(
        controller: _commentTextController ,
        decoration: InputDecoration(
          hintText: "Write a comment..."
        ),
      ),
      actions: [
        //cancel button
        TextButton(onPressed: () {
            //pop box
            Navigator.pop(context);
            //clear controller
          _commentTextController.clear();
            },
          child: Text("Cancel"),
        ),

        //post button
        TextButton(onPressed: ()   {
          //add comment
          addComment(_commentTextController.text);


          //pop box
          Navigator.pop(context);

          //clear controller
          _commentTextController.clear();

          },
          child: Text("Post"),
        ),
      ],
    ),
    );
}


  @override
  Widget build(BuildContext context) {
    return Container(
      height:280,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.only(top: 25, left: 25 , right: 25),
      padding: const EdgeInsets.all(25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        //new feed page
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Message and username
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                //user
                Text(
                  widget.user,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),

                //message
                Text(
                  widget.message,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                //user,time
                Row(
                  children: [
                    Text(widget.user,style: TextStyle(color: Colors.grey)),

                    Text(" . ",style: TextStyle(color: Colors.grey)),
                    Text(widget.time,style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          //button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              //like
              Column(
                children: [
                  // like button
                  LikeButton(
                    isLiked: isLiked,
                    onTap: toggleLike,
                  ),

                  const SizedBox(height: 5),

                  // like count
                  Text(
                    likeCount.toString(),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(width: 10),
              //comment
              Column(
                children: [
                  // comment button
                 CommentButton(onTap: showCommentDialog),

                  const SizedBox(height: 5),

                  // comment count
                  Text(
                    '0',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),

          //comment under the count
          FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance.collection("User_Posts").doc(widget.postId).collection("Comments").orderBy("CommentTime",descending: true).get(),
            builder: (context,snapshot){


              //show loading circle if no data yet
              if(!snapshot.hasData){
                return const Center(
                  child: SizedBox(),
                );
              }

              return ListView(
                shrinkWrap: true, // for nested lists
                physics: const NeverScrollableScrollPhysics(),
                children: snapshot.data!.docs.map((doc) {
                  // get the comment
                  final commentData = doc.data() as Map<String,dynamic>;

                  // return the comment widget
                  return Comment(
                    text: commentData["CommentText"],
                    user: commentData["CommentedBy"],
                    time: formatDate(commentData["CommentTime"]),
                  );
                }).toList(),
              );
              },
            )
        ],
      ),
    );
  }
}

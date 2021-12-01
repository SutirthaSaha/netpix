import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:netpix/pages/profile_page.dart';
import 'package:netpix/pages/search_page.dart';
import 'package:netpix/pages/timeline_page.dart';
import 'package:netpix/pages/upload_page.dart';
import 'package:netpix/models/user.dart';

import 'create_account_page.dart';
import 'notifications_page.dart';


final GoogleSignIn gSignIn = GoogleSignIn();
final usersReference = FirebaseFirestore.instance.collection("users");
final Reference storageReference = FirebaseStorage.instance.ref().child("Posts Pictures");
final postsReference = FirebaseFirestore.instance.collection("posts");
User? currentUser;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isSignedIn = false;
  late PageController pageController;
  int getPageIndex = 0;

  @override
  void initState() {
    super.initState();

    pageController = PageController();

    gSignIn.onCurrentUserChanged.listen((gSignInAccount){
      controlSignIn(gSignInAccount);
    },onError: (gError){
      print("Error:"+ gError.toString());
    });
    gSignIn.signInSilently(suppressErrors: false).then((gSignInAccount){
      controlSignIn(gSignInAccount);
    }).catchError((gError){
      isSignedIn = false;
      print("Error:"+gError.toString());
    });
  }
  controlSignIn(GoogleSignInAccount? signInAccount) async{
    if (signInAccount!=null){
      await saveUserInfoToFireStore();
      setState(() {
        isSignedIn = true;
      });
    }else{
      setState(() {
        isSignedIn = false;
      });
    }
  }

  loginUser(){
    gSignIn.signIn();
  }

  logoutUser(){
    gSignIn.signOut();
  }

  whenPageChanges(int index){
    setState(() {
      getPageIndex = index;
    });
  }

  onTapChangePage(int index){
    pageController.animateToPage(index, duration: const Duration(milliseconds: 400), curve: Curves.bounceInOut);
  }

  @override
  Widget build(BuildContext context) {
    if (isSignedIn){
      return buildHomeScreen();
    }else{
      return buildSignInScreen();
    }
  }

  Widget buildHomeScreen() {
    // return ElevatedButton.icon(onPressed: logoutUser, icon: const Icon(Icons.close), label: const Text("Sign Out"));
    return Scaffold(
      body: PageView(
        children: <Widget>[
          TimelinePage(),
          const SearchPage(),
          UploadPage(gCurrentUser: currentUser!),
          NotificationsPage(),
          ProfilePage(userProfileId: currentUser!.id)
        ],
        controller: pageController,
        onPageChanged: whenPageChanges,
        physics: const NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: getPageIndex,
        onTap: onTapChangePage,
        selectedItemColor: Colors.black87,
        unselectedItemColor: Colors.black12,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: "Add Post"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notifications"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget buildSignInScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "NetPix",
              style: TextStyle(fontSize: 92.0, color:Colors.black, fontFamily: "GrandHotel")
            ),
            GestureDetector(
              onTap: ()=>loginUser(),
              child: Container(
                width: 270.0,
                height: 65.0,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/google_signin_button.png"
                      )
                  )
                ),
              ),
            )
          ],
        )
      ),
    );
  }

  saveUserInfoToFireStore() async {
    final GoogleSignInAccount? gCurrentUser = gSignIn.currentUser;
    DocumentSnapshot documentSnapshot = await usersReference.doc(gCurrentUser!.id.toString()).get();

    if(!documentSnapshot.exists){
      final username = await Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateAccountPage()));
      usersReference.doc(gCurrentUser.id).set({
        "id":gCurrentUser.id,
        "profileName":gCurrentUser.displayName,
        "username": username,
        "url": gCurrentUser.photoUrl,
        "email": gCurrentUser.email,
        "bio": "",
        "timestamp": DateTime.now()
      });
      documentSnapshot = await usersReference.doc(gCurrentUser.id.toString()).get();
    }

    currentUser = User.fromDocument(documentSnapshot);

  }
}

import "package:firebase_auth/firebase_auth.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:restaurantapp/pages/home_page.dart';
import "package:google_sign_in/google_sign_in.dart";


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FirebaseAuth _auth=FirebaseAuth.instance;
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;
  final TextEditingController _emailController =TextEditingController();
  final TextEditingController _passwordController=TextEditingController();

  //function to start or create user process
  void _register() async{
    try{
      UserCredential userCredential= await _auth.createUserWithEmailAndPassword(
        email: _emailController.text, 
        password: _passwordController.text
        );
      //Set Users roll to user
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'email':_emailController.text,
        'roll': 'user'
      });

      //Navigate to homeScreen or another screen
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context)=>const HomePage())
        );


    }catch(e){
      print(e);
    }
  }
   Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        //check if user data already exisits
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          await _firestore.collection('users').doc(user.uid).set({
            'email': user.email,
            'roll': 'user',
          });
        }
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      print(e);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body:Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: _register, 
              child: const Text('Register')
              ),
                ElevatedButton(
                onPressed: _signInWithGoogle,
                child:const Text("Signup With Google"),
              ),
              TextButton(
                onPressed: (){
                  Navigator.pushNamed(context, '/login');
                }, 
                child: const Text('Already registered? Login here'),
                ),
          ],
        ),
        )
    );
  }
}
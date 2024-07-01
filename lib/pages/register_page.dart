import "package:firebase_auth/firebase_auth.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:restaurantapp/pages/home_page.dart';

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
        MaterialPageRoute(builder: (context)=>HomePage())
        );


    }catch(e){
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
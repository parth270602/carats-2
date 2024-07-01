import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:restaurantapp/pages/home_page.dart";

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}


class _LoginPageState extends State<LoginPage> {

  final FirebaseAuth _auth =FirebaseAuth.instance;
  final TextEditingController _emailController=TextEditingController();
  final TextEditingController _passwordController =TextEditingController();

  void _login() async{
    try{
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text, 
        password: _passwordController.text,
        );

        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) =>  HomePage()),
          );
    }catch(e){
      print(e);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body:Padding(
        padding: const EdgeInsets.all(16.0),
        child:Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: _login, 
              child: const Text('Login')
              ),
              TextButton(
                onPressed: (){
                  Navigator.pushNamed(context, '/register');
                }, 
                child: const Text('Not Registered? Register Here'),
                )
          ],
          )
          )
    );
  }
}
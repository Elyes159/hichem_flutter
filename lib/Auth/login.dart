import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sofima/Home/Home.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

 Future<bool> signIn({
  required String email,
  required String password,
}) async {
  final url = Uri.parse("http://192.168.1.13:8000/login/");
  final requete = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'username': email,
      'password': password,
    }),
  );
  if (requete.statusCode == 200) {
   bool superadmin = json.decode(requete.body)["superAdmin"];
   bool admin = json.decode(requete.body)["admin"];
   bool utilisateur = json.decode(requete.body)["utilisateur"];
   print("superadmin = $superadmin , admin = $admin , user = $utilisateur");
   Navigator.push(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
   return true;
    
  } else {
    print("${requete.statusCode}");
    return false;
  }
}

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images.png",
                height: 100,
                width: 100,
              ),
              SizedBox(height: 10,),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  hintText: "Entrez votre email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              SizedBox(height: 10,),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: "password",
                  hintText: "Entrez password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(Icons.password),
                ),
                obscureText: true,
              ),
              SizedBox(height: 16,),
              InkWell(
                onTap: (){
                  signIn(email: _emailController.text,password: _passwordController.text);
                },
                child: Container(
                  height: 50,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color.fromARGB(255, 10, 54, 90)
                  ),
                  child: Center(child: Text("login" , style : TextStyle(color: Colors.white , fontSize: 20 , fontWeight: FontWeight.bold))),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

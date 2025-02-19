import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class AddArticle extends StatefulWidget {
  const AddArticle({super.key});

  @override
  State<AddArticle> createState() => _AddArticleState();
}

class _AddArticleState extends State<AddArticle> {
  TextEditingController _quantiteControler = TextEditingController();
    TextEditingController _rControler = TextEditingController();
  TextEditingController _dControler = TextEditingController();



  Future<bool> AddArticle(int quantite, String reference , String description) async {
    final url = Uri.parse("http://192.168.1.13:8000/adda/");
    final body = jsonEncode({
      "quantite": quantite,
      "reference": reference,
      "description" : description
    });
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'}, body: body);

    if (response.statusCode == 201) {
      print("ajout terminé");
      return true;
    } else {
      print("Erreur ${response.statusCode}");
      return false;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("add article"),),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _rControler,
                decoration: InputDecoration(
                  hintText: "reference",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 16,),
              TextField(
                controller: _dControler,
                decoration: InputDecoration(
                   hintText: "decription",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 16,),
              TextField(
                controller: _quantiteControler,
                decoration: InputDecoration(
                  hintText: "quantité",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 16,),
              ElevatedButton(onPressed: (){
                AddArticle(int.parse(_quantiteControler.text), _rControler.text, _dControler.text);
              }, child: Text("add Article"))
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic>? articles;
  String? username;
  FlutterSecureStorage storage = FlutterSecureStorage();

  Future<bool> getArticles() async {
    final url = Uri.parse("http://192.168.1.13:8000/getArticles/");
    final response = await http.get(url, headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      setState(() {
        articles = json.decode(response.body)["articles"];
      });
      username = await storage.read(key: "username");
      String? admin = await storage.read(key: "admin");
       String? superadmin = await storage.read(key: "superadmin");
       String?  utilisateur = await storage.read(key: "utilisateur");
       print("$utilisateur , $superadmin , $admin");
      return true;
    } else {
      print("Erreur ${response.statusCode}");
      return false;
    }
  }
  

  @override
  void initState() {
    super.initState();
    getArticles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Liste des Articles")),
      body: articles == null
          ? const Center(child: Text("no articles"))
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                children: [
                  Text("Welcome $username !" , style: TextStyle(fontSize: 18 , color: Colors.red)),
                  DataTable(
                    columnSpacing:35,
                    columns: const [
                      DataColumn(label: Text('Nom')),
                      DataColumn(label: Text('Référence')),
                      DataColumn(label: Text('Quantité')),
                      DataColumn(label: Text('')),
                    ],
                    rows: articles!.map((article) {
                      return DataRow(cells: [
                        DataCell(Text(article["nom"].toString())),
                        DataCell(Text(article["reference"].toString())),
                        DataCell(Text(article["quantite"].toString())),
                        DataCell(Row(
                          children: [
                            IconButton(onPressed: (){}, icon: Icon(Icons.add,size: 14,)),
                            IconButton(onPressed: (){}, icon: Icon(Icons.remove , size:14)),
                          ],
                        )),
                      ]);
                    }).toList(),
                  ),
                ],
              ),
            ),
    );
  }
}

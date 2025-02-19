import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:sofima/composnat/composant.dart';

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
    final response =
        await http.get(url, headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      setState(() {
        articles = json.decode(response.body)["articles"];
      });
      username = await storage.read(key: "username");
      String? admin = await storage.read(key: "admin");
      String? superadmin = await storage.read(key: "superadmin");
      String? utilisateur = await storage.read(key: "utilisateur");
      print("$utilisateur , $superadmin , $admin");
      return true;
    } else {
      print("Erreur ${response.statusCode}");
      return false;
    }
  }

  Future<bool> modification_quantite(int quantite, String reference) async {
    final url = Uri.parse("http://192.168.1.13:8000/updateQ/");
    final body = jsonEncode({
      "quantite": quantite,
      "reference_article": reference,
    });
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'}, body: body);

    if (response.statusCode == 200) {
      print("modification terminé");
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
                  Text("Welcome $username !",
                      style: TextStyle(fontSize: 18, color: Colors.red)),
                  DataTable(
                    columnSpacing: 35,
                    columns: const [
                      DataColumn(label: Text('Référence')),
                      DataColumn(label: Text('description')),
                      DataColumn(label: Text('Quantité')),
                      DataColumn(label: Text('')),
                    ],
                    rows: articles!.map((article) {
                      TextEditingController _quantiteControler =
                          TextEditingController(
                              text: article["quantite"].toString());
                      return DataRow(cells: [
                        DataCell(InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Composant(reference: article["reference"],)));
                            },
                            child: Text(article["reference"].toString()))),
                        DataCell(Text(article["description"].toString())),
                        DataCell(TextField(
                          controller: _quantiteControler,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        )),
                        DataCell(
                          SizedBox(
                            width: 80, // Ajuste cette valeur selon tes besoins
                            child: Row(
                              mainAxisSize:
                                  MainAxisSize.min, // Évite l'expansion inutile
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    modification_quantite(
                                        int.parse(_quantiteControler.text),
                                        article["reference"]);
                                  },
                                  icon: Icon(Icons.check_circle_sharp,
                                      color: Colors.green,
                                      size:
                                          40), // Réduction de la taille de l'icône
                                  padding:
                                      EdgeInsets.zero, // Réduction du padding
                                  constraints:
                                      BoxConstraints(), // Supprime les contraintes de taille par défaut
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ],
              ),
            ),
    );
  }
}

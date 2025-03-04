import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:sofima/composnat/composant.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic>? articles;
  List<dynamic>? filteredArticles; // Liste pour les articles filtrés
  String? username;
  FlutterSecureStorage storage = FlutterSecureStorage();

  TextEditingController _searchController = TextEditingController();

  Future<bool> getArticles() async {
    final url = Uri.parse("http://192.168.1.13:8000/getArticles/");
    final response =
        await http.get(url, headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      setState(() {
        articles = json.decode(response.body)["articles"];
        filteredArticles = articles; // Par défaut, on affiche tous les articles
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
      print("Modification terminée");
      return true;
    } else {
      print("Erreur ${response.statusCode}");
      return false;
    }
  }

  Future<bool> delete_article(String reference) async {
    final url = Uri.parse("http://192.168.1.13:8000/deleteAricle/");
    final body = jsonEncode({
      "reference": reference,
    });
    final response = await http.delete(url,
        headers: {'Content-Type': 'application/json'}, body: body);

    if (response.statusCode == 200) {
      print("Suppression terminée");
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
    _searchController.addListener(
        _filterArticles); // Ajout de l'écouteur pour le champ de recherche
  }

  // Fonction pour filtrer les articles en fonction de la référence
  void _filterArticles() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredArticles = articles?.where((article) {
        return article["reference"].toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(
        _filterArticles); // Supprimer l'écouteur quand le widget est supprimé
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Liste des Articles",
          style: GoogleFonts.dmSans(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 1.71,
          ),
        ),
        iconTheme: IconThemeData(
          color:
              Colors.white, // Changer la couleur de l'icône (flèche de retour)
        ),
      ),
      body: articles == null
          ? const Center(child: Text("Aucun article disponible"))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Recherche par référence',
                        labelStyle: GoogleFonts.dmSans(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)
                        ),
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      children: [
                        Column(
                          children: [
                            DataTable(
                              dataTextStyle: GoogleFonts.dmSans(),
                              headingTextStyle: GoogleFonts.dmSans(),
                              border: TableBorder.all(
                                  color: Color(0xFFC0C0C0),
                                  borderRadius: BorderRadius.circular(10)),
                              columnSpacing: 35,
                              columns: [
                                DataColumn(
                                  label: Text(
                                    'Référence',
                                    style: GoogleFonts.dmSans(
                                      color: Color(0xFF1A1A27),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      height: 2,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                    label: Text(
                                  'Description',
                                  style: GoogleFonts.dmSans(
                                    color: Color(0xFF1A1A27),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    height: 2,
                                  ),
                                )),
                                DataColumn(
                                    label: Text(
                                  'Quantité',
                                  style: GoogleFonts.dmSans(
                                    color: Color(0xFF1A1A27),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    height: 2,
                                  ),
                                )),
                                DataColumn(
                                    label: Text(
                                  'valider',
                                  style: GoogleFonts.dmSans(
                                    color: Color(0xFF1A1A27),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    height: 2,
                                  ),
                                )),
                                DataColumn(
                                    label: Text(
                                  'Supprimer',
                                  style: GoogleFonts.dmSans(
                                    color: Color(0xFF1A1A27),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    height: 2,
                                  ),
                                )),
                              ],
                              rows: filteredArticles!.map((article) {
                                TextEditingController _quantiteController =
                                    TextEditingController(
                                        text: article["quantite"].toString());
                                return DataRow(cells: [
                                  DataCell(InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Composant(
                                                    reference:
                                                        article["reference"],
                                                  )),
                                        );
                                      },
                                      child: Text(
                                          article["reference"].toString()))),
                                  DataCell(
                                      Text(article["description"].toString())),
                                  DataCell(SizedBox(
                                    width:
                                        120, // Ajout de contrainte de largeur
                                    child: TextField(
                                      controller: _quantiteController,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  )),
                                  DataCell(
                                    SizedBox(
                                      width:
                                          80, // Ajuste cette valeur selon tes besoins
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              modification_quantite(
                                                  int.parse(
                                                      _quantiteController.text),
                                                  article["reference"]);
                                            },
                                            icon: Icon(Icons.check_circle_sharp,
                                                color: Colors.green, size: 40),
                                            padding: EdgeInsets.zero,
                                            constraints: BoxConstraints(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width:
                                          80, // Ajuste cette valeur selon tes besoins
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text('Supprimer'),
                                                    content: Text(
                                                        'Etes-vous sûr de vouloir supprimer cet article ?'),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        onPressed: () {
                                                          delete_article(
                                                              article[
                                                                  "reference"]);
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child:
                                                            Text('Confirmer'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            icon: Icon(Icons.delete,
                                                color: Colors.red, size: 40),
                                            padding: EdgeInsets.zero,
                                            constraints: BoxConstraints(),
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

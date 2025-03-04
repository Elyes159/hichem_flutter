import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class Composant extends StatefulWidget {
  final String reference;
  const Composant({super.key, required this.reference});

  @override
  State<Composant> createState() => _ComposantState();
}

class _ComposantState extends State<Composant> {
  List<dynamic>? composants;
  List<dynamic>? filteredComposant; // Liste pour les articles filtrés

  Future<bool> getComposant() async {
    final url = Uri.parse("http://192.168.1.13:8000/getComposant/");
    final body = jsonEncode({"reference": widget.reference});
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'}, body: body);

    if (response.statusCode == 200) {
      print("success");
      setState(() {
        composants = json.decode(response.body)["composants"];
        filteredComposant = composants;
      });
      print(composants);
      return true;
    } else {
      print("Erreur ${response.statusCode}");
      return false;
    }
  }

  Future<bool> AddComposant(int quantite, String reference) async {
    final url = Uri.parse("http://192.168.1.13:8000/addC/");
    final body = jsonEncode({
      "quantite": quantite,
      "reference": reference,
      "referenceA": widget.reference,
    });
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'}, body: body);

    if (response.statusCode == 201) {
      print(" composant ajouté");
      return true;
    } else {
      print("Erreur ${response.body}");
      return false;
    }
  }

  Future<bool> modification_quantite(int quantite, String reference) async {
    final url = Uri.parse("http://192.168.1.13:8000/updateQC/");
    final body = jsonEncode({
      "quantite": quantite,
      "reference_c": reference,
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

  TextEditingController _searchController = TextEditingController();

  void _filterComposants() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredComposant = composants?.where((composant) {
        return composant["reference"].toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    getComposant();
    _searchController.addListener(_filterComposants);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterComposants);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _quantiteControler = TextEditingController();
    TextEditingController _rControler = TextEditingController();
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Composants de ${widget.reference}",
          style: GoogleFonts.dmSans(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            height: 1.71,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white, // Changer la couleur de l'icône (flèche de retour)
        ),
      ),
      body: composants == null || composants == [] || composants == [{}]
          ? Center(
              child: Text(
                "No articles",
                style: TextStyle(color: Colors.black),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Recherche par référence',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    children: [
                      Container(
                        width: screenWidth, // Utilise la largeur de l'écran
                        child: DataTable(
                          dataTextStyle: GoogleFonts.dmSans(),
                          headingTextStyle: GoogleFonts.dmSans(),
                          border: TableBorder.all(
                            color: Color(0xFFC0C0C0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          columnSpacing: 35,
                          columns: [
                            const DataColumn(label: Text('Référence')),
                            const DataColumn(label: Text('Quantité')),
                            DataColumn(
                              label: IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        content: Text("Voulez-vous continuer ?"),
                                        actions: [
                                          TextField(
                                            controller: _rControler,
                                            decoration: InputDecoration(
                                              hintText: "Référence",
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          TextField(
                                            controller: _quantiteControler,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              hintText: "Quantité",
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Center(
                                            child: ElevatedButton(
                                              onPressed: () {
                                                AddComposant(int.parse(_quantiteControler.text), _rControler.text);
                                              },
                                              child: Text("Ajouter composant"),
                                            ),
                                          )
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: Row(
                                  children: [
                                    SizedBox(width: 10,),
                                    Center(
                                      child: Image.asset(
                                        "assets/plus.png",
                                        height: 40,
                                        width: 40,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          rows: filteredComposant!.map((composant) {
                            TextEditingController _quantiteControler = TextEditingController(
                              text: composant["quantite"].toString(),
                            );
                            return DataRow(cells: [
                              DataCell(Text(composant["reference"].toString())),
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
                                    mainAxisSize: MainAxisSize.min, // Évite l'expansion inutile
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          modification_quantite(
                                            int.parse(_quantiteControler.text),
                                            composant["reference"],
                                          );
                                        },
                                        icon: Center(
                                          child: Icon(
                                            Icons.check_circle_sharp,
                                            color: Colors.green,
                                            size: 40,
                                          ),
                                        ),
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

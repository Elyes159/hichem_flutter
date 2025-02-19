import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Composant extends StatefulWidget {
  final String reference;
  const Composant({super.key, required this.reference});

  @override
  State<Composant> createState() => _ComposantState();
}

class _ComposantState extends State<Composant> {
  List<dynamic>? composants;
  Future<bool> getComposant() async {
    final url = Uri.parse("http://192.168.1.13:8000/getComposant/");
    final body = jsonEncode({"reference": widget.reference});
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'}, body: body);

    if (response.statusCode == 200) {
      print("success");
      setState(() {
        composants = json.decode(response.body)["composants"];
      });
      print("heeeeeeeey");
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
      "referenceA" : widget.reference,
    });
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'}, body: body);

    if (response.statusCode == 201) {
      print(" composnat terminé");
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getComposant();
  }

  @override
  Widget build(BuildContext context) {
      TextEditingController _quantiteControler = TextEditingController();
    TextEditingController _rControler = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text("les Composants de ${widget.reference}"),
      ),
      body: composants == null || composants == [] || composants == [{}]
          ? Center(
              child: Text(
              "no articles",
              style: TextStyle(color: Colors.black),
            ))
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                children: [
                  DataTable(
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
                                            hintText: "reference",
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 8,),
                                        TextField(
                                          controller: _quantiteControler,
                                          decoration: InputDecoration(
                                            hintText: "quantity",
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 8,),
                                        Center(child: ElevatedButton(onPressed: (){
                                          AddComposant(int.parse(_quantiteControler.text) , _rControler.text);
                                        }, child: Text("add composant")))
                                       
                                      ],
                                    );
                                  },
                                );
                              },
                              icon: Image.asset(
                                "assets/plus.png",
                                height: 30,
                                width: 30,
                              ))),
                    ],
                    rows: composants!.map((composant) {
                      TextEditingController _quantiteControler =
                          TextEditingController(
                              text: composant["quantite"].toString());
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
                              mainAxisSize:
                                  MainAxisSize.min, // Évite l'expansion inutile
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    modification_quantite(
                                        int.parse(_quantiteControler.text),
                                        composant["reference"]);
                                  },
                                  icon: Icon(Icons.check_circle_sharp,
                                      color: Colors.green,
                                      size:
                                          30), // Réduction de la taille de l'icône
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

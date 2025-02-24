import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sofima/Home/Home.dart';
import 'package:sofima/add/addarticle.dart';
import 'package:sofima/admin/admin.dart';
import 'package:sofima/rendement/rendement.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  FlutterSecureStorage storage = FlutterSecureStorage();
  String userType = "";

  // Cette fonction vérifie le type d'utilisateur
  Future<void> veriftypeUser() async {
    String? admin = await storage.read(key: "admin");
    String? superadmin = await storage.read(key: "superadmin");
    String? utilisateur = await storage.read(key: "utilisateur");
    print("Navigation: $admin , $superadmin , $utilisateur");

    if (admin == "true") {
      setState(() {
        userType = "admin";
      });
    } else if (superadmin == "true") {
      setState(() {
        userType = "superadmin";
      });
    } else if (utilisateur == "true") {
      setState(() {
        userType = "utilisateur";
      });
    } else {
      setState(() {
        userType = "";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    veriftypeUser(); // Vérifie le type d'utilisateur au démarrage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "menu",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomeScreen()));
                        },
                        child: Image.asset(
                          "assets/accueil.png",
                          height: 150,
                          width: 150,
                        )),
                    Text(
                      "Articles",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                if (userType == "admin" || userType == "superadmin")
                Column(
                  children: [
                    InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Rendement()));
                        },
                        child: Image.asset(
                          "assets/attente.png",
                          height: 150,
                          width: 150,
                        )),
                    Text(
                      "Rendement",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 100,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddArticle()));
                        },
                        child: Image.asset(
                          "assets/plus.png",
                          height: 150,
                          width: 150,
                        )),
                    Text(
                      "Ajouter un Article",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ],
            ),
            // Ajouter un quatrième bouton si l'utilisateur est un admin ou superadmin
            if (userType == "admin" || userType == "superadmin") ...[
              SizedBox(
                height: 50,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>Admin()));
                        },
                        child: Image.asset(
                          "assets/admin.png", // Utilise une icône différente pour ce bouton
                          height: 150,
                          width: 150,
                        ),
                      ),
                      Text(
                        "Admin Actions",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }
}

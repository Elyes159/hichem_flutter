import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class Admin extends StatefulWidget {
  const Admin({super.key});

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  final FlutterSecureStorage storage = FlutterSecureStorage();

Future<bool>blockadmin(String admin_id)async{
   final url = Uri.parse("http://192.168.1.13:8000/block_admin/$admin_id/");
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
  );
  if(response.statusCode == 200){
    return true;
  }
  else {
    return false;
  }
}
Future<bool>dblockadmin(String admin_id)async{
   final url = Uri.parse("http://192.168.1.13:8000/dblock_admin/$admin_id/");
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
  );
  if(response.statusCode == 200){
    return true;
  }
  else {
    return false;
  }
}
Future<bool>dblockuser(String admin_id)async{
   final url = Uri.parse("http://192.168.1.13:8000/dblock_user/$admin_id/");
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
  );
  if(response.statusCode == 200){
    return true;
  }
  else {
    return false;
  }
}
Future<bool>blockuser(String admin_id)async{
   final url = Uri.parse("http://192.168.1.13:8000/block_user/$admin_id/");
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
  );
  if(response.statusCode == 200){
    return true;
  }
  else {
    return false;
  }
}
Future<bool>deleteuser(String admin_id)async{
   final url = Uri.parse("http://192.168.1.13:8000/delete_user/$admin_id/");
  final response = await http.delete(
    url,
    headers: {'Content-Type': 'application/json'},
  );
  if(response.statusCode == 200){
    return true;
  }
  else {
    return false;
  }
}
Future<bool>deleteadmin(String admin_id)async{
   final url = Uri.parse("http://192.168.1.13:8000/delete_admin/$admin_id/");
  final response = await http.delete(
    url,
    headers: {'Content-Type': 'application/json'},
  );
  if(response.statusCode == 200){
    return true;
  }
  else {
    return false;
  }
}


 Future<Map<String, dynamic>> fetchUsers() async {
  String? isAdmin = await storage.read(key: "admin");
  String? isSuper = await storage.read(key: "superadmin");

  final url = Uri.parse("http://192.168.1.13:8000/getUsers/$isAdmin/$isSuper/");
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return {
      "users": data["users"] ?? [],
      "admins": data["admins"] ?? [],
    };
  } else {
    throw Exception("Failed to load users");
  }
}


@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text("Liste des utilisateurs")),
    body: FutureBuilder<Map<String, dynamic>>(
      future: fetchUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Erreur: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Aucun utilisateur trouvé"));
        }

        // Récupérer les utilisateurs et les administrateurs à partir du Map
        final users = snapshot.data!["users"];
        final admins = snapshot.data!["admins"];

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            children: [
              Text("Admins",style: TextStyle(fontWeight: FontWeight.bold),),
              DataTable(
                columnSpacing: 35,
                columns: const [
                  DataColumn(label: Text('email')),
                  DataColumn(label: Text('blocage')),
                  DataColumn(label: Text('suppression')),
                ],
                rows: admins.map<DataRow>((admin) {
                  return DataRow(cells: [
                    DataCell(Text(admin["email"].toString())),
                    DataCell(
                      IconButton(
                        icon: admin["is_blocked"] ==false? Icon(Icons.block) : Icon(Icons.check),
                        onPressed: () {
                          if(admin["is_blocked"] == false){
                            blockadmin(admin["email"]);
                            setState(() {
                            
                          });
                          }else{
                            dblockadmin(admin["email"]);
                            setState(() {
                              
                            });
                          }
                        },
                      ),
                    ),
                    DataCell(
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          deleteadmin(admin["email"]);
                          setState(() {
                            
                          });
                        },
                      ),
                    ),
                  ]);
                }).toList(),
              ),
              Text("Utilisateur" , style: TextStyle(fontWeight: FontWeight.bold),),
              DataTable(
                columnSpacing: 35,
                columns: const [
                  DataColumn(label: Text('email')),
                  DataColumn(label: Text('blocage')),
                  DataColumn(label: Text('suppression')),
                ],
                rows: users.map<DataRow>((user) {
                  return DataRow(cells: [
                    DataCell(Text(user["email"].toString())),
                    DataCell(
                      IconButton(
                       icon: user["is_blocked"] ==false? Icon(Icons.block) : Icon(Icons.check),
                        onPressed: () {
                          if(user["is_blocked"] ==false){
                          blockuser(user["email"]);
                          setState(() {
                            
                          });
                          }else {
                            dblockuser(user["email"]);
                            setState(() {
                              
                            });
                          }
                        },
                      ),
                    ),
                    DataCell(
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          deleteuser(user["email"]);
                          setState(() {
                            
                          });
                        },
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ],
          ),
        );
      },
    ),
  );
}


}

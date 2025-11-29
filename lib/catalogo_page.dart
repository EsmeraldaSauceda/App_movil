import 'package:catalogo_de_peliculas/agregar.dart';
import 'package:catalogo_de_peliculas/descripcion.dart';
import 'package:catalogo_de_peliculas/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


// 👉 Lista de correos que serán administradores
const List<String> correosAdmins = [
  "admin@gmail.com",
  "otroadmin@gmail.com",
];

class CatalogoPage extends StatefulWidget {
  const CatalogoPage({super.key});

  @override
  State<CatalogoPage> createState() => _CatalogoPageState();
}

class _CatalogoPageState extends State<CatalogoPage> {
  List<String> imagenes = [];
  List<String> nombres = [];

  bool esAdmin = false; // 👈 Nueva variable

  @override
  void initState() {
    super.initState();
    verificarAdmin(); // 👈 Verificamos si es admin
    fetchImagenes();
  }

  List<String> excluidos = [];

  void eliminarPokemon(String nombre) {
  setState(() {
    int index = nombres.indexOf(nombre);
    if (index != -1) {
      nombres.removeAt(index);
      imagenes.removeAt(index);
    }
  });
}

  void verificarAdmin() {
    final emailUsuario = FirebaseAuth.instance.currentUser!.email;

    setState(() {
      esAdmin = correosAdmins.contains(emailUsuario);
    });
  }

  Future<void> cargarPokemonesAPI() async {
  final response = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=25'));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    List results = data['results'];

    List<String> urls = [];
    List<String> names = [];

    for (var item in results) {
      names.add(item['name']);

      final pokeResponse = await http.get(Uri.parse(item['url']));
      if (pokeResponse.statusCode == 200) {
        final pokeData = json.decode(pokeResponse.body);
        final imageUrl = pokeData['sprites']['front_default'];
        if (imageUrl != null) {
          urls.add(imageUrl);
        }
      }
    }

    setState(() {
      imagenes = urls;
      nombres = names;
    });
  }
}


  Future<void> fetchImagenes() async {
    await cargarPokemonesAPI();
    await cargarPokemonesAdmin();
  }


  Future<void> cargarPokemonesAdmin() async {
  final query = await FirebaseFirestore.instance
      .collection("pokemones_custom")
      .orderBy("fecha", descending: true)
      .get();

  for (var doc in query.docs) {
    imagenes.insert(0, doc["imagenUrl"]);
    nombres.insert(0, doc["nombre"]);
  }

  setState(() {});
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
        child: Drawer(
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                const DrawerHeader(
                  child: Text(
                    'Menú',
                    style: TextStyle(fontSize: 22, color: Colors.black),
                  ),
                ),

                Back(),

                // 🔥 SOLO aparece si el usuario es admin
                if (esAdmin) ...[
                  const Divider(),
                  const Text(
                    "Administrador",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),

                  TextButton(
                    onPressed: () async {
                      final resultado = await Navigator.push<Map<String, dynamic>>(
                        context,
                        MaterialPageRoute(builder: (context) => NuevaPeli()),
                      );

                      if (resultado != null) {
                        setState(() {
                          imagenes.insert(0, resultado["imagenUrl"]);
                          nombres.insert(0, resultado["nombre"]);
                        });
                      }
                    },
                    child: const Text("Agregar pokemon"),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),

      backgroundColor: const Color.fromRGBO(218, 192, 167, 1),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  Expanded(
                    child: SearchBar(
                      leading: const Icon(Icons.search),
                      hintText: 'Buscar',
                      backgroundColor: WidgetStateProperty.all(Colors.white),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              Builder(
                builder: (context) {
                  int totalCategorias = (imagenes.length / 3).ceil();

                  return Column(
                    children: List.generate(
                      totalCategorias,
                      (i) => buildCategoria('', i),
                    ),
                  );
                },
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget buildCategoria(String titulo, int categoriaIndex) {
    int start = categoriaIndex * 3;
    int end = start + 3;

    List<String> imagenesCategoria = imagenes.sublist(
    start,
    end > imagenes.length ? imagenes.length : end,
  );


    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.black,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(3, (index) {
              if (imagenesCategoria.isEmpty) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else {
                int globalIndex = start + index;

                if (globalIndex >= imagenes.length) {
                  return const SizedBox(); // no mostrar nada fuera de rango
                }

                final imageUrl = imagenes[globalIndex];
                final nombre = nombres[globalIndex];


                return Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final resultado = await Navigator.push<String>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Descripcion(
                                nombre: nombre,
                                imagenUrl: imageUrl,
                              ),
                            ),
                          );

                          if (resultado != null) {
                            eliminarPokemon(resultado); // 👈 actualiza la lista
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("$resultado eliminado del catálogo")),
                            );
                          }
                      },
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      nombre.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              }
            }),
          ),
        ],
      ),
    );
  }
}

class Back extends StatelessWidget {
  const Back({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        await FirebaseAuth.instance.signOut();

        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Login()),
          );
        }
      },
      child: const Text('Cerrar sesión'),
    );
  }
}

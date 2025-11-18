import 'package:catalogo_de_peliculas/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CatalogoPage extends StatefulWidget {
  const CatalogoPage({super.key});

  @override
  State<CatalogoPage> createState() => _CatalogoPageState();
}

class _CatalogoPageState extends State<CatalogoPage> {
  List<String> imagenes = [];

  @override
  void initState() {
    super.initState();
    fetchImagenes();
  }

  Future<void> fetchImagenes() async {
    final response =
        await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=50'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List results = data['results'];

      List<String> urls = [];

      // Obtenemos el sprite de cada uno (solo los primeros 50)
      for (var item in results) {
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
      });
    }
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
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Login()),
                  );
                },
                child: const Text('Inicio'),
              ),
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
                  Expanded( // 👈 Ajusta automáticamente el ancho disponible
                    child: SearchBar(
                      leading: const Icon(Icons.search),
                      hintText: 'Buscar',
                      backgroundColor: WidgetStateProperty.all(Colors.white),
                    ),
                  ),
                ],
              ),

              
              const SizedBox(height: 25),

              // Creamos 4 categorías con diferentes imágenes
              buildCategoria('', 0),
              buildCategoria('', 1),
              buildCategoria('', 2),
              buildCategoria('', 3),
            ],
          ),
        ),
      ),
    );
  }

  // Cada categoría usará diferentes imágenes según su índice
  Widget buildCategoria(String titulo, int categoriaIndex) {
    // Calculamos el rango de imágenes para cada categoría
    int start = categoriaIndex * 9;
    int end = start + 9;

    List<String> imagenesCategoria = imagenes.length > end
        ? imagenes.sublist(start, end)
        : imagenes; // Si hay menos imágenes, usamos todas

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
                // Muestra una imagen distinta para cada recuadro
                final imageUrl = imagenesCategoria[index % imagenesCategoria.length];
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black, width: 1), // 👈 Borde negro
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
                );

              }
            }),
          ),
        ],
      ),
    );
  }
}

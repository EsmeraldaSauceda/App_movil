import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

const List<String> correosAdmins = [
  "admin@gmail.com",
  "otroadmin@gmail.com",
];


class Descripcion extends StatefulWidget {
  final String nombre;
  final String imagenUrl;
  final void Function(String nombre)? onDelete;

  const Descripcion({
    super.key,
    required this.nombre,
    required this.imagenUrl,
    this.onDelete,
  });

  @override
  State<Descripcion> createState() => _DescripcionState();
}

class _DescripcionState extends State<Descripcion> {
  int? numeroPokemon;
  List<String> tipos = [];
  double? altura;
  double? peso;
  List<String> habilidades = [];
  Map<String, int> estadisticas = {};
  String? descripcion;

  @override
  void initState() {
    super.initState();
    fetchPokemonData();
  }

  Future<void> fetchDescripcion() async {
  final url = Uri.parse('https://pokeapi.co/api/v2/pokemon-species/${widget.nombre.toLowerCase()}');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final entries = data['flavor_text_entries'] as List;

    final entryEs = entries.firstWhere(
      (entry) => entry['language']['name'] == 'es',
      orElse: () => null,
    );

    setState(() {
      descripcion = entryEs != null
          ? (entryEs['flavor_text'] as String).replaceAll('\n', ' ').replaceAll('\f', ' ')
          : 'Descripción no disponible en español.';
    });
  } else {
    setState(() {
      descripcion = 'No se pudo cargar la descripción.';
    });
  }
}

  Future<void> fetchPokemonData() async {
  final url = Uri.parse('https://pokeapi.co/api/v2/pokemon/${widget.nombre.toLowerCase()}');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);

    setState(() {
      numeroPokemon = data['id'];
      tipos = (data['types'] as List)
          .map((typeInfo) => typeInfo['type']['name'].toString())
          .toList();

      altura = (data['height'] as int) / 10; // decímetros → metros
      peso = (data['weight'] as int) / 10;   // hectogramos → kg

      habilidades = (data['abilities'] as List)
          .map((a) => a['ability']['name'].toString())
          .toList();

      estadisticas = {
        for (var stat in data['stats'])
          stat['stat']['name']: stat['base_stat']
      };
    });

    // Llamamos también a la descripción
    fetchDescripcion();
  } else {
    setState(() {
      numeroPokemon = null;
      tipos = ['Desconocido'];
      altura = null;
      peso = null;
      habilidades = [];
      estadisticas = {};
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(218, 192, 167, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(218, 192, 167, 1),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          widget.nombre.toUpperCase(),
          style: const TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Imagen del Pokémon
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  widget.imagenUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Nombre + Número del Pokémon
            Text(
              "${widget.nombre} ( #${numeroPokemon?.toString().padLeft(3, '0') ?? '...'} )",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            // Tipo del Pokémon
            Text(
              "Tipo: ${tipos.isNotEmpty ? tipos.join(', ') : 'Cargando...'}",
              style: const TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // Cuadro grande para información adicional
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Altura: ${altura != null ? "${altura!.toStringAsFixed(1)} m" : '...'}"),
                  Text("Peso: ${peso != null ? "${peso!.toStringAsFixed(1)} kg" : '...'}"),
                  const SizedBox(height: 10),
                  Text("Habilidades: ${habilidades.isNotEmpty ? habilidades.join(', ') : '...'}"),
                  const SizedBox(height: 20),
                  const Text("Descripción:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(descripcion ?? 'Cargando descripción...'),
                  ...estadisticas.entries.map((e) => Text("${e.key}: ${e.value}")),
                ],
              ),
            ),
            const SizedBox(height: 20),

          // BOTÓN PARA ADMINISTRADOR
          if (correosAdmins.contains(FirebaseAuth.instance.currentUser?.email))

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, widget.nombre); // 👈 regresamos el nombre al padre
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Eliminar del catálogo", style: TextStyle(color: Colors.white)),
            )
          ],

        ),
      ),
    );
  }
}
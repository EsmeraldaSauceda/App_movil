
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';


class NuevaPeli extends StatefulWidget {
  const NuevaPeli({super.key});

  @override
  State<NuevaPeli> createState() => _NuevaPeliState();
}

class _NuevaPeliState extends State<NuevaPeli> {
  // Estado
  bool loading = true;
  int? numeroPokemon;
  String nombre = "";
  String imagenUrl = "";
  List<String> tipos = [];
  double? altura;
  double? peso;
  List<String> habilidades = [];
  Map<String, int> estadisticas = {};
  String? descripcion;

  @override
  void initState() {
    super.initState();
    cargarPokemonRandom();
  }

  Future<void> cargarPokemonRandom() async {
    setState(() {
      loading = true;
      // opcional: limpiar datos previos
      numeroPokemon = null;
      nombre = "";
      imagenUrl = "";
      tipos = [];
      altura = null;
      peso = null;
      habilidades = [];
      estadisticas = {};
      descripcion = null;
    });

    try {
      final random = Random();
      final id = random.nextInt(898) + 1; // 1..898

      final url = Uri.parse("https://pokeapi.co/api/v2/pokemon/$id");
      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception("Error al obtener Pokémon");
      }

      final data = json.decode(response.body);

      final fetchedName = data["name"]?.toString() ?? "";
      final fetchedImage = data["sprites"]?["other"]?["official-artwork"]?["front_default"]?.toString()
          ?? data["sprites"]?["front_default"]?.toString()
          ?? "";

      final fetchedTipos = (data["types"] as List<dynamic>?)
              ?.map((t) => t["type"]?["name"]?.toString() ?? "")
              .where((s) => s.isNotEmpty)
              .toList() ??
          [];

      final fetchedAltura = (data["height"] is int) ? (data["height"] as int) / 10.0 : null;
      final fetchedPeso = (data["weight"] is int) ? (data["weight"] as int) / 10.0 : null;

      final fetchedHabilidades = (data["abilities"] as List<dynamic>?)
              ?.map((a) => a["ability"]?["name"]?.toString() ?? "")
              .where((s) => s.isNotEmpty)
              .toList() ??
          [];

      final fetchedStats = <String, int>{};
      if (data["stats"] is List) {
        for (var s in data["stats"]) {
          final key = s["stat"]?["name"]?.toString() ?? "";
          final val = s["base_stat"] is int ? s["base_stat"] as int : 0;
          if (key.isNotEmpty) fetchedStats[key] = val;
        }
      }

      // Guardamos los datos básicos primero
      setState(() {
        nombre = fetchedName;
        imagenUrl = fetchedImage;
        numeroPokemon = data["id"] is int ? data["id"] as int : null;
        tipos = fetchedTipos;
        altura = fetchedAltura;
        peso = fetchedPeso;
        habilidades = fetchedHabilidades;
        estadisticas = fetchedStats;
      });

      // Luego pedimos la descripción (species)
      await cargarDescripcion(fetchedName);
    } catch (e) {
      // manejar error: puedes mostrar un SnackBar en la UI si quieres
      setState(() {
        descripcion = "No se pudo cargar el Pokémon.";
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> cargarDescripcion(String nombrePokemon) async {
    if (nombrePokemon.isEmpty) return;

    try {
      final url = Uri.parse("https://pokeapi.co/api/v2/pokemon-species/$nombrePokemon");
      final response = await http.get(url);

      if (response.statusCode != 200) {
        descripcion = "Descripción no disponible.";
        return;
      }

      final data = json.decode(response.body);
      final entries = data["flavor_text_entries"] as List<dynamic>? ?? [];

      final entryEs = entries.firstWhere(
        (e) => e?["language"]?["name"] == "es",
        orElse: () => null,
      );

      if (entryEs != null && entryEs["flavor_text"] != null) {
        descripcion = (entryEs["flavor_text"] as String).replaceAll("\n", " ").replaceAll("\f", " ");
      } else {
        descripcion = "Descripción no disponible en español.";
      }
    } catch (_) {
      descripcion = "No se pudo cargar la descripción.";
    }
  }

  @override
  Widget build(BuildContext context) {
    // build está correctamente definido dentro de la clase State
    return Scaffold(
      backgroundColor: const Color.fromRGBO(218, 192, 167, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(218, 192, 167, 1),
        elevation: 0,
        centerTitle: true,
        title: Text(
          loading ? "Cargando..." : nombre.toUpperCase(),
          style: const TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: cargarPokemonRandom,
          )
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Imagen
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: imagenUrl.isNotEmpty
                          ? Image.network(imagenUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Center(child: Icon(Icons.error)))
                          : const Center(child: Icon(Icons.image_not_supported)),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Nombre + Número
                  Text(
                    "${nombre.isNotEmpty ? nombre.toUpperCase() : '---'} ( #${numeroPokemon != null ? numeroPokemon.toString().padLeft(3, '0') : '...'} )",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 10),

                  // Tipos
                  Text(
                    "Tipo: ${tipos.isNotEmpty ? tipos.join(', ') : 'Desconocido'}",
                    style: const TextStyle(fontSize: 15),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  // Panel informativo
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
                        Text(descripcion ?? 'Sin descripción.'),
                        const SizedBox(height: 20),
                        const Text("Estadísticas:", style: TextStyle(fontWeight: FontWeight.bold)),
                        ...estadisticas.entries.map((e) => Text("${e.key}: ${e.value}")),
                      ],
                    ),
                  ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: ElevatedButton(
                        onPressed: () {
                          if (!mounted) return;

                          // devolvemos los datos al CatalogoPage
                          Navigator.pop(context, {
                            "nombre": nombre,
                            "imagenUrl": imagenUrl,
                          });
                        },
                        child: const Text("Agregar al catálogo"),
                      )




                    )
                ],
              ),
            ),
    );
  }
}

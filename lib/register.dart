import 'package:flutter/material.dart';

class Register extends StatelessWidget {
  const Register({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 250.0,
              width: 250.0,
              child: Image.network('https://cdn.pixabay.com/photo/2014/03/25/16/54/tape-297596_1280.png'),
            ),
            Respuesta()
          ],
        ),
      ),
    );
  }
}

class Respuesta extends StatelessWidget {
  const Respuesta({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      child: SizedBox(
      width: 270.0,
      height: 350.0,
      child: Column(
        children: [
          Padding(padding: const EdgeInsets.all(10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Correo',
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 14,
              ),
          ))),
          const SizedBox(height: 5,),
          SizedBox(
            width: 270.0,
            child: TextFormField(
              decoration: InputDecoration(
                hintText: 'Ingrese su correo',
                filled: true,
                fillColor: const Color(0xFF8B6B4F), // marrón
                contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),)
            ),
          ),
          Padding(padding: const EdgeInsets.all(10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Nombre de usuario',
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 14,
              ),
          ))
          ),
          SizedBox(
            width: 270.0,
            child: TextFormField(
              decoration: InputDecoration(
                hintText: 'Ingrese su nombre de usuario',
                filled: true,
                fillColor: const Color(0xFF8B6B4F), // marrón
                contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              )),
            ),
          ),
          Padding(padding: const EdgeInsets.all(10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Contraseña',
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 14,
              ),
          ))
          ),
          SizedBox(
            width: 270.0,
            child: TextFormField(
              decoration: InputDecoration(
                hintText: 'Ingrese su contraseña',
                filled: true,
                fillColor: const Color(0xFF8B6B4F), // marrón
                contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              )),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                ElevatedButton(onPressed: (){}, style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(67, 76, 57, 1),
                ), child: Text('Registrarse', style: TextStyle(color: Color.fromRGBO(218, 192, 167, 1)))),

                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: SizedBox(
                  width: 100.0,
                  child: ElevatedButton(onPressed: (){
                    Navigator.pop(context);
                  },style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(67, 76, 57, 1),
                  ), child: Text('Home', style: TextStyle(color: Color.fromRGBO(218, 192, 167, 1)),)),),
                )
              ],
            ),
          )
        ],
      ),
    ));
  }
}

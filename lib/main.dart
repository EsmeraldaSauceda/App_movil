import 'package:catalogo_de_peliculas/login.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';



void main() async {  
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Catálogo de Películas',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: Color.fromRGBO(218, 192, 167, 1)
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text('Welcome to MOVIES', style: TextStyle(fontSize: 25),),
            ),
            SizedBox(
              height: 250.0,
              width: 250.0,
              child: Image.network('https://cdn.pixabay.com/photo/2014/03/25/16/54/tape-297596_1280.png'),
            ),
            ElevatedButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
            }, style: ElevatedButton.styleFrom(
      backgroundColor: Color.fromRGBO(67, 76, 57, 1),
    ), child: Text('Enter the app', style: TextStyle(color: Color.fromRGBO(218, 192, 167, 1))))
          ],
        ),
      )
    );
  }
}
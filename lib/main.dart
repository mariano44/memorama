import 'package:flutter/material.dart';
import 'package:project_memorama/src/gameHard.dart';
import 'package:project_memorama/src/gameMid.dart';
import 'package:project_memorama/src/game_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Juego de Memoria',
      theme: ThemeData(
        primaryColor: Colors.orange[400],
        scaffoldBackgroundColor: Colors.blueGrey[900],
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/img/wallpaper.jpg"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black45, // Oscurece un poco el fondo
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Título animado
                Text(
                  "Juego de Memoria",
                  style: TextStyle(
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[300],
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.orange,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40.0),
                // Botones de dificultad
                _buildDifficultyButton(
                  context,
                  "Fácil (8)",
                  const GameScreen(),
                  Colors.green,
                  Colors.greenAccent,
                ),
                const SizedBox(height: 20.0),
                _buildDifficultyButton(
                  context,
                  "Normal (10)",
                  const Gamemid(),
                  Colors.orange,
                  Colors.deepOrangeAccent,
                ),
                const SizedBox(height: 20.0),
                _buildDifficultyButton(
                  context,
                  "Difícil (12)",
                  const Gamehard(),
                  Colors.red,
                  Colors.redAccent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Método para construir los botones de dificultad con estilo
  Widget _buildDifficultyButton(
    BuildContext context,
    String text,
    Widget gameScreen,
    Color colorStart,
    Color colorEnd,
  ) {
    return SizedBox(
      width: 200.0,
      height: 50.0,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => gameScreen),
          );
        },
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorStart, colorEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

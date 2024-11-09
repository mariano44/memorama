import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_memorama/src/components/info_card.dart';
import 'package:project_memorama/src/components/game_utils_hard.dart';
import 'package:soundpool/soundpool.dart';

class Gamehard extends StatefulWidget {
  const Gamehard({super.key});

  @override
  State<Gamehard> createState() => _GamehardState();
}

class _GamehardState extends State<Gamehard> {
  GameHard _game = GameHard(); // Objeto para manejar la lógica del juego
  Soundpool pool = Soundpool(
      streamType: StreamType
          .notification); // Inicializa Soundpool para los efectos de sonido

  // Rutas de los sonidos
  String popSound = "assets/sounds/cartoon_pop.flac";
  String dandan = "assets/sounds/finish.mp3";

  // Variables para las estadísticas del juego
  int tries = 0; // Contador de intentos
  int score = 0; // Puntaje actual
  int highscore = 0; // Mejor puntaje registrado
  int secondsPassed = 0; // Tiempo transcurrido en segundos
  Timer? _timer; // Temporizador para el juego
  int bestTime = 999; // Almacena el mejor tiempo registrado (inicialmente alto)

  @override
  void initState() {
    super.initState();
    startNewGame(); // Inicia un nuevo juego al cargar la pantalla
  }

  // Método para iniciar un nuevo juego
  void startNewGame() {
    _game.initGame(); // Inicializa la lógica del juego
    _resetGameStats(); // Resetea las estadísticas

    // Configura el temporizador para incrementar el contador cada segundo
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        secondsPassed++;
      });
    });
  }

  // Método para resetear las estadísticas del juego
  void _resetGameStats() {
    setState(() {
      tries = 0;
      score = 0;
      secondsPassed = 0;
    });
  }

  // Verifica si el usuario ha ganado
  void checkWin(BuildContext context) {
    _timer?.cancel(); // Detiene el temporizador al ganar
    _playSoundEffect(dandan); // Reproduce sonido de victoria

    // Actualiza el mejor tiempo si el tiempo actual es menor
    if (secondsPassed < bestTime) {
      setState(() {
        bestTime = secondsPassed;
      });
    }

    // Muestra el cuadro de diálogo de victoria con detalles
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¡Has ganado!"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Tiempo total: $secondsPassed segundos"),
            Text("Score: $highscore puntos"),
            const SizedBox(height: 10),
            Text(
              "Mejor Tiempo: $bestTime segundos",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              startNewGame(); // Reinicia el juego si el usuario quiere volver a jugar
            },
            child: const Text("Volver a intentar"),
          ),
        ],
      ),
    );
  }

  // Método para reproducir un efecto de sonido
  Future<void> _playSoundEffect(String sound) async {
    int soundId = await rootBundle.load(sound).then((ByteData soundData) {
      return pool.load(soundData);
    });
    await pool.play(soundId);
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancela el temporizador al salir de la pantalla
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Juego de Memoria'),
        centerTitle: true,
        backgroundColor: Colors.orange[400],
        foregroundColor: Colors.white,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Filas para mostrar intentos y puntaje
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              info_card("Intentos", "$tries"),
              info_card("Score", "$highscore")
            ],
          ),
          // Contenedor de las tarjetas en formato GridView
          SizedBox(
            height: 650,
            width: MediaQuery.of(context).size.width,
            child: GridView.builder(
              itemCount: _game.gameImg!.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
              ),
              padding: const EdgeInsets.all(16.0),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      tries++; // Incrementa el contador de intentos
                      _game.gameImg![index] = _game.cards_list[index];
                      _game.matchCheck.add({index: _game.cards_list[index]});
                    });
                    if (_game.matchCheck.length == 2) {
                      if (_game.matchCheck[0].values.first ==
                          _game.matchCheck[1].values.first) {
                        score += 100; // Suma puntos por acierto
                        highscore += 1;
                        _game.matchCheck.clear();
                        _playSoundEffect(
                            popSound); // Efecto de sonido por acierto

                        if (score == 1200) {
                          // Si el usuario alcanza el puntaje máximo
                          checkWin(context);
                        }
                      } else {
                        Future.delayed(const Duration(milliseconds: 500), () {
                          setState(() {
                            _game.gameImg![_game.matchCheck[0].keys.first] =
                                _game.hiddenCardpath;
                            _game.gameImg![_game.matchCheck[1].keys.first] =
                                _game.hiddenCardpath;
                            _game.matchCheck.clear();
                          });
                        });
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB46A),
                      borderRadius: BorderRadius.circular(8.0),
                      image: DecorationImage(
                        image: AssetImage(_game.gameImg![index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Temporizador
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Tiempo: $secondsPassed s",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

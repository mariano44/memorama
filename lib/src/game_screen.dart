import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_memorama/src/components/info_card.dart';
import 'package:project_memorama/src/components/game_utils.dart';
import 'package:soundpool/soundpool.dart';

// Pantalla principal del juego de memoria
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Instancias para manejar la lógica del juego y el sonido
  Game _game = Game();
  Soundpool pool = Soundpool(streamType: StreamType.notification);

  // Archivos de sonido para efectos
  String popSound = "assets/sounds/cartoon_pop.flac";
  String finish = "assets/sounds/finish.mp3";

  // Variables para estadísticas y temporizador
  int tries = 0;
  int highscore = 0;
  int score = 0;
  int secondsPassed = 0;
  Timer? _timer;
  bool showBestTime = false; // Controla la visibilidad del mejor tiempo

  @override
  void initState() {
    super.initState();
    startNewGame(); // Inicia un nuevo juego al cargar la pantalla
  }

  // Función para iniciar un nuevo juego
  void startNewGame() {
    _game.initGame(); // Inicializa el estado del juego
    _resetGameStats(); // Reinicia las estadísticas

    // Inicia el temporizador para contar los segundos
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        secondsPassed++;
      });
    });
  }

  // Función para reiniciar estadísticas del juego
  void _resetGameStats() {
    setState(() {
      tries = 0;
      score = 0;
      secondsPassed = 0;
      showBestTime = false;
    });
  }

  // Verifica si el jugador ha ganado el juego
  void checkWin(BuildContext context) async {
    _timer?.cancel(); // Detiene el temporizador
    await _soundefect(finish); // Reproduce el sonido de victoria

    // Muestra el diálogo de victoria
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¡Has ganado!"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Tiempo total: $secondsPassed segundos"),
            Text("Score: $highscore puntos"), // Cambiado a mostrar `score`
            const SizedBox(height: 10),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              startNewGame(); // Reinicia el juego al cerrar el diálogo
            },
            child: const Text("Volver a intentar"),
          ),
        ],
      ),
    );
  }

  // Función para reproducir efectos de sonido
  Future<void> _soundefect(String sound) async {
    int soundId = await rootBundle.load(sound).then((ByteData soundData) {
      return pool.load(soundData);
    });
    await pool.play(soundId);
  }

  @override
  void dispose() {
    _timer?.cancel(); // Detiene el temporizador al cerrar la pantalla
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
          // Muestra el mejor tiempo si es necesario
          if (showBestTime)
            Text(
              "Mejor Tiempo: $secondsPassed segundos",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 20),
          // Muestra las tarjetas de estadísticas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              info_card("Intentos", "$tries"),
              info_card("Score", "$highscore"),
            ],
          ),
          // Área de juego
          SizedBox(
            height: 500,
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
                      // Muestra la tarjeta seleccionada y guarda el intento
                      _game.gameImg![index] = _game.cards_list[index];
                      _game.matchCheck.add({index: _game.cards_list[index]});
                    });

                    if (_game.matchCheck.length == 2) {
                      tries++;

                      // Verifica si las tarjetas coinciden
                      if (_game.matchCheck[0].values.first ==
                          _game.matchCheck[1].values.first) {
                        score += 100;
                        highscore += 1;
                        _game.matchCheck.clear();
                        _soundefect(popSound);

                        // Si el puntaje llega a 800, el juego se gana
                        if (score == 800) {
                          checkWin(context);
                        }
                      } else {
                        // Voltea las tarjetas si no coinciden
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
                  // Muestra la tarjeta
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
          const SizedBox(height: 20),
          // Muestra el tiempo transcurrido
          Text(
            'Tiempo: $secondsPassed s',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

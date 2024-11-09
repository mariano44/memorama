import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_memorama/src/components/info_card.dart';
import 'package:project_memorama/src/components/game_utils_mid.dart';
import 'package:soundpool/soundpool.dart';

class Gamemid extends StatefulWidget {
  const Gamemid({super.key});

  @override
  State<Gamemid> createState() => _GamemidState();
}

class _GamemidState extends State<Gamemid> {
  // Instancia de juego para la lógica
  GameMid _game = GameMid();

  // Manejo de sonido
  Soundpool pool = Soundpool(streamType: StreamType.notification);

  // Archivos de sonidos de efectos
  String popSound = "assets/sounds/cartoon_pop.flac";
  String dandan = "assets/sounds/finish.mp3";

  // Variables de estadísticas del juego
  int tries = 0; // Intentos realizados
  int score = 0; // Puntaje acumulado
  int secondsPassed = 0; // Tiempo transcurrido en segundos
  int? highScore = 0; // Mejor puntaje registrado
  Timer? _timer; // Temporizador para contar el tiempo
  int bestTime = 999; // Mejor tiempo registrado

  @override
  void initState() {
    super.initState();
    startNewGame(); // Inicia un nuevo juego al arrancar el estado
  }

  // Función para iniciar un nuevo juego
  void startNewGame() {
    _game.initGame(); // Inicializa el juego
    _resetGameStats(); // Reinicia las estadísticas

    // Configura y arranca el temporizador de tiempo
    _timer?.cancel(); // Detiene cualquier temporizador previo
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        secondsPassed++; // Incrementa el tiempo en segundos
      });
    });
  }

  // Reinicia las estadísticas del juego
  void _resetGameStats() {
    setState(() {
      tries = 0;
      score = 0;
      secondsPassed = 0;
    });
  }

  // Verifica si el jugador ganó
  void checkWin(BuildContext context) async {
    // Detiene el temporizador y reproduce el sonido de victoria
    _timer?.cancel();
    _soundEffect(dandan); // Llama a función para reproducir sonido de victoria

    // Muestra un diálogo de victoria
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¡Has ganado!"),
        content: Column(
          mainAxisSize: MainAxisSize.min, // Tamaño mínimo del diálogo
          children: [
            Text("Tiempo total: $secondsPassed segundos"),
            Text("Score: $highScore puntos"),
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
              Navigator.of(context).pop(); // Cierra el diálogo
              startNewGame(); // Reinicia el juego
            },
            child: const Text("Volver a intentar"),
          ),
        ],
      ),
    );
  }

  // Reproduce efectos de sonido
  Future<void> _soundEffect(String sound) async {
    int soundId = await rootBundle.load(sound).then((ByteData soundData) {
      return pool.load(soundData);
    });
    print(soundId);
    await pool.play(soundId); // Espera a que el sonido termine de reproducirse
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancela el temporizador cuando se destruye el widget
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Juego de Memoria'),
        centerTitle: true,
        backgroundColor: Colors.orange[400],
        foregroundColor: Colors.white,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Muestra las estadísticas de intentos y puntuación
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              info_card("Intentos", "$tries"),
              info_card("Score", "$highScore"),
            ],
          ),
          // Grid del juego de memoria
          SizedBox(
            height: 550,
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
                      tries++; // Aumenta los intentos
                      _game.gameImg![index] = _game.cards_list[index];
                      _game.matchCheck.add({index: _game.cards_list[index]});
                    });
                    // Verifica coincidencias en las cartas
                    if (_game.matchCheck.length == 2) {
                      if (_game.matchCheck[0].values.first ==
                          _game.matchCheck[1].values.first) {
                        score += 100; // Aumenta el puntaje en caso de acierto
                        _game.matchCheck.clear();
                        _soundEffect(
                            popSound); // Reproduce efecto de coincidencia

                        if (score == 1000) {
                          checkWin(
                              context); // Llama a checkWin si llega al puntaje máximo
                        }
                      } else {
                        // Oculta las cartas después de un breve retraso si no coinciden
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
          const SizedBox(height: 20), // Espacio entre el Grid y el tiempo
          Text(
            'Tiempo: $secondsPassed segundos',
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

import 'dart:async';

class TurnManager {
  bool isWhiteTurn = true;

  static const int initialTimeMs = 60 * 60 * 1000; // 1 hora em milissegundos
  int whiteTimeLeft = initialTimeMs;
  int blackTimeLeft = initialTimeMs;

  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;

  /// Inicia o relógio do jogador atual
  void start() {
    _stopwatch.start();
    _timer = Timer.periodic(Duration(seconds: 1), (_) => _updateTime());
  }

  /// Atualiza o tempo restante do jogador atual
  void _updateTime() {
    final elapsed = _stopwatch.elapsedMilliseconds;
    _stopwatch.reset();

    if (isWhiteTurn) {
      whiteTimeLeft -= elapsed;
      if (whiteTimeLeft <= 0) {
        whiteTimeLeft = 0;
        stop();
        print("Brancas perderam por tempo!");
      }
    } else {
      blackTimeLeft -= elapsed;
      if (blackTimeLeft <= 0) {
        blackTimeLeft = 0;
        stop();
        print("Pretas perderam por tempo!");
      }
    }
  }

  /// Troca o turno e reinicia o relógio
  void switchTurn() {
    _updateTime();        // Atualiza tempo antes de trocar
    isWhiteTurn = !isWhiteTurn;
    _stopwatch.reset();   // Zera o cronômetro do outro jogador
  }

  /// Para o relógio (fim de jogo ou pausa)
  void stop() {
    _stopwatch.stop();
    _timer?.cancel();
  }

  /// Reinicia o jogo do zero
  void reset() {
    stop();
    whiteTimeLeft = initialTimeMs;
    blackTimeLeft = initialTimeMs;
    isWhiteTurn = true;
    _stopwatch.reset();
  }

  /// Retorna tempo restante formatado em mm:ss
  String getFormattedTime(bool white) {
    int time = white ? whiteTimeLeft : blackTimeLeft;
    int minutes = time ~/ 60000;
    int seconds = (time % 60000) ~/ 1000;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

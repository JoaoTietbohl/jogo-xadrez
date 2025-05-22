import 'package:flutter/material.dart';
import '../widgets/chess_board.dart';

class ChessPage extends StatelessWidget {
  const ChessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xadrez Simples')),
      body: const Padding(
        padding: EdgeInsets.all(8.0),
        child: ChessBoard(),
      ),
    );
  }
}

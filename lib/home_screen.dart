import 'package:flutter/material.dart';
import 'package:tic_tac_game/game_logic.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String activePlayer = 'X';
  bool gameOver = false;
  int turn = 0;
  String result = ' ';
  Game game = Game();

  bool isSwitched = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: MediaQuery.of(context).orientation == Orientation.portrait
            ? Column(
                children: [
                  ...firstBlock(),
                  _expanded(context),
                  // we use (...) to extract the List's elements .
                  ...lastBlock(),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...firstBlock(),
                        const SizedBox(height: 20),
                        ...lastBlock(),
                      ],
                    ),
                  ),
                  _expanded(context),
                ],
              ),
      ),
    );
  }

  List<Widget> firstBlock() {
    return [
      SwitchListTile.adaptive(
        title: const Text(
          'Turn on/off two player',
          style: TextStyle(color: Colors.white, fontSize: 28),
          textAlign: TextAlign.center,
        ),
        value: isSwitched,
        onChanged: (bool newValue) {
          setState(() {
            isSwitched = newValue;
          });
        },
      ),
      Text(
        'IT\'S $activePlayer TURN',
        style: const TextStyle(color: Colors.white, fontSize: 52),
        textAlign: TextAlign.center,
      ),
    ];
  }

  Expanded _expanded(BuildContext context) {
    return Expanded(
      child: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 3,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        childAspectRatio: 1.0,
        children: List.generate(
            9,
            (index) => InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: gameOver ? null : () => _ontap(index),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).shadowColor,
                        borderRadius: BorderRadius.circular(16)),
                    child: Center(
                      child: Text(
                        Player.playerX.contains(index)
                            ? 'X'
                            : Player.playerO.contains(index)
                                ? 'O'
                                : ' ',
                        style: TextStyle(
                            color: Player.playerX.contains(index)
                                ? Colors.blue
                                : Colors.redAccent,
                            fontSize: 52),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )),
      ),
    );
  }

  List<Widget> lastBlock() {
    return [
      Text(
        result,
        style: const TextStyle(color: Colors.white, fontSize: 42),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 10),
      ElevatedButton.icon(
        onPressed: () {
          setState(() {
            Player.playerX = [];
            Player.playerO = [];
            activePlayer = 'X';
            gameOver = false;
            turn = 0;
            result = ' ';
          });
        },
        icon: const Icon(Icons.replay),
        label: const Text('Repear the game'),
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all(Theme.of(context).splashColor),
        ),
      )
    ];
  }

  _ontap(int index) async {
    if ((!Player.playerX.contains(index) || Player.playerX.isEmpty) &&
        (!Player.playerO.contains(index) || Player.playerO.isEmpty)) {
      game.playGame(index, activePlayer);
      update_state();

      if (!isSwitched && !gameOver && turn != 9) {
        await game.autoPlay(activePlayer);
        update_state();
      }
    }
  }

  void update_state() {
    setState(() {
      activePlayer = (activePlayer == 'X') ? 'O' : 'X';

      turn++;

      String winnerPlayer = game.checkWinner();
      if (winnerPlayer != ' ') {
        gameOver = true;
        result = '$winnerPlayer is the Winner';
      } else if (!gameOver && turn == 9) {
        result = 'It\'s Draw';
      }
    });
  }
}

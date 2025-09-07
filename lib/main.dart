import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

void main() {
  runApp(DesiTicTacToeApp());
}

class DesiTicTacToeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic-Tac-Toe',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Color(0xFFF2F2F7),
        fontFamily: 'SF Pro Display',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Color(0xFF000000),
        fontFamily: 'SF Pro Display',
      ),
      themeMode: ThemeMode.system,
      home: TicTacToeGame(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TicTacToeGame extends StatefulWidget {
  @override
  _TicTacToeGameState createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame> with TickerProviderStateMixin {
  // Game state variables
  List<String> board = List.filled(9, ''); // 3x3 grid
  String currentPlayer = 'X';
  bool gameEnded = false;
  String? winner;
  List<int> winningLine = [];
  
  final AudioPlayer audioPlayer = AudioPlayer();
  late ConfettiController confettiController;
  
  List<AnimationController> cellControllers = [];
  List<Animation<double>> cellAnimations = [];
  late AnimationController pulseController;
  late Animation<double> pulseAnimation;

  bool isSoundOn = true;

  void toggleSound() {
    setState(() {
      isSoundOn = !isSoundOn;
    });
  }


  @override
  void initState() {
    super.initState();
    confettiController = ConfettiController(duration: const Duration(seconds: 2));
    
    for (int i = 0; i < 9; i++) {
      AnimationController controller = AnimationController(
        duration: Duration(milliseconds: 300),
        vsync: this,
      );
      cellControllers.add(controller);
      cellAnimations.add(Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.elasticOut),
      ));
    }
    
    pulseController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
    );
    pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    confettiController.dispose();
    audioPlayer.dispose();
    for (AnimationController controller in cellControllers) {
      controller.dispose();
    }
    pulseController.dispose();
    super.dispose();
  }

  void playMoveSound() async {
    if (!isSoundOn) return;
    try {
      HapticFeedback.lightImpact();
      await audioPlayer.play(AssetSource('audio/move_sound.mp3'));
    } catch (e) {
      print('Error playing move sound: $e');
    }
  }

  void playWinSound() async {
    if (!isSoundOn) return;
    try {
      HapticFeedback.mediumImpact();
      await audioPlayer.play(AssetSource('audio/win_sound.mp3'));
    } catch (e) {
      print('Error playing win sound: $e');
    }
  }


  void onCellTap(int index) {
    if (board[index] != '' || gameEnded) return;

    setState(() {
      board[index] = currentPlayer;
    });

    cellControllers[index].forward();
    playMoveSound();

    String? gameWinner = checkWinner();
    
    if (gameWinner != null) {
      setState(() {
        winner = gameWinner;
        gameEnded = true;
      });
      playWinSound();
      confettiController.play();
      
      Future.delayed(Duration(milliseconds: 500), () {
        _showGameEndPopup(true, gameWinner);
      });
      
    } else if (board.every((cell) => cell != '')) {
      setState(() {
        gameEnded = true;
      });
      Future.delayed(Duration(milliseconds: 500), () {
        _showGameEndPopup(false, null);
      });
      
    } else {
      setState(() {
        currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
      });
    }
  }

  String? checkWinner() {
    List<List<int>> winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6],
    ];

    for (List<int> pattern in winPatterns) {
      if (board[pattern[0]] != '' &&
          board[pattern[0]] == board[pattern[1]] &&
          board[pattern[1]] == board[pattern[2]]) {
        winningLine = pattern;
        return board[pattern[0]];
      }
    }
    return null;
  }

  // ✅ Fixed popup (removed duplicate text)
  void _showGameEndPopup(bool isWin, String? winnerSymbol) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Column(
            children: [
              Text(
                isWin ? 'Player $winnerSymbol Wins!' : "It's a Draw!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              if (isWin) ...[
                const SizedBox(height: 6),
                Text(
                  winnerSymbol ?? '',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: winnerSymbol == 'X'
                        ? (isDark ? Colors.blue[300] : Colors.blue[600])
                        : (isDark ? Colors.red[300] : Colors.red[600]),
                  ),
                ),
              ],
            ],
          ),
          content: Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              isWin 
                ? 'Congratulations! You got three in a row.' 
                : 'Good game! The board is full.',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
                resetGame();
              },
              child: Text(
                'Play Again',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.systemBlue,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void resetGame() {
    setState(() {
      board = List.filled(9, '');
      currentPlayer = 'X';
      gameEnded = false;
      winner = null;
      winningLine = [];
    });
    for (AnimationController controller in cellControllers) {
      controller.reset();
    }
    confettiController.stop();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? Color(0xFF000000) : Color(0xFFF2F2F7),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                if (!gameEnded) ...[
                  SizedBox(height: 40),
                  AnimatedBuilder(
                    animation: pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: pulseAnimation.value,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 20),
                              child: IconButton(
                                icon: Icon(
                                  isSoundOn ? Icons.volume_up : Icons.volume_off,
                                ),
                                onPressed: toggleSound,
                                tooltip: "Toggle Sound",
                              ),
                            ),
                            SizedBox(width: 2),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                color: isDark 
                                  ? Colors.white.withOpacity(0.1) 
                                  : Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'Player $currentPlayer',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
                
                Expanded(
                  child: Center(
                    child: Container(
                      margin: EdgeInsets.all(20),
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark 
                          ? Color(0xFF1C1C1E).withOpacity(0.8) 
                          : Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: isDark 
                              ? Colors.black.withOpacity(0.3) 
                              : Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.0,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: 9,
                        itemBuilder: (context, index) {
                          bool isWinningCell = winningLine.contains(index);
                          
                          return GestureDetector(
                            onTap: () => onCellTap(index),
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: isWinningCell 
                                  ? Colors.green.withOpacity(0.2)
                                  : (isDark ? Color(0xFF2C2C2E) : Color(0xFFF2F2F7)),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isWinningCell
                                    ? Colors.green.withOpacity(0.5)
                                    : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
                                  width: isWinningCell ? 2 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: AnimatedBuilder(
                                  animation: cellAnimations[index],
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: cellAnimations[index].value,
                                      child: Text(
                                        board[index],
                                        style: TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.w600,
                                          color: board[index] == 'X' 
                                            ? (isDark ? Colors.blue[300] : Colors.blue[600])
                                            : (isDark ? Colors.red[300] : Colors.red[600]),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                
                Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: CupertinoButton(
                    onPressed: resetGame,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemBlue,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: CupertinoColors.systemBlue.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        'New Game',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: confettiController,
                blastDirection: pi / 2,
                maxBlastForce: 12,
                minBlastForce: 6,
                emissionFrequency: 0.03,
                numberOfParticles: 15,
                gravity: 0.2,
                shouldLoop: false,
                colors: [
                  CupertinoColors.systemBlue,
                  CupertinoColors.systemGreen,
                  CupertinoColors.systemOrange,
                  CupertinoColors.systemPurple,
                  CupertinoColors.systemPink,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

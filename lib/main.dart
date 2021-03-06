import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SnakeGame(),
    );
  }
}

class SnakeGame extends StatefulWidget {
  @override
  _SnakeGamesState createState() => _SnakeGamesState();
}

class _SnakeGamesState extends State<SnakeGame> {
  final int squaresPerRow = 20;
  final int squaresPercol = 40;
  final fontStyle = TextStyle(color: Colors.white, fontSize: 20);
  final randomGen = Random();

  var snake = [
    [0, 1],
    [0, 0]
  ];
  var food = [0, 2];
  var directions = 'up';
  var isPlaying = false;

  void startGame() {
    const duration = Duration(milliseconds: 150);

    snake = [
      [(squaresPerRow / 2).floor(), (squaresPercol / 2).floor()]
    ];
    snake.add([snake.first[0], snake.first[1] - 1]);

    createFood();

    isPlaying = true;
    Timer.periodic(duration, (Timer timer) {
      moveSnake();
      if (checkGameOver()) {
        timer.cancel();
        endGame();
      }
    });
  }

  void moveSnake() {
    setState(() {
      switch (directions) {
        case 'up':
          snake.insert(0, [snake.first[0], snake.first[1] - 1]);
          break;
        case 'down':
          snake.insert(0, [snake.first[0], snake.first[1] + 1]);
          break;

        case 'left':
          snake.insert(0, [snake.first[0] - 1, snake.first[1]]);
          break;

        case 'right':
          snake.insert(0, [snake.first[0] + 1, snake.first[1]]);
          break;
      }
      if (snake.first[0] != food[0] || snake.first[1] != food[1]) {
        snake.removeLast();
      } else {
        createFood();
      }
    });
  }

  void createFood() {
    food = [randomGen.nextInt(squaresPerRow), randomGen.nextInt(squaresPercol)];
  }

  bool checkGameOver() {
    if (!isPlaying ||
        snake.first[1] < 0 ||
        snake.first[1] >= squaresPercol ||
        snake.first[0] < 0 ||
        snake.first[0] > squaresPercol) {
      return true;
    }

    for (var i = 1; i < snake.length; ++i) {
      if (snake[1][0] == snake.first[0] && snake[i][1] == snake.first[1]) {
        return true;
      }
    }
    return false;
  }

  void endGame() {
    isPlaying = false;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('GAME OVER'),
            content: Text(
              'Score: ${snake.length - 2}',
              style: TextStyle(fontSize: 20),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Expanded(
              child: GestureDetector(
                  onVerticalDragUpdate: (details) {
                    if (directions != 'up' && details.delta.dy > 0) {
                      directions = 'down';
                    } else if (directions != 'down' && details.delta.dy < 0) {
                      directions = 'up';
                    }
                  },
                  onHorizontalDragUpdate: (details) {
                    if (directions != 'left' && details.delta.dx > 0) {
                      directions = 'right';
                    } else if (directions != 'right' && details.delta.dx < 0) {
                      directions = 'left';
                    }
                  },
                  child: AspectRatio(
                    aspectRatio: squaresPerRow / (squaresPercol + 2),
                    child: GridView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: squaresPerRow,
                        ),
                        itemCount: squaresPerRow * squaresPercol,
                        itemBuilder: (BuildContext context, int index) {
                          var color;
                          var x = index % squaresPerRow;
                          var y = (index / squaresPerRow).floor();

                          bool isSnakeBody = false;
                          for (var pos in snake) {
                            if (pos[0] == x && pos[1] == y) {
                              isSnakeBody = true;
                              break;
                            }
                          }

                          if (snake.first[0] == x && snake.first[1] == y) {
                            color = Colors.green;
                          } else if (isSnakeBody) {
                            color = Colors.green[200];
                          } else if (food[0] == x && food[1] == y) {
                            color = Colors.red;
                          } else {
                            color = Colors.lightGreenAccent[800];
                          }

                          return Container(
                            margin: EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                  ))), // Expanded
          Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    if (isPlaying) {
                      isPlaying = false;
                    } else {
                      startGame();
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    color: isPlaying ? Colors.red : Colors.blue,
                    child: Text(
                      isPlaying ? 'End' : 'Start',
                      style: fontStyle,
                    ),
                  ),
                ),
                Text(
                  'Score: ${snake.length - 2}',
                  style: fontStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

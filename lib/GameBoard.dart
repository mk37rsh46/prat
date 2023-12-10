import 'dart:math';

class GameBoard {
  List<int> gamePiecesW = [];
  List<int> gamePiecesB = [];
  double eval = 0;
  var gameBoard = List<List>.generate(
      3, (i) => List<dynamic>.generate(3, (index) => null, growable: false),
      growable: false);
  List<(int, int)> valM = [(0, 1), (0, -1), (1, 0), (-1, 0)];
  List<(int, int)> diag = [(-1, -1), (-1, 1), (1, 1), (1, -1)];

  GameBoard() {
    resetState();
  }

  GameBoard.parseBoard(String newState) {
    int incr = 0;
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        gameBoard[row][col] = newState.substring(incr, incr + 1);
        if (gameBoard[row][col] == 'c') {
          gamePiecesB.add(incr);
        } else if (gameBoard[row][col] == 'p') {
          gamePiecesW.add(incr);
        }
        incr++;
      }
    }
  }

  GameBoard.copyBoard(GameBoard oldState) {
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        gameBoard[row][col] = oldState.gameBoard[row][col];
      }
    }
    for (int i = 0; i < oldState.gamePiecesB.length; i++) {
      gamePiecesB.add(oldState.gamePiecesB[i]);
    }
    for (int i = 0; i < oldState.gamePiecesW.length; i++) {
      gamePiecesW.add(oldState.gamePiecesW[i]);
    }
  }

  GameBoard.placeBoard(GameBoard oldState, (int, int) location, String c) {
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        gameBoard[row][col] = oldState.gameBoard[row][col];
      }
    }
    for (int i = 0; i < oldState.gamePiecesB.length; i++) {
      gamePiecesB.add(oldState.gamePiecesB[i]);
    }
    for (int i = 0; i < oldState.gamePiecesW.length; i++) {
      gamePiecesW.add(oldState.gamePiecesW[i]);
    }
    placePiece(location, c);
  }

  GameBoard.newBoard(GameBoard oldState, (int, int) location,
      (int, int) destination, String c) {
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        gameBoard[row][col] = oldState.gameBoard[row][col];
      }
    }
    for (int i = 0; i < oldState.gamePiecesB.length; i++) {
      gamePiecesB.add(oldState.gamePiecesB[i]);
    }
    for (int i = 0; i < oldState.gamePiecesW.length; i++) {
      gamePiecesW.add(oldState.gamePiecesW[i]);
    }
    makeMove(location, destination, c);
  }

  void resetState() {
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        gameBoard[row][col] = '-';
      }
    }
  }

  void makeMove((int, int) location, (int, int) dest, String c) {
    gameBoard[dest.$1][dest.$2] = gameBoard[location.$1][location.$2];
    gameBoard[location.$1][location.$2] = '-';
    List<int> pieces = (c == 'p') ? gamePiecesW : gamePiecesB;
    for (int i = 0; i < pieces.length; i++) {
      if (pieces[i] == location.$1 * 3 + location.$2) {
        pieces.remove(pieces[i]);
        pieces.add(dest.$1 * 3 + dest.$2);
      }
    }
  }

  (int, int, double) minimaxMove(
      int depth, String c, GameBoard brd, (int, int) movr) {
    String op1 = (c == 'p' ? 'c' : 'p');
    if ((brd.gamePiecesB.length == 3 && brd.gamePiecesW.length == 3)) {
      brd.eval = brd
          .minimaxAB(3, c, brd, (-5, -5, -5, -5), -1000000009, 1000000009)
          .$5;
      return (movr.$1, movr.$2, brd.eval);
    }
    if (depth == 0 ||
        winner(op1, brd) ||
        winner(c, brd) ||
        (brd.gamePiecesB.length == 3 && brd.gamePiecesW.length == 3)) {
      brd.eval = brd.placeEval(brd, c).toDouble();
      return (movr.$1, movr.$2, brd.eval);
    }
    if (c == 'p') {
      (int, int, double) b = (-5, -5, -10000000000);
      List<(int, int)> moves = [];
      moves.addAll(brd.validPlaces());
      for ((int, int) mo in moves) {
        String n = c == 'p' ? 'c' : 'p';
        var mvc = mo;
        var passOn = movr.$1 == -5 ? mo : movr;
        GameBoard bd = GameBoard.placeBoard(brd, (mvc.$1, mvc.$2), c);
        (int, int, double) test = bd.minimaxMove(depth - 1, n, bd, passOn);
        if (test.$3 >= b.$3) {
          b = test;
        }
      }
      return b;
    } else {
      (int, int, double) b = (-5, -5, 10000000);
      List<(int, int)> moves = [];
      moves.addAll(brd.validPlaces());
      for ((int, int) move in moves) {
        String n = c == 'p' ? 'c' : 'p';
        var mvc = move;
        var passOn = movr.$1 == -5 ? move : movr;
        GameBoard bd = GameBoard.placeBoard(brd, (mvc.$1, mvc.$2), c);
        (int, int, double) test = bd.minimaxMove(depth - 1, n, bd, passOn);
        if (test.$3 <= b.$3) {
          b = test;
        }
      }
      return b;
    }
  }

  void placePiece((int, int) location, String c) {
    List<int> pieces = (c == 'p') ? gamePiecesW : gamePiecesB;
    pieces.add(location.$1 * 3 + location.$2);
    gameBoard[location.$1][location.$2] = c;
  }

  List<(int, int, int, int)> generateMoves(int location) {
    List<(int, int, int, int)> moves = [];
    (int, int) decLoc = (location ~/ 3, location % 3);
    for ((int, int) test in valM) {
      int row = decLoc.$1 + test.$1;
      int col = decLoc.$2 + test.$2;
      if ((row >= 0 && row <= 2) &&
          (col >= 0 && col <= 2) &&
          gameBoard[decLoc.$1 + test.$1][decLoc.$2 + test.$2] == '-') {
        moves.add(
            (decLoc.$1, decLoc.$2, decLoc.$1 + test.$1, decLoc.$2 + test.$2));
      }
    }
    if (location == 4) {
      (int, int) decLoc = (location ~/ 3, location % 3);
      for ((int, int) test in diag) {
        int row = decLoc.$1 + test.$1;
        int col = decLoc.$2 + test.$2;
        if ((row >= 0 && row <= 2) &&
            (col >= 0 && col <= 2) &&
            gameBoard[decLoc.$1 + test.$1][decLoc.$2 + test.$2] == '-') {
          moves.add(
              (decLoc.$1, decLoc.$2, decLoc.$1 + test.$1, decLoc.$2 + test.$2));
        }
      }
    } else {
      if (gameBoard[1][1] == '-') {
        moves.add((decLoc.$1, decLoc.$2, 1, 1));
      }
    }
    return moves;
  }

  List<(int, int)> validPlaces() {
    List<(int, int)> moves = [];
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        if (gameBoard[row][col] == '-') {
          moves.add((row, col));
        }
      }
    }
    return moves;
  }

  winner(String c, GameBoard brd) {
    List<int> pieces = (c == 'p') ? brd.gamePiecesW : brd.gamePiecesB;
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        if (brd.gameBoard[row][col] != c) break;
        if (col == 2) return true;
      }
    }
    for (int col = 0; col < 3; col++) {
      for (int row = 0; row < 3; row++) {
        if (brd.gameBoard[row][col] != c) break;
        if (row == 2) return true;
      }
    }
    for (int diag = 0; diag < 3; diag++) {
      if (brd.gameBoard[diag][diag] != c) break;
      if (diag == 2) return true;
    }
    for (int diag = 0; diag < 3; diag++) {
      if (brd.gameBoard[diag][(diag - 2).abs()] != c) break;
      if (diag == 2) return true;
    }
    if (pieces.isNotEmpty) {
      List<(int, int)> adj = [
        (-1, 0),
        (1, 0),
        (0, -1),
        (0, 1),
      ];
      int ct = 0;
      (int, int) decLoc = (pieces[0] ~/ 3, pieces[0] % 3);
      List<(int, int)> bfs = [decLoc];
      List<(int, int)> visited = [];
      while (bfs.isNotEmpty) {
        (int, int) node = bfs.first;
        bfs.remove(node);
        if (node.$1 == 1 && node.$2 == 1) return false;
        visited.add((node.$1, node.$2));
        for ((int, int) move in adj) {
          int row = node.$1 + move.$1;
          int col = node.$2 + move.$2;
          (int, int) n = (row, col);
          if ((row >= 0 && row <= 2) &&
              (col >= 0 && col <= 2) &&
              brd.gameBoard[row][col] == c &&
              !visited.contains(n)) {
            if (n.$1 == 1 && n.$2 == 1) {
              return false;
            }
            bfs.add((row, col));

            ct++;
            if (ct == 2) {
              return true;
            }
          }
        }
      }
    }
    return false;
  }

  int placeEval(GameBoard brd, String c) {
    int multiplier = (c == 'c') ? -1 : 1;
    if (winner(c, brd)) {
      30000 * multiplier;
    }
    String opp = (c == 'c') ? 'p' : 'c';
    if (winner(opp, brd)) {
      return 30000 * multiplier * -1;
    }
    List<int> mySq = [0, 0, 0, 0];
    List<int> enemSq = [0, 0, 0, 0];
    for (int col = 0; col < 3; col++) {
      int myCounter = 0;
      int yourCounter = 0;
      for (int row = 0; row < 3; row++) {
        if (brd.gameBoard[row][col] == c) {
          if (myCounter != -1) {
            myCounter++;
          }
          yourCounter = -1;
        } else if (brd.gameBoard[row][col] == opp) {
          if (yourCounter != -1) {
            yourCounter++;
          }
          myCounter = -1;
        }
      }
      for (int i = 1; i <= myCounter; i++) {
        mySq[i]++;
      }
      for (int i = 1; i <= yourCounter; i++) {
        enemSq[i]++;
      }
    }
    for (int row = 0; row < 3; row++) {
      int myCounter = 0;
      int yourCounter = 0;
      for (int col = 0; col < 3; col++) {
        if (brd.gameBoard[row][col] == c) {
          if (myCounter != -1) {
            myCounter++;
          }
          yourCounter = -1;
        } else if (brd.gameBoard[row][col] == opp) {
          if (yourCounter != -1) {
            yourCounter++;
          }
          myCounter = -1;
        }
      }
      for (int i = 1; i <= myCounter; i++) {
        mySq[i]++;
      }
      for (int i = 1; i <= yourCounter; i++) {
        enemSq[i]++;
      }
    }

    List<(int, int)> diagOne = [(0, 0), (1, 1), (2, 2)];
    List<(int, int)> diagTwo = [(0, 2), (1, 1), (2, 0)];
    int myCounter = 0;
    int yourCounter = 0;
    for ((int, int) d in diagOne) {
      if (brd.gameBoard[d.$1][d.$2] == c) {
        if (myCounter != -1) {
          myCounter++;
        }
        yourCounter = -1;
      } else if (brd.gameBoard[d.$1][d.$2] == opp) {
        if (yourCounter != -1) {
          yourCounter++;
        }
        myCounter = -1;
      }
    }
    for (int i = 1; i <= myCounter; i++) {
      mySq[i]++;
    }
    for (int i = 1; i <= yourCounter; i++) {
      enemSq[i]++;
    }
    myCounter = 0;
    yourCounter = 0;
    for ((int, int) d in diagTwo) {
      if (brd.gameBoard[d.$1][d.$2] == c) {
        if (myCounter != -1) {
          myCounter++;
        }
        yourCounter = -1;
      } else if (brd.gameBoard[d.$1][d.$2] == opp) {
        if (yourCounter != -1) {
          yourCounter++;
        }
        myCounter = -1;
      }
    }
    for (int i = 1; i <= myCounter; i++) {
      mySq[i]++;
    }
    for (int i = 1; i <= yourCounter; i++) {
      enemSq[i]++;
    }
    List<int> pieces = (c == 'c') ? brd.gamePiecesB : brd.gamePiecesW;
    List<int> opPieces = (c == 'c') ? brd.gamePiecesW : brd.gamePiecesB;
    if (pieces.isNotEmpty && !pieces.contains(4)) {
      int calc = 1;
      int oppcount = 0;
      List<(int, int)> visited = [];
      List<(int, int)> bfs = [(pieces[0] ~/ 3, pieces[0] % 3)];
      List<(int, int)> adj = [
        (-1, 0),
        (1, 0),
        (0, -1),
        (0, 1),
      ];
      while (bfs.isNotEmpty) {
        (int, int) node = bfs.first;
        bfs.remove(node);
        visited.add(node);
        for ((int, int) move in adj) {
          int row = move.$1 + node.$1;
          int col = move.$2 + node.$2;
          (int, int) n = (row, col);
          if ((row <= 2 && row >= 0) &&
              (col <= 2 && col >= 0) &&
              !visited.contains(n) &&
              brd.gameBoard[row][col] == c) {
            calc++;
          } else if ((row <= 2 && row >= 0) &&
              (col <= 2 && col >= 0) &&
              !visited.contains(n) &&
              brd.gameBoard[row][col] == c) {
            oppcount++;
          }
        }
      }
      if (oppcount >= 2) {
        calc = -1;
      }
      for (int i = 1; i <= calc; i++) {
        mySq[i]++;
      }
    }
    if (opPieces.isNotEmpty && !opPieces.contains(4)) {
      int calc = 1;
      int oppcount = 0;
      List<(int, int)> visited = [];
      List<(int, int)> bfs = [(opPieces[0] ~/ 3, opPieces[0] % 3)];
      List<(int, int)> adj = [
        (-1, 0),
        (1, 0),
        (0, -1),
        (0, 1),
      ];
      while (bfs.isNotEmpty) {
        (int, int) node = bfs.first;
        bfs.remove(node);
        visited.add(node);
        for ((int, int) move in adj) {
          int row = move.$1 + node.$1;
          int col = move.$2 + node.$2;
          (int, int) n = (row, col);
          if ((row <= 2 && row >= 0) &&
              (col <= 2 && col >= 0) &&
              !visited.contains(n) &&
              brd.gameBoard[row][col] == opp) {
            calc++;

            bfs.add(n);
          } else if ((row <= 2 && row >= 0) &&
              (col <= 2 && col >= 0) &&
              !visited.contains(n) &&
              brd.gameBoard[row][col] == c) {
            oppcount++;
          }
        }
      }
      if (oppcount >= 2) {
        calc = -1;
      }
      for (int i = 1; i <= calc; i++) {
        enemSq[i]++;
      }
    }
    return (300 * mySq[3] -
            99 * enemSq[2] +
            24 * mySq[2] -
            7 * enemSq[1] +
            3 * mySq[1]) *
        multiplier;
  }

  (int, int, int, int, double) minimax(
    int depth,
    String c,
    GameBoard brd,
    (int, int, int, int) movr,
  ) {
    String op1 = (c == 'p' ? 'c' : 'p');
    List<int> pieces = (c == 'p') ? brd.gamePiecesW : brd.gamePiecesB;
    if (depth == 0 || winner(op1, brd) || winner(c, brd)) {
      brd.eval = brd.placeEval(brd, c).toDouble();

      return (movr.$1, movr.$2, movr.$3, movr.$4, brd.eval);
    }
    if (c == 'p') {
      (int, int, int, int, double) b = (-5, -5, -5, -5, -10000000000);
      List<(int, int, int, int)> moves = [];
      for (int p in pieces) {
        moves.addAll(brd.generateMoves(p));
      }
      for ((int, int, int, int) mo in moves) {
        String n = c == 'p' ? 'c' : 'p';
        var mvc = mo;
        var passOn = movr.$1 == -5 ? mo : movr;
        GameBoard bd =
            GameBoard.newBoard(brd, (mvc.$1, mvc.$2), (mvc.$3, mvc.$4), c);
        (int, int, int, int, double) test =
            bd.minimax(depth - 1, n, bd, passOn);
        if (test.$5 >= b.$5) {
          b = test;
        }
      }
      return b;
    } else {
      (int, int, int, int, double) b = (-5, -5, -5, -5, 10000000);
      List<(int, int, int, int)> moves = [];
      for (int p in pieces) {
        moves.addAll(brd.generateMoves(p));
      }
      for ((int, int, int, int) move in moves) {
        String n = c == 'p' ? 'c' : 'p';
        var mvc = move;
        var passOn = movr.$1 == -5 ? move : movr;
        GameBoard bd =
            GameBoard.newBoard(brd, (mvc.$1, mvc.$2), (mvc.$3, mvc.$4), c);
        (int, int, int, int, double) test =
            bd.minimax(depth - 1, n, bd, passOn);
        if (test.$5 <= b.$5) {
          b = test;
        }
      }
      return b;
    }
  }

  (int, int, int, int, double) minimaxAB(int depth, String c, GameBoard brd,
      (int, int, int, int) movr, int alpha, int beta) {
    String op1 = (c == 'p' ? 'c' : 'p');
    List<int> pieces = (c == 'p') ? brd.gamePiecesW : brd.gamePiecesB;
    if (depth == 0 || winner(op1, brd) || winner(c, brd)) {
      brd.eval = brd.placeEval(brd, c).toDouble();

      return (movr.$1, movr.$2, movr.$3, movr.$4, brd.eval);
    }
    if (c == 'p') {
      int value = -10000001;
      (int, int, int, int, double) b = (-5, -5, -5, -5, -100000);
      List<(int, int, int, int)> moves = [];
      for (int p in pieces) {
        moves.addAll(brd.generateMoves(p));
      }
      for ((int, int, int, int) mo in moves) {
        String n = c == 'p' ? 'c' : 'p';
        var mvc = mo;
        var passOn = movr.$1 == -5 ? mo : movr;
        GameBoard bd =
            GameBoard.newBoard(brd, (mvc.$1, mvc.$2), (mvc.$3, mvc.$4), c);
        (int, int, int, int, double) test =
            bd.minimaxAB(depth - 1, n, bd, passOn, alpha, beta);

        value = max(value, test.$5.toInt());

        if (test.$5 >= b.$5) {
          b = test;
        }
        if (value > beta) break;
        alpha = max(value, alpha);
      }
      return b;
    } else {
      int value = 10000001;
      (int, int, int, int, double) b = (-5, -5, -5, -5, 100000);
      List<(int, int, int, int)> moves = [];
      for (int p in pieces) {
        moves.addAll(brd.generateMoves(p));
      }
      for ((int, int, int, int) move in moves) {
        String n = c == 'p' ? 'c' : 'p';
        var mvc = move;
        var passOn = movr.$1 == -5 ? move : movr;
        GameBoard bd =
            GameBoard.newBoard(brd, (mvc.$1, mvc.$2), (mvc.$3, mvc.$4), c);
        (int, int, int, int, double) test =
            bd.minimaxAB(depth - 1, n, bd, passOn, alpha, beta);
        if (test.$5 <= b.$5) {
          b = test;
        }
        value = min(value, test.$5.toInt());
        if (value < alpha) break;
        beta = min(value, beta);
      }
      return b;
    }
  }
}

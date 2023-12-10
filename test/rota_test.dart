import 'package:rota/GameBoard.dart';
import 'package:test/test.dart';

void main() {
  test('isWin', () {
    GameBoard testBoard1 = GameBoard();
    testBoard1.placePiece((0, 0), 'c');
    testBoard1.placePiece((1, 1), 'c');
    testBoard1.placePiece((2, 2), 'c');
    expect(testBoard1.winner('c', testBoard1), true);
    testBoard1 = GameBoard();
    testBoard1.placePiece((2, 0), 'c');
    testBoard1.placePiece((1, 1), 'c');
    testBoard1.placePiece((0, 2), 'c');
    expect(testBoard1.winner('c', testBoard1), true);
    testBoard1 = GameBoard();
    testBoard1.placePiece((0, 0), 'c');
    testBoard1.placePiece((0, 1), 'c');
    testBoard1.placePiece((0, 2), 'c');
    expect(testBoard1.winner('c', testBoard1), true);
    testBoard1 = GameBoard();
    testBoard1.placePiece((1, 0), 'c');
    testBoard1.placePiece((0, 0), 'c');
    testBoard1.placePiece((2, 0), 'c');
    expect(testBoard1.winner('c', testBoard1), true);
    testBoard1 = GameBoard();
    testBoard1.placePiece((0, 0), 'c');
    testBoard1.placePiece((0, 1), 'c');
    testBoard1.placePiece((1, 0), 'c');
    expect(testBoard1.winner('c', testBoard1), true);
    testBoard1 = GameBoard();
    testBoard1.placePiece((0, 0), 'c');
    testBoard1.placePiece((1, 1), 'c');
    testBoard1.placePiece((1, 0), 'c');
    expect(testBoard1.winner('c', testBoard1), false);
  });
  test('onlyMove', () {
    //check only move scenarios
    GameBoard testBoard1 = GameBoard();
    testBoard1.placePiece((0, 0), 'c');
    testBoard1.placePiece((0, 2), 'c');
    testBoard1.placePiece((2, 0), 'c');
    testBoard1.placePiece((0, 1), 'p');
    testBoard1.placePiece((1, 0), 'p');
    testBoard1.placePiece((2, 2), 'p');
    var (_, _, row, col, _) =
        testBoard1.minimax(5, 'p', testBoard1, (-5, -5, -5, -5));
    expect((row, col), (1, 1));
  });
}

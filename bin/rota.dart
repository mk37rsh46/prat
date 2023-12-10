import 'dart:convert';
import 'dart:io';

import 'package:rota/GameBoard.dart';
import 'package:http/http.dart' as http;

void writeListToFile(String filePath, List<dynamic> data) {
  final file = File(filePath);
  final dataAsString = data.join('\n');
  file.writeAsStringSync(dataAsString);
}

void main(List<String> arguments) async {
  String url =
      'https://rota.praetorian.com/rota/service/play.php?request=new&email=example@gmail.com';
  final response = await http.get(Uri.parse(url));
  List<dynamic> hash = [];
  var resp = jsonDecode(response.body);
  final cookieHeaders = response.headers['set-cookie'];
  final cookies = cookieHeaders!.split('; ');
  final headersWithCookies = <String, String>{
    'Cookie': cookies.join('; '),
  };
  int games = 0;
  GameBoard currentGame = GameBoard.parseBoard(resp['data']['board']);
  while (games < 50) {
    int moves = 0;
    while (currentGame.gamePiecesW.length != 3) {
      var (rowPlace, colPlace, _) =
          currentGame.minimaxMove(5, 'p', currentGame, (-5, -5));
      String url =
          'https://rota.praetorian.com/rota/service/play.php?request=place&location=${rowPlace * 3 + colPlace + 1}&email=example@gmail.com';
      final response =
          await http.post(Uri.parse(url), headers: headersWithCookies);
      resp = jsonDecode(response.body);
      currentGame = GameBoard.parseBoard(resp['data']['board']);
      moves = resp['data']['moves'];
    }
    while (moves < 30) {
      var (currentRow, currentCol, destRow, destCol, _) = currentGame.minimaxAB(
          5, 'p', currentGame, (-5, -5, -5, -5), -1000000009, 1000000009);

      String url =
          'https://rota.praetorian.com/rota/service/play.php?request=move&from=${currentRow * 3 + currentCol + 1}&to=${destRow * 3 + destCol + 1}&email=example@gmail.com';
      final response =
          await http.post(Uri.parse(url), headers: headersWithCookies);
      resp = await jsonDecode(response.body);
      print(resp);
      if (resp['status'] == 'fail') exit(0);
      if (resp['data'].containsKey('hash')) {
        hash.add(resp['data']['hash']);
      }
      currentGame = GameBoard.parseBoard(resp['data']['board']);
      moves = resp['data']['moves'];
    }
    final response1 = await http.post(
        Uri.parse(
            'https://rota.praetorian.com/rota/service/play.php?request=next&email=example@gmail.com'),
        headers: headersWithCookies);
    print(response1.body);
    resp = await jsonDecode(response1.body);
    if (!resp['data'].containsKey('board')) {
      if (resp['data'].containsKey('hash')) {
        hash.add(resp['data']['hash']);
        final filePath = 'assets/data.txt';
        writeListToFile(filePath, hash);
        print(hash);
      }
      exit(0);
    }
    currentGame = GameBoard.parseBoard(resp['data']['board']);
    games++;
  }
}

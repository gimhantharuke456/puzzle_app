import 'dart:convert';
import 'package:http/http.dart' as http;

class CrosswordSolverService {
  final String apiKey = 'b0625de1cdmsh64505911f2df9bap1d2a87jsnb93d58568e13';
  final String apiHost = 'crossword-solver.p.rapidapi.com';

  Future<List<String>> getSuggestions(String pattern) async {
    final uri = Uri.https(apiHost, '/cross', {'word': pattern});
    final response = await http.get(uri, headers: {
      'X-RapidAPI-Key': apiKey,
      'X-RapidAPI-Host': apiHost,
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final suggestions = List<String>.from(data['suggestions']);
      return suggestions;
    } else {
      throw Exception('Failed to load suggestions');
    }
  }
}

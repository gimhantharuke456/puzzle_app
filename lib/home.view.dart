import 'package:flutter/material.dart';
import 'dart:math';

import 'package:puzzle_app/widgets/common_gradient_button.dart';
import 'package:puzzle_app/widgets/common_input_field.dart';
import 'package:puzzle_app/widgets/gradient_app_bar.dart';
import 'package:puzzle_app/widgets/loading.widget.dart';
import '../services/crossword_db_service.dart';
import '../models/crossword.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<Color> _generateRandomGradient() {
    final Random random = Random();
    Color color1 = Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
    Color color2 = Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
    return [color1, color2];
  }

  final _patternController = TextEditingController();
  final _clueController = TextEditingController();
  final _maxLengthController = TextEditingController();
  final _excludeLettersController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  List<CrossWord> _suggestions = [];
  List<CrossWord> _filteredSuggestions = [];
  bool _isLoading = false;
  String _searchCriteria = 'Pattern';

  void _getSuggestions() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _suggestions = [];
      _filteredSuggestions = [];
    });

    final dbService = CrossWordDbService();

    String pattern = _patternController.text.trim();
    String clue = _clueController.text.trim();
    int? maxLength = int.tryParse(_maxLengthController.text.trim());
    String excludeLetters = _excludeLettersController.text.trim();

    try {
      List<CrossWord> results;
      if (_searchCriteria == 'Pattern') {
        results = await dbService.searchWords(
          pattern,
          maxLength ?? 100, // Set a default max length if not provided
          excludeLetters,
        );
      } else {
        // Implement search by clue here if needed
        results = []; // Placeholder, implement search by clue logic if required
      }

      setState(() {
        _suggestions = results;
        _filteredSuggestions = results;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching suggestions: $error')),
      );
    }
  }

  void _applyFilters() {
    int? maxLength = int.tryParse(_maxLengthController.text.trim());
    String excludeLetters = _excludeLettersController.text.trim();

    setState(() {
      _filteredSuggestions = _suggestions.where((suggestion) {
        if (maxLength != null && suggestion.word.length > maxLength) {
          return false;
        }
        for (var letter in excludeLetters.split('')) {
          if (suggestion.word.toLowerCase().contains(letter.toLowerCase())) {
            return false;
          }
        }
        return true;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(title: 'Crossword Solver'),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: const Icon(
          Icons.filter_vintage_rounded,
          color: Colors.white,
        ),
        onPressed: () {
          showModalBottomSheet(
              context: context,
              backgroundColor: Colors.white,
              builder: (context) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 32,
                      ),
                      const Text(
                        "Add Filters",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Divider(),
                      const SizedBox(
                        height: 10,
                      ),
                      CommonInputField(
                        controller: _maxLengthController,
                        hintText: 'Enter max length (optional)',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      CommonInputField(
                        controller: _excludeLettersController,
                        hintText: 'Exclude letters (optional)',
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      CommonGradientButton(
                        text: "Apply Filters",
                        onPressed: () {
                          _applyFilters();
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                );
              });
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(
                height: 32,
              ),
              DropdownButtonFormField<String>(
                value: _searchCriteria,
                items: <String>['Pattern', 'Clue']
                    .map((label) => DropdownMenuItem(
                          child: Text(label),
                          value: label,
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _searchCriteria = value!;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search by",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  filled: true,
                  labelText: "Search by",
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 20.0, horizontal: 20.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _searchCriteria == 'Pattern'
                  ? CommonInputField(
                      controller: _patternController,
                      hintText: "Pattern (ex:c_t)",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a pattern';
                        }
                        return null;
                      },
                    )
                  : CommonInputField(
                      controller: _clueController,
                      hintText: "Clue (an animal)",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a clue';
                        }
                        return null;
                      },
                    ),
              const SizedBox(height: 20),
              _isLoading
                  ? const LoadingWidget()
                  : CommonGradientButton(
                      onPressed: _getSuggestions,
                      text: 'Get Suggestions',
                    ),
              const SizedBox(height: 20),
              _filteredSuggestions.isEmpty
                  ? const Text('No suggestions yet.')
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredSuggestions.length,
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _generateRandomGradient(),
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 5.0),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 20.0),
                            title: Text(
                              _filteredSuggestions[index].word,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18.0, // Increased font size
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              _filteredSuggestions[index].clue,
                              style: TextStyle(
                                color: Colors.grey.shade200,
                                fontSize: 16.0, // Increased font size
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

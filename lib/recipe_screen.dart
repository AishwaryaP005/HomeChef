import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'recipe_detail_screen.dart';


class AllRecipesScreen extends StatefulWidget {
  @override
  _AllRecipesScreenState createState() => _AllRecipesScreenState();
}




class _AllRecipesScreenState extends State<AllRecipesScreen> {
  List<Map<String, dynamic>> recipes = [];
  List<Map<String, dynamic>> filteredRecipes = [];
  String searchQuery = "";
  String selectedCuisine = "All";
  String selectedDiet = "All";
  String selectedDifficulty = "All";




  final List<String> cuisines = ["All", "Indian", "Italian", "Chinese", "Mexican"];
  final List<String> diets = ["All", "Vegetarian", "Vegan", "Keto", "Gluten-Free"];
  final List<String> difficulties = ["All", "Easy", "Medium", "Hard"];




  @override
  void initState() {
    super.initState();
    fetchRecipes();
  }




  Future<void> fetchRecipes() async {
    var snapshot = await FirebaseFirestore.instance.collection('recipes').get();
    setState(() {
      recipes = snapshot.docs.map((doc) => <String, dynamic>{...doc.data(), 'id': doc.id}).toList();
      filteredRecipes = recipes;
    });
  }




  void applyFilters() {
    setState(() {
      filteredRecipes = recipes.where((r) {
        bool matchSearch = r['name'].toString().toLowerCase().contains(searchQuery.toLowerCase());
        bool matchCuisine = selectedCuisine == "All" || r['cuisine'] == selectedCuisine;
        bool matchDiet = selectedDiet == "All" || r['diet'] == selectedDiet;
        bool matchDifficulty = selectedDifficulty == "All" || r['difficulty'] == selectedDifficulty;
        return matchSearch && matchCuisine && matchDiet && matchDifficulty;
      }).toList();
    });
  }




  Widget filterDropdown(String label, String value, List<String> options, Function(String?) onChanged) {
    return DropdownButton<String>(
      value: value,
      items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
      onChanged: onChanged,
      underline: SizedBox(),
    );
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Recipes"), backgroundColor: Colors.green[700]),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search recipes...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onChanged: (val) {
                searchQuery = val;
                applyFilters();
              },
            ),
          ),
          // Filter chips row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                filterDropdown("Cuisine", selectedCuisine, cuisines, (val) {
                  selectedCuisine = val!;
                  applyFilters();
                }),
                SizedBox(width: 10),
                filterDropdown("Diet", selectedDiet, diets, (val) {
                  selectedDiet = val!;
                  applyFilters();
                }),
                SizedBox(width: 10),
                filterDropdown("Difficulty", selectedDifficulty, difficulties, (val) {
                  selectedDifficulty = val!;
                  applyFilters();
                }),
              ],
            ),
          ),
          // Recipe list
          Expanded(
            child: filteredRecipes.isEmpty
                ? Center(child: Text("No recipes found"))
                : ListView.builder(
              itemCount: filteredRecipes.length,
              itemBuilder: (context, index) {
                var recipe = filteredRecipes[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        // Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: recipe['image'] != null
                              ? Image.network(recipe['image'], width: 60, height: 60, fit: BoxFit.cover)
                              : Container(width: 60, height: 60, color: Colors.orange[100],
                              child: Icon(Icons.restaurant_menu, color: Colors.orange)),
                        ),
                        SizedBox(width: 12),
                        // Text info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(recipe['name'] ?? "", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              SizedBox(height: 4),
                              Text(
                                "${recipe['cuisine'] ?? ''} · ${recipe['difficulty'] ?? ''} · ${recipe['calories'] ?? ''} kcal",
                                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        // THIS IS THE EXPLICIT BUTTON
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(10),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RecipeDetailScreen(recipe: Map<String, dynamic>.from(recipe)),
                              ),
                            );
                          },
                          child: Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ),
                );;
              },
            ),
          ),
        ],
      ),
    );
  }
}




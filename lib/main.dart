import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homechef/recipe_detail_screen.dart';
import 'package:homechef/recipe_screen.dart'; // ← ADD THIS IMPORT
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'home_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}


class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}


class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;


  final List<Widget> screens = [
    HomePage(username: "User"),   // Home
    RecipeScreen(),               // Ingredient-based recipes (defined below in main.dart)
    ChatbotScreen(),              // Chatbot
    AllRecipesScreen(),           // ← NEW: All Recipes tab (from recipe_screen.dart)
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed, // ← Required for 4+ items
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: "Recipes",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: "Chatbot",
          ),
          BottomNavigationBarItem(       // ← NEW ITEM
            icon: Icon(Icons.menu_book),
            label: "All Recipes",
          ),
        ],
      ),
    );
  }
}


// ... rest of your existing code (RecipeScreen, ChatbotScreen) unchanged








// ================= RECIPES SCREEN =================




// ================= RECIPES =================
class RecipeScreen extends StatefulWidget {
  @override
  _RecipeScreenState createState() => _RecipeScreenState();
}




class _RecipeScreenState extends State<RecipeScreen> {
  List recipes = [];
  List selectedIngredients = [];




  List<Map<String, String>> allIngredients = [
    {"name": "rice", "image": "assets/images/rice.png"},
    {"name": "carrot", "image": "assets/images/carrot.png"},
    {"name": "beans", "image": "assets/images/beans.png"},
    {"name": "paneer", "image": "assets/images/paneer(1).png"},
    {"name": "butter", "image": "assets/images/butter.png"},
    {"name": "tomato", "image": "assets/images/tomato.png"},
    {"name": "egg", "image": "assets/images/egg.png"},
    {"name": "oil", "image": "assets/images/oil.png"},
  ];




  Future<void> fetchRecipes() async {
    var snapshot = await FirebaseFirestore.instance.collection('recipes').get();




    var filtered = snapshot.docs.where((doc) {
      var data = doc.data();
      List ingredients = data['ingredients'];




      List<String> ingredientList =
      ingredients.map((e) => e.toString().toLowerCase()).toList();




      return selectedIngredients.every((selected) {
        return ingredientList.any((item) => item.contains(selected));
      });
    }).map((doc) => doc.data()).toList();




    setState(() {
      recipes = filtered;
    });
  }




  Widget _infoChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 14, color: Colors.green),
      label: Text(label, style: TextStyle(fontSize: 12)),
      backgroundColor: Colors.green[50],
    );
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("HomeChef")),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Text(
              "Select Ingredients",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),




            SizedBox(height: 10),




            // 🔥 INGREDIENT GRID
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: allIngredients.map((item) {
                String name = item['name']!;
                String image = item['image']!;
                bool isSelected = selectedIngredients.contains(name);




                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedIngredients.remove(name);
                      } else {
                        selectedIngredients.add(name);
                      }
                    });
                  },
                  child: Container(
                    width: 80,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.green[200] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Image.asset(image, height: 40),
                        SizedBox(height: 5),
                        Text(name, style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),




            SizedBox(height: 10),




            ElevatedButton(
              onPressed: fetchRecipes,
              child: Text("Generate Recipes"),
            ),




            SizedBox(height: 10),




            // 🔥 RECIPE CARDS (UPDATED UI)
            Expanded(
              child: recipes.isEmpty
                  ? Center(child: Text("No recipes found"))
                  : ListView.builder(
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  var recipe = recipes[index];




                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RecipeDetailScreen(
                            recipe: Map<String, dynamic>.from(recipe),
                          ),
                        ),
                      );
                    },
                    child: Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // IMAGE
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                            child: Image.network(
                              recipe['image'],
                              height: 160,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),




                          Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  recipe['name'],
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 6),
                                Row(
                                  children: [
                                    _infoChip(Icons.timer,
                                        "${recipe['cookingTime']} min"),
                                    SizedBox(width: 6),
                                    _infoChip(Icons.bar_chart,
                                        recipe['difficulty']),
                                    SizedBox(width: 6),
                                    _infoChip(Icons.local_fire_department,
                                        "${recipe['calories']} kcal"),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}






// ================= CHATBOT SCREEN =================








class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}








class _ChatbotScreenState extends State<ChatbotScreen> {
  TextEditingController controller = TextEditingController();
  List<Map<String, String>> messages = [];








  // 🔥 CALL API
















  static const String apiKey = "key_here";
















  Future<String> getBotResponse(String userMessage) async {
    try {
      final url = Uri.parse(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey",
      );








      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": userMessage}
              ]
            }
          ]
        }),
      );








      print(response.body); // debug








      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data["candidates"][0]["content"]["parts"][0]["text"];
      } else {
        return "Error: ${response.statusCode}";
      }
    } catch (e) {
      return "Connection failed";
    }
  }








  // 🔥 SEND MESSAGE
  void sendMessage() async {
    String userText = controller.text.trim();
    if (userText.isEmpty) return;








    setState(() {
      messages.add({"sender": "user", "text": userText});
      messages.add({"sender": "bot", "text": "Typing..."}); // 👈 loading
    });








    controller.clear();








    String botReply = await getBotResponse(userText);








    setState(() {
      messages.removeLast(); // remove "Typing..."
      messages.add({"sender": "bot", "text": botReply});
    });
  }








  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chatbot"),
      ),
      body: Column(
        children: [
          // 🔹 MESSAGE LIST
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                var msg = messages[index];








                return Container(
                  alignment: msg["sender"] == "user"
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  padding: EdgeInsets.all(10),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: msg["sender"] == "user"
                          ? Colors.blue
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      msg["text"]!,
                      style: TextStyle(
                        color: msg["sender"] == "user"
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),








          // 🔹 INPUT FIELD
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration:
                  InputDecoration(hintText: "Ask something..."),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: sendMessage,
              )
            ],
          )
        ],
      ),
    );
  }
}







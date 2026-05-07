import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homechef/profile.dart';
import 'package:homechef/user_model.dart';
import 'recipe_detail_screen.dart';
import 'recipe_screen.dart';
import 'dart:async';

// ─── Brand Palette ────────────────────────────────────────────────────────────
const kPrimary   = Color(0xFF55AD9B);
const kSecondary = Color(0xFF95D2B3);
const kLight     = Color(0xFFD8EFD3);
const kBackground= Color(0xFFF1F8E8);
// ──────────────────────────────────────────────────────────────────────────────

class HomePage extends StatefulWidget {
  final String username;
  HomePage({required this.username});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> recipes = [];
  final PageController _pageController = PageController();
  int currentPage = 0;

  final List<String> healthTips = [
    "🥗 Eat vegetables daily for better immunity",
    "💪 Protein helps repair body tissues",
    "🔥 1g of protein contains 4 calories",
    "🍎 Fruits provide essential vitamins",
  ];

  Future<void> fetchRecipes() async {
    var snapshot =
        await FirebaseFirestore.instance.collection('recipes').get();
    setState(() {
      recipes = snapshot.docs
          .map((doc) => {...doc.data(), "id": doc.id})
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchRecipes();
    Timer.periodic(Duration(seconds: 3), (timer) {
      if (!mounted) return;
      currentPage = (currentPage + 1) % healthTips.length;
      _pageController.animateToPage(
        currentPage,
        duration: Duration(milliseconds: 400),
        curve: Curves.easeIn,
      );
    });
  }

  Widget recipeCard(Map<String, dynamic> recipe) {
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
      child: Container(
        margin: EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: kPrimary.withOpacity(0.12),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.horizontal(left: Radius.circular(18)),
              child: Image.network(
                recipe['image'] ?? "",
                width: 110,
                height: 95,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 110,
                  height: 95,
                  color: kLight,
                  child: Icon(Icons.restaurant_menu, color: kPrimary, size: 32),
                ),
              ),
            ),
            SizedBox(width: 12),
            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe['name'] ?? "",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF1B4332),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "${recipe['cuisine'] ?? ''}",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        _miniChip(Icons.local_fire_department,
                            "${recipe['calories'] ?? '?'} kcal"),
                        SizedBox(width: 6),
                        _miniChip(Icons.timer,
                            "${recipe['cookingTime'] ?? '?'} min"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.chevron_right, color: kPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: kLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: kPrimary),
          SizedBox(width: 3),
          Text(label, style: TextStyle(fontSize: 10, color: kPrimary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── HEADER ────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hello, ${widget.username} 👋",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B4332),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "What would you like to cook today?",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () async {
                      var data = await FirebaseFirestore.instance
                          .collection("users")
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .get();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProfileScreen(
                            user: UserModel(
                              age: data["age"],
                              weight: data["weight"],
                              height: data["height"],
                              gender: data["gender"],
                              activity: data["activity"],
                              diet: data["diet"],
                              calories: data["calories"],
                              protein: data["protein"],
                              carbs: data["carbs"],
                              fat: data["fat"],
                              water: data["water"],
                            ),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: kSecondary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: kPrimary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          )
                        ],
                      ),
                      child: Icon(Icons.person, color: Colors.white, size: 24),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 18),

            // ── SEARCH BAR ────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimary.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    )
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search Recipes 🍳",
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: kPrimary),
                    filled: true,
                    fillColor: Colors.transparent,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  ),
                  onSubmitted: (value) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AllRecipesScreen(initialSearch: value),
                      ),
                    );
                  },
                ),
              ),
            ),

            SizedBox(height: 20),

            // ── HEALTH TIP SLIDER ─────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 130,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [kPrimary, kSecondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimary.withOpacity(0.35),
                      blurRadius: 12,
                      offset: Offset(0, 5),
                    )
                  ],
                ),
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => currentPage = index);
                  },
                  itemCount: healthTips.length,
                  itemBuilder: (context, index) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          healthTips[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.4,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            SizedBox(height: 10),

            // ── DOTS ──────────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                healthTips.length,
                (index) => AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 3),
                  width: currentPage == index ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: currentPage == index ? kPrimary : kSecondary,
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),

            // ── SECTION TITLE ─────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Recommended Recipes 🍽",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B4332),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AllRecipesScreen()),
                    ),
                    child: Text(
                      "See all",
                      style: TextStyle(
                        fontSize: 13,
                        color: kPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 10),

            // ── RECIPE LIST ───────────────────────────────────────────────
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20),
                itemCount: recipes.length,
                itemBuilder: (context, index) => recipeCard(recipes[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

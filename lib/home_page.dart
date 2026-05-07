import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:math';


class HomePage extends StatefulWidget {
  final String username;


  HomePage({required this.username});


  @override
  _HomePageState createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {


  List randomRecipes = [];


  final PageController _pageController = PageController();
  int currentPage = 0;


  final List<String> healthTips = [


    "🥗 Eat vegetables daily for better immunity",


    "💪 Protein helps repair body tissues",


    "🔥 1g of protein contains 4 calories",


    "🍎 Fruits provide essential vitamins",


  ];


  Future<void> fetchRandomRecipes() async {


    var snapshot = await FirebaseFirestore.instance
        .collection('recipes')
        .get();


    var docs = snapshot.docs.map((doc) => doc.data()).toList();


    docs.shuffle(Random());


    setState(() {
      randomRecipes = docs;
    });
  }


  @override
  void initState() {
    super.initState();


    fetchRandomRecipes();


    Timer.periodic(Duration(seconds: 3), (Timer timer) {


      if (currentPage < healthTips.length - 1) {
        currentPage++;
      } else {
        currentPage = 0;
      }


      _pageController.animateToPage(
        currentPage,
        duration: Duration(milliseconds: 400),
        curve: Curves.easeIn,
      );


    });


  }


  Widget ingredientChip(String name, Color color) {


    return Padding(
      padding: EdgeInsets.only(right: 10),


      child: Chip(
        label: Text(name),


        backgroundColor: color.withOpacity(0.2),


        avatar: CircleAvatar(
          backgroundColor: color,
          child: Icon(Icons.restaurant, size: 16, color: Colors.white),
        ),
      ),
    );
  }


  Widget recipeCard(recipe) {


    return Container(
      width: 160,
      margin: EdgeInsets.only(right: 12),


      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
            )
          ],
        ),


        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,


          children: [


            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),


              child: Image.network(
                recipe['image'] ??
                    "https://images.unsplash.com/photo-1546069901-ba9599a7e63c",
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),


            Padding(
              padding: EdgeInsets.all(8),


              child: Text(
                recipe['name'] ?? "Recipe",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {


    return Scaffold(


      backgroundColor: Color(0xFFE8F5E9),


      body: SafeArea(


        child: SingleChildScrollView(


          child: Column(


            crossAxisAlignment: CrossAxisAlignment.start,


            children: [


              // Greeting
              Padding(
                padding: EdgeInsets.all(16),


                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,


                  children: [


                    Text(
                      "Hello ${widget.username} 👋",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),


                    CircleAvatar(
                      backgroundColor: Colors.pink[200],
                      child: Icon(Icons.favorite, color: Colors.white),
                    )
                  ],
                ),
              ),


              // Search Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),


                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search Recipes 🍳",
                    prefixIcon: Icon(Icons.search, color: Colors.green),


                    filled: true,
                    fillColor: Colors.white,


                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),


              SizedBox(height: 20),


              // Health Tips Slider
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),


                child: Column(


                  children: [


                    Container(
                      height: 150,
                      width: double.infinity,


                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),


                        gradient: LinearGradient(
                          colors: [
                            Colors.pink.shade200,
                            Colors.orange.shade200,
                          ],
                        ),
                      ),


                      child: PageView.builder(


                        controller: _pageController,


                        onPageChanged: (index) {
                          setState(() {
                            currentPage = index;
                          });
                        },


                        itemCount: healthTips.length,


                        itemBuilder: (context, index) {


                          return Center(


                            child: Padding(
                              padding: EdgeInsets.all(20),


                              child: Text(
                                healthTips[index],


                                textAlign: TextAlign.center,


                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),


                    SizedBox(height: 10),


                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,


                      children: List.generate(
                        healthTips.length,


                            (index) => Container(
                          margin: EdgeInsets.symmetric(horizontal: 4),


                          width: currentPage == index ? 10 : 8,
                          height: currentPage == index ? 10 : 8,


                          decoration: BoxDecoration(
                            shape: BoxShape.circle,


                            color: currentPage == index
                                ? Colors.green
                                : Colors.green.shade200,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),


              SizedBox(height: 25),


              // Ingredient Chips
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),


                child: Text(
                  "Find Recipes By Ingredient 🧑‍🍳",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),


              SizedBox(height: 10),


              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),


                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,


                  child: Row(


                    children: [


                      ingredientChip("Egg", Colors.orange),
                      ingredientChip("Tomato", Colors.red),
                      ingredientChip("Paneer", Colors.pink),
                      ingredientChip("Broccoli", Colors.green),
                      ingredientChip("Rice", Colors.blue),


                    ],
                  ),
                ),
              ),


              SizedBox(height: 25),


              // Horizontal Recipes Section 1
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),


                child: Text(
                  "Recommended Recipes 🍽",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ),


              SizedBox(height: 15),


              SizedBox(
                height: 170,


                child: ListView.builder(


                  scrollDirection: Axis.horizontal,


                  itemCount: randomRecipes.length,


                  itemBuilder: (context, index) {


                    var recipe = randomRecipes[index];


                    return recipeCard(recipe);
                  },
                ),
              ),


              SizedBox(height: 25),


              // Horizontal Recipes Section 2
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),


                child: Text(
                  "Healthy Choices 🥗",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ),


              SizedBox(height: 15),


              SizedBox(
                height: 170,


                child: ListView.builder(


                  scrollDirection: Axis.horizontal,


                  itemCount: randomRecipes.length,


                  itemBuilder: (context, index) {


                    var recipe = randomRecipes[index];


                    return recipeCard(recipe);
                  },
                ),
              ),


              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}




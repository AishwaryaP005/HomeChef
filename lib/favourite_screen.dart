import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'recipe_detail_screen.dart';

const _kPrimary    = Color(0xFF55AD9B);
const _kSecondary  = Color(0xFF95D2B3);
const _kLight      = Color(0xFFD8EFD3);
const _kBackground = Color(0xFFF1F8E8);

class FavoritesScreen extends StatelessWidget {
  Future<void> _removeFavorite(BuildContext context, String recipeId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(recipeId)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Removed from favorites"),
        backgroundColor: _kPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: _kBackground,
        appBar: _appBar(),
        body: Center(child: Text("Please login to view favorites.")),
      );
    }

    return Scaffold(
      backgroundColor: _kBackground,
      appBar: _appBar(),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .orderBy('addedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: _kPrimary));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _kLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.favorite_outline,
                        size: 56, color: _kPrimary),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "No favorites yet!",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B4332),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Tap ❤️ on any recipe to save it here.",
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                ],
              ),
            );
          }

          final favorites = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final data =
                  favorites[index].data() as Map<String, dynamic>;
              final recipeId = favorites[index].id;

              return Container(
                margin: EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: _kPrimary.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    )
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('recipes')
                                .doc(recipeId)
                                .get(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Scaffold(
                                  body: Center(
                                      child: CircularProgressIndicator(
                                          color: _kPrimary)),
                                );
                              }
                              final recipeData = snapshot.data!.data()
                                  as Map<String, dynamic>;
                              return RecipeDetailScreen(
                                recipe: {...recipeData, 'id': recipeId},
                              );
                            },
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: data['image'] != null &&
                                    data['image'].toString().isNotEmpty
                                ? Image.network(
                                    data['image'],
                                    width: 72,
                                    height: 72,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _placeholder(),
                                  )
                                : _placeholder(),
                          ),
                          SizedBox(width: 14),

                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['name'] ?? '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Color(0xFF1B4332),
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "${data['cuisine'] ?? ''} · ${data['difficulty'] ?? ''}",
                                  style: TextStyle(
                                      color: Colors.grey[500], fontSize: 13),
                                ),
                                SizedBox(height: 6),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _kLight,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.favorite,
                                          size: 11,
                                          color: Color(0xFFE91E63)),
                                      SizedBox(width: 3),
                                      Text(
                                        "Saved",
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: _kPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Remove button
                          GestureDetector(
                            onTap: () =>
                                _removeFavorite(context, recipeId),
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Color(0xFFFFEBEE),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.favorite,
                                  color: Color(0xFFE91E63), size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  AppBar _appBar() => AppBar(
        title: Text(
          "My Favourites ❤️",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: _kPrimary,
        elevation: 0,
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(color: Colors.white),
      );

  Widget _placeholder() => Container(
        width: 72,
        height: 72,
        color: _kLight,
        child: Icon(Icons.restaurant_menu, color: _kPrimary, size: 28),
      );
}

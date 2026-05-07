import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'firebase_service.dart';
import 'user_model.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:image_cropper/image_cropper.dart';
import 'favourite_screen.dart';

const _kPrimary    = Color(0xFF55AD9B);
const _kSecondary  = Color(0xFF95D2B3);
const _kLight      = Color(0xFFD8EFD3);
const _kBackground = Color(0xFFF1F8E8);

class ProfileScreen extends StatefulWidget {
  final UserModel user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? imageFile;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> pickImage() async {
    try {
      PermissionStatus status = await Permission.photos.request();
      if (!status.isGranted) {
        print("Permission denied");
        return;
      }

      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 30,
      );
      if (picked == null) return;

      CroppedFile? cropped = await ImageCropper().cropImage(
        sourcePath: picked.path,
        compressQuality: 30,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
            statusBarColor: Colors.blue,
            activeControlsWidgetColor: Colors.blue,
          ),
        ],
      );
      if (cropped == null) return;

      File file = File(cropped.path);
      setState(() => imageFile = file);

      String uid = FirebaseService().getUid();
      final bytes = await file.readAsBytes();
      String base64Image = base64Encode(bytes);

      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .update({"profileImageBase64": base64Image});

      print("Cropped image stored in Firestore");
    } catch (e) {
      print("ERROR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image upload failed")),
      );
    }
  }

  void loadUser() async {
    var data = await FirebaseService().getUserData();
    if (data != null) {
      setState(() {
        widget.user.profileImageUrl = data["profileImageBase64"];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var user = widget.user;

    return Scaffold(
      backgroundColor: _kBackground,
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: _kPrimary,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // ── Profile image section ──────────────────────────────
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: _kSecondary, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: _kPrimary.withOpacity(0.2),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              )
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 55,
                            backgroundColor: _kLight,
                            backgroundImage: imageFile != null
                                ? FileImage(imageFile!)
                                : (user.profileImageUrl != null &&
                                        user.profileImageUrl!.isNotEmpty)
                                    ? MemoryImage(
                                            base64Decode(user.profileImageUrl!))
                                        as ImageProvider
                                    : null,
                            child: (imageFile == null &&
                                    (user.profileImageUrl == null ||
                                        user.profileImageUrl!.isEmpty))
                                ? Icon(Icons.person,
                                    size: 52, color: _kPrimary)
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: pickImage,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: _kPrimary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white, width: 2),
                              ),
                              child: Icon(Icons.camera_alt,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    if (imageFile != null)
                      ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            String uid = FirebaseService().getUid();
                            final bytes = await imageFile!.readAsBytes();
                            String base64Image = base64Encode(bytes);
                            await FirebaseFirestore.instance
                                .collection("users")
                                .doc(uid)
                                .update(
                                    {"profileImageBase64": base64Image});
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Profile updated")),
                            );
                          } catch (e) {
                            print("ERROR: $e");
                          }
                        },
                        icon: Icon(Icons.check, size: 16),
                        label: Text("Save Photo"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kPrimary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                        ),
                      ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // ── User details card ──────────────────────────────────
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _cardHeader(Icons.person_outline, "Personal Details"),
                    Divider(color: _kLight, height: 20),
                    _detailGrid([
                      ["Age",      "${user.age} yrs"],
                      ["Gender",   user.gender],
                      ["Height",   "${user.height} cm"],
                      ["Weight",   "${user.weight} kg"],
                      ["Activity", user.activity],
                      ["Diet",     user.diet],
                    ]),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // ── Nutrition breakdown ────────────────────────────────
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _cardHeader(Icons.pie_chart_outline, "Nutrition Breakdown"),
                    Divider(color: _kLight, height: 20),
                    SizedBox(
                      height: 230,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              value: user.protein,
                              title:
                                  "Protein\n${user.protein.toStringAsFixed(0)}g",
                              color: _kPrimary,
                              radius: 60,
                              titleStyle: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            PieChartSectionData(
                              value: user.carbs,
                              title:
                                  "Carbs\n${user.carbs.toStringAsFixed(0)}g",
                              color: Color(0xFFFF9800),
                              radius: 60,
                              titleStyle: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            PieChartSectionData(
                              value: user.fat,
                              title:
                                  "Fat\n${user.fat.toStringAsFixed(0)}g",
                              color: Color(0xFFF44336),
                              radius: 60,
                              titleStyle: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ],
                          sectionsSpace: 3,
                          centerSpaceRadius: 38,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // ── Summary card ───────────────────────────────────────
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _cardHeader(
                        Icons.analytics_outlined, "Daily Nutrition Goals"),
                    Divider(color: _kLight, height: 20),
                    _nutritionRow(Icons.local_fire_department,
                        "Calories", "${user.calories.toStringAsFixed(0)} kcal",
                        Color(0xFFFF5722)),
                    _nutritionRow(Icons.fitness_center,
                        "Protein", "${user.protein.toStringAsFixed(0)} g",
                        _kPrimary),
                    _nutritionRow(Icons.grain,
                        "Carbs", "${user.carbs.toStringAsFixed(0)} g",
                        Color(0xFFFF9800)),
                    _nutritionRow(Icons.opacity,
                        "Fat", "${user.fat.toStringAsFixed(0)} g",
                        Color(0xFFF44336)),
                    _nutritionRow(Icons.water_drop_outlined,
                        "Water", "${user.water.toStringAsFixed(2)} L",
                        Color(0xFF2196F3)),
                    _nutritionRow(Icons.restaurant_menu,
                        "Diet", user.diet, _kSecondary),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // ── Favourites button ──────────────────────────────────
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => FavoritesScreen()),
                  );
                },
                icon: Icon(Icons.favorite_outline, color: Colors.white),
                label: Text(
                  "My Favourites",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFE91E63),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
              ),

              SizedBox(height: 10),

              // ── Logout button ──────────────────────────────────────
              ElevatedButton.icon(
                onPressed: () async {
                  await FirebaseService().logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                    (route) => false,
                  );
                },
                icon: Icon(Icons.logout, color: Colors.white),
                label: Text(
                  "Logout",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF44336),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
              ),

              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: EdgeInsets.all(16),
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
      child: child,
    );
  }

  Widget _cardHeader(IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _kLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: _kPrimary, size: 18),
        ),
        SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Color(0xFF1B4332),
          ),
        ),
      ],
    );
  }

  Widget _detailGrid(List<List<String>> items) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        return Container(
          width: (MediaQuery.of(context).size.width - 80) / 2,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _kBackground,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item[0],
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 2),
              Text(
                item[1],
                style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1B4332),
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _nutritionRow(
      IconData icon, String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          Spacer(),
          Text(
            value,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B4332)),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'calculator.dart';
import 'firebase_service.dart';
import 'user_model.dart';
import 'profile.dart';
import 'dart:io';
import 'storage_service.dart';

// ─── Brand Colors ────────────────────────────────────────────
const kPrimaryGreen = Color(0xFFA3DC9A);
const kSoftLime     = Color(0xFFDEE791);
const kCreamYellow  = Color(0xFFFFF9BD);
const kSoftPeach    = Color(0xFFFFD6BA);
const kDarkGreen    = Color(0xFF3A7D44);

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int step = 0;

  int age       = 20;
  double weight = 60;
  double height = 170;
  String gender   = "Male";
  String activity = "Sedentary";
  String diet     = "Vegetarian";
  File? imageFile;
  String? imageUrl;

  void nextStep() {
    if (step < 2) {
      setState(() => step++);
    } else {
      submit();
    }
  }

  void submit() async {
    double calories =
        Calculator.calculateCalories(age, weight, height, gender, activity);
    var macros = Calculator.calculateMacros(calories);
    double water = Calculator.calculateWater(weight);

    UserModel user = UserModel(
      age: age,
      weight: weight,
      height: height,
      gender: gender,
      activity: activity,
      diet: diet,
      calories: calories,
      protein: macros["protein"]!,
      carbs: macros["carbs"]!,
      fat: macros["fat"]!,
      water: water,
    );

    if (imageFile != null) {
      String uid = FirebaseService().getUid();
      imageUrl = await StorageService().uploadProfileImage(uid, imageFile!);
    }

    await FirebaseService().saveUser(user);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfileScreen(user: user)),
    );
  }

  // ─── Input Field Helper ──────────────────────────────────────
  Widget _inputField({
    required String label,
    required TextInputType keyboardType,
    required Function(String) onChanged,
    String? initialValue,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
      ),
    );
  }

  // ─── Dropdown Helper ─────────────────────────────────────────
  Widget _styledDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required Function(T?) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          hint: Text(label,
              style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          icon: const Icon(Icons.keyboard_arrow_down, color: kDarkGreen),
          style: const TextStyle(
              color: Color(0xFF2D2D2D),
              fontSize: 14,
              fontWeight: FontWeight.w500),
          items: items
              .map((e) => DropdownMenuItem<T>(value: e, child: Text(e.toString())))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCreamYellow,
      appBar: AppBar(
        backgroundColor: kDarkGreen,
        foregroundColor: Colors.white,
        title: const Text("Setup Your Profile",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: kDarkGreen,
          ),
        ),
        child: Stepper(
          currentStep: step,
          onStepContinue: nextStep,
          onStepCancel: () {
            if (step > 0) setState(() => step--);
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kDarkGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: Text(step < 2 ? "Next" : "Finish",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  if (step > 0) ...[
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text("Back",
                          style: TextStyle(color: Colors.grey)),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            Step(
              title: const Text("Basic Info",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              isActive: step >= 0,
              state: step > 0 ? StepState.complete : StepState.indexed,
              content: Column(
                children: [
                  _inputField(
                    label: "Age",
                    keyboardType: TextInputType.number,
                    onChanged: (val) =>
                        age = int.tryParse(val) ?? age,
                  ),
                  _inputField(
                    label: "Weight (kg)",
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    onChanged: (val) =>
                        weight = double.tryParse(val) ?? weight,
                  ),
                  _inputField(
                    label: "Height (cm)",
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    onChanged: (val) =>
                        height = double.tryParse(val) ?? height,
                  ),
                ],
              ),
            ),
            Step(
              title: const Text("Lifestyle",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              isActive: step >= 1,
              state: step > 1 ? StepState.complete : StepState.indexed,
              content: Column(
                children: [
                  _styledDropdown<String>(
                    label: "Gender",
                    value: gender,
                    items: ["Male", "Female"],
                    onChanged: (val) =>
                        setState(() => gender = val.toString()),
                  ),
                  _styledDropdown<String>(
                    label: "Activity Level",
                    value: activity,
                    items: ["Sedentary", "Moderate", "Active"],
                    onChanged: (val) =>
                        setState(() => activity = val.toString()),
                  ),
                ],
              ),
            ),
            Step(
              title: const Text("Diet Preference",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              isActive: step >= 2,
              state: StepState.indexed,
              content: _styledDropdown<String>(
                label: "Diet Type",
                value: diet,
                items: [
                  "Vegetarian",
                  "Vegan",
                  "Keto",
                  "Diabetic",
                  "Gluten-Free"
                ],
                onChanged: (val) =>
                    setState(() => diet = val.toString()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

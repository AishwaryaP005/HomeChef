class Calculator {
  static double calculateCalories(
      int age, double weight, double height, String gender, String activity) {


    double bmr;


    if (gender == "Male") {
      bmr = 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      bmr = 10 * weight + 6.25 * height - 5 * age - 161;
    }


    double factor = 1.2;
    if (activity == "Moderate") factor = 1.55;
    if (activity == "Active") factor = 1.725;


    return bmr * factor;
  }


  static Map<String, double> calculateMacros(double calories) {
    return {
      "protein": (calories * 0.3) / 4,
      "carbs": (calories * 0.4) / 4,
      "fat": (calories * 0.3) / 9,
    };
  }


  static double calculateWater(double weight) {
    return weight * 0.033;
  }
}


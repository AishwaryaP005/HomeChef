# 🍽️ HomeChef
### Smart Meal Planning • Personalized Nutrition • Sustainable Healthy Living

> A modern Flutter-powered meal planning and recipe discovery application designed to help users eat healthier, plan smarter, and maintain sustainable food habits through personalized nutrition tracking.

---

## 📌 Project Overview

**HomeChef** is a Flutter-based mobile application developed to simplify meal planning and improve healthy eating habits through smart nutrition management.

The application allows users to:
- Discover recipes
- Plan meals efficiently
- Track calorie intake
- Receive meal reminders
- Listen to cooking instructions hands-free
- Maintain balanced nutrition goals

Built using **Flutter + Firebase**, the project combines modern UI design with real-time cloud database functionality.

---

## 📌 Key Features

### 👤 Authentication & User Profiles
- Firebase Authentication (Login & Registration)
- Personalized onboarding experience
- Stores:
  - age
  - height
  - weight
  - calorie goals
  - nutrition details

---

### 🍲 Smart Recipe Discovery
Users can browse recipes dynamically fetched from Firebase Firestore.

Each recipe includes:
- Recipe image
- Cooking time
- Calories
- Difficulty level
- Ingredients
- Cooking instructions

---

### 🔊 Voice-Assisted Cooking
Integrated **Text-to-Speech (TTS)** support allows users to listen to recipe instructions while cooking.

Features:
- Hands-free cooking experience
- Reads recipe steps aloud
- Interactive multimedia integration

---

### 📅 Personalized Meal Planner
Users can create meal schedules for:
- Breakfast
- Lunch
- Dinner

Features include:
- Meal scheduling
- Recipe selection
- Calorie tracking
- Reminder notifications
- Firestore-based meal storage

---

### 📊 Nutrition & Calorie Tracking
The application:
- Fetches user's calorie goal from Firestore
- Calculates calories of selected meals
- Compares selected meals with target calories
- Displays calorie progress visually

---

### 💡 Health Tips Slider
An interactive health tips section built using:
- `PageView`
- `Timer`

The tips automatically scroll every few seconds to improve user engagement.

---

### 🤖 Chatbot Assistant
Integrated chatbot feature for:
- Food-related guidance
- Healthy eating suggestions
- Interactive user support

---

### 🔔 Smart Notifications
Meal reminder notifications implemented using:
- Flutter Local Notifications
- Firebase Messaging support

Users receive reminders for:
- Breakfast
- Lunch
- Dinner

---

## 🌱 Sustainability Aspect

HomeChef promotes sustainable and healthier eating habits through:
- Organized meal planning
- Balanced nutrition tracking
- Efficient meal scheduling
- Health-conscious food selection

The application encourages users to make smarter and more sustainable dietary choices.

---

## 📌 Tech Stack

- Programming Language: Dart
- Framework: Flutter
- Backend: Firebase
- Database: Cloud Firestore (NoSQL)
- Authentication: Firebase Authentication
- Notifications: Firebase Messaging & Flutter Local Notifications
- Multimedia: flutter_tts (Text-to-Speech)
- Image Handling: image_picker

---

## 📌 Database Used

### 🔹 Firebase Firestore (NoSQL Database)

Firestore is used to store:
- User profiles
- Recipes
- Meal planner data
- Nutrition information
- Notification tokens

---

### 🔹 Users Collection Structure

| Field | Description |
|---|---|
| `name` | Stores username |
| `age` | Stores user age |
| `height` | Stores user height |
| `weight` | Stores user weight |
| `calories` | Daily calorie goal |
| `protein` | Protein requirement |
| `carbs` | Carbohydrate requirement |
| `fat` | Fat requirement |
| `mealPlanner` | Stores planned meals |
| `fcmToken` | Stores notification token |

---

### 🔹 Recipes Collection Structure

| Field | Description |
|---|---|
| `name` | Recipe name |
| `image` | Recipe image URL |
| `calories` | Calories in recipe |
| `cookingTime` | Cooking duration |
| `difficulty` | Recipe difficulty |
| `ingredients` | List of ingredients |
| `steps` | Cooking instructions |

---

## 📌 Core Functionalities

| Functionality | Description |
|---|---|
| User Authentication | Secure login & registration |
| Recipe Fetching | Dynamic recipe loading from Firestore |
| Meal Planning | Schedule breakfast, lunch & dinner |
| Nutrition Tracking | Compare meals with calorie goals |
| Voice Instructions | Text-to-Speech cooking guidance |
| Notifications | Meal reminder alerts |
| Chatbot | Food & health assistance |

---

## 📌 Flutter Concepts Used

| Concept | Purpose |
|---|---|
| `StatefulWidget` | Dynamic UI updates |
| `ListView.builder` | Dynamic recipe rendering |
| `PageView` | Health tips slider |
| `Navigator` | Screen navigation |
| `Future & Async` | Firebase operations |
| `Timer` | Auto-scrolling slider |
| `Firestore` | Cloud database integration |

---

## 📌 Multimedia Features

| Multimedia Feature | Purpose |
|---|---|
| Recipe Images | Visual recipe representation |
| Voice Instructions | Audio-based cooking support |
| Notifications | Interactive reminders |
| Chatbot | User interaction |

---

## 📌 Project Workflow

```text
User Login/Register
        ↓
User Data Stored in Firestore
        ↓
Recipes Fetched Dynamically
        ↓
User Selects Meals
        ↓
Calories Calculated Automatically
        ↓
Meal Notifications Scheduled
        ↓
Voice-Assisted Cooking Experience

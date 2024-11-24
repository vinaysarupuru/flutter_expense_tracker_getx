# Expense Tracker App

A modern, feature-rich expense tracking application built with Flutter, implementing clean architecture principles and a beautiful Material Design 3 UI.

## Features

### Core Functionality
- 📊 Real-time expense tracking and management
- 🏷️ Smart tag system with suggestions
- 📁 Dynamic category and subcategory organization
- 📈 Visual expense breakdowns with pie charts
- 🌓 Dark and light theme support
- 🔒 Secure local authentication
- 💾 Offline-first with local SQLite storage

### User Experience
- Clean, intuitive Material Design 3 interface
- Smooth animations and transitions
- Responsive layout for all screen sizes
- Easy-to-use transaction management
- Quick expense categorization
- Visual spending patterns and insights

## Tech Stack

- **Framework**: Flutter
- **Language**: Dart
- **State Management**: GetX
- **Database**: SQLite (sqflite)
- **Architecture**: Clean Architecture
- **UI**: Material Design 3
- **Dependencies**:
  - get: ^4.6.5
  - sqflite: ^2.3.0
  - flutter_colorpicker: ^1.0.3
  - intl: ^0.18.1
  - path: ^1.8.3

## Project Structure

```
lib/
├── core/
│   ├── database/
│   ├── theme/
│   └── constants/
├── data/
│   ├── repositories/
│   └── services/
├── domain/
│   └── models/
├── presentation/
│   ├── auth/
│   ├── dashboard/
│   ├── home/
│   ├── settings/
│   └── transaction/
└── routes/
```

## Getting Started

1. **Prerequisites**
   - Flutter SDK (>=3.0.0)
   - Dart SDK
   - Android Studio / VS Code
   - iOS Simulator / Android Emulator

2. **Installation**
   ```bash
   # Clone the repository
   git clone https://github.com/vinaysarupuru/flutter_expense_tracker_getx.git

   # Navigate to project directory
   cd expense_tracker

   # Install dependencies
   flutter pub get

   # Run the Flutter app
   flutter run
   ```

## Architecture

The app follows Clean Architecture principles with three main layers:

1. **Presentation Layer**
   - Views
   - Controllers (GetX)
   - Bindings

2. **Domain Layer**
   - Models
   - Repository Interfaces

3. **Data Layer**
   - Repositories
   - Local Data Sources
   - Services

## Key Features Implementation

### Transaction Management
- CRUD operations for transactions
- Real-time updates
- Category-based organization
- Tag system for detailed tracking

### Category System
- Dynamic category creation
- Subcategory support
- Category-based analytics
- Color coding for better visualization

### Dashboard
- Expense summaries
- Pie chart visualizations
- Monthly breakdowns
- Spending patterns

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flutter team for the amazing framework
- GetX team for the efficient state management solution
- The open-source community for various packages used

## Contact

Your Name - [@robotvinay](https://twitter.com/robotvinay)

Project Link: [https://github.com/vinaysarupuru/flutter_expense_tracker_getx](https://github.com/vinaysarupuru/flutter_expense_tracker_getx)

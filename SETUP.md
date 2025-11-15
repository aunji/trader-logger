# Zentry Trade Logger - Setup Guide

A Flutter trading journal application with Firebase backend and Cloudinary image storage.

## Features

- User authentication (Email/Password)
- Trade logging with multiple chart screenshots
- Trade analytics and reporting
- Session-based filtering (Asia, London, NY)
- Behavioral tags for trade analysis
- Post-mortem analysis for closed trades
- Win/Loss statistics and performance tracking

## Prerequisites

1. Flutter SDK (installed at `/home/aunji/flutter`)
2. Firebase project: `zentrydev-trader-logger`
3. Cloudinary account (cloud name: `dx5kqmj5y`)

## Firebase Setup

### 1. Enable Firebase Services

Go to [Firebase Console](https://console.firebase.google.com) and enable:

- **Authentication** → Email/Password provider
- **Firestore Database** → Create database in production mode
- **Security Rules** → Deploy the rules from `firestore.rules`

### 2. Deploy Firestore Security Rules

```bash
firebase deploy --only firestore:rules
```

Or manually copy the rules from `firestore.rules` to Firebase Console.

### 3. Configure Flutter with Firebase

The project already has `google-services.json` configured. If you need to reconfigure:

```bash
# Install flutterfire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

## Cloudinary Setup

### 1. Create Upload Preset

1. Go to [Cloudinary Console](https://cloudinary.com/console)
2. Navigate to Settings → Upload
3. Create an **unsigned** upload preset:
   - Name: `trade_logger_unsigned`
   - Signing Mode: Unsigned
   - Folder: `trade-logger/`
   - Resource type: Image only
   - Max file size: 1MB

### 2. Update Config (if needed)

The Cloudinary configuration is in `lib/core/constants/cloudinary_config.dart`:

```dart
static const String cloudName = 'dx5kqmj5y';
static const String uploadPreset = 'trade_logger_unsigned';
```

## Running the App

### 1. Add Flutter to PATH

```bash
export PATH="$PATH:/home/aunji/flutter/bin"
```

Or add it permanently to your `.bashrc` or `.zshrc`:

```bash
echo 'export PATH="$PATH:/home/aunji/flutter/bin"' >> ~/.bashrc
source ~/.bashrc
```

### 2. Get Dependencies

```bash
cd /home/aunji/zentry_trade_logger
flutter pub get
```

### 3. Run the App

```bash
# Check available devices
flutter devices

# Run on connected device
flutter run

# Run on web (if web support is enabled)
flutter run -d chrome

# Run on Android emulator
flutter run -d android
```

## Project Structure

```
lib/
├── core/
│   ├── routing/
│   │   ├── app_pages.dart       # GetX route definitions
│   │   └── app_routes.dart      # Route name constants
│   ├── theme/
│   ├── widgets/
│   └── constants/
│       └── cloudinary_config.dart
├── data/
│   ├── models/
│   │   ├── trade.dart           # Trade data model
│   │   └── trade_image.dart     # TradeImage data model
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   └── trade_repository.dart
│   └── services/
│       └── cloudinary_service.dart
└── modules/
    ├── auth/
    │   ├── controllers/
    │   │   └── auth_controller.dart
    │   ├── views/
    │   │   ├── login_page.dart
    │   │   └── register_page.dart
    │   └── bindings/
    │       └── auth_binding.dart
    └── trades/
        ├── controllers/
        │   ├── trade_list_controller.dart
        │   ├── trade_form_controller.dart
        │   ├── trade_detail_controller.dart
        │   └── trade_report_controller.dart
        ├── views/
        │   ├── trade_list_page.dart
        │   ├── trade_form_page.dart
        │   ├── trade_detail_page.dart
        │   └── trade_report_page.dart
        └── bindings/
            └── trade_binding.dart
```

## Data Models

### Trade

- `symbol`: Trading pair (e.g., XAUUSD)
- `direction`: BUY or SELL
- `entryPrice`: Entry price
- `tpPrice`: Take profit price
- `lot`: Position size
- `session`: Asia, London, NewYork, or Custom
- `result`: WIN, LOSS, or BE (Break Even)
- `profitUsd`: Profit/Loss in USD
- `reason`: Entry reason/strategy
- `postMortem`: Self-analysis after trade closes
- `tags`: Behavioral tags (e.g., "FOMO", "System A")

### TradeImage

- `imageUrl`: Cloudinary secure URL
- `publicId`: Cloudinary public ID (for deletion)
- `timeframe`: Optional chart timeframe
- `note`: Optional image note

## Firestore Structure

```
users/{userId}/
  └── trades/{tradeId}/
      ├── (trade document fields)
      └── images/{imageId}/
          └── (image document fields)
```

## Building for Production

### Android APK

```bash
flutter build apk --release
```

### Android App Bundle (for Play Store)

```bash
flutter build appbundle --release
```

### iOS (requires macOS)

```bash
flutter build ios --release
```

## Troubleshooting

### Firebase not initialized

Run `flutterfire configure` and update `lib/main.dart` to uncomment Firebase initialization code.

### Cloudinary upload fails

1. Verify the upload preset is set to "unsigned"
2. Check the cloud name in `cloudinary_config.dart`
3. Ensure the preset name matches exactly

### Build fails

```bash
# Clean the build
flutter clean

# Get dependencies
flutter pub get

# Rebuild
flutter run
```

## Next Steps

1. ✅ Complete Firebase setup
2. ✅ Configure Cloudinary unsigned upload preset
3. ⏳ Test the application end-to-end
4. 🔄 Deploy Firestore security rules
5. 📱 Build and test on physical device

## Support

For issues related to:
- Flutter: https://flutter.dev/docs
- Firebase: https://firebase.google.com/docs
- GetX: https://pub.dev/packages/get
- Cloudinary: https://cloudinary.com/documentation

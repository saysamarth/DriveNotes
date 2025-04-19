# DriveNotes

DriveNotes is a Flutter application that allows you to create, edit, and manage notes synchronized with Google Drive. Your notes are stored securely in your Google Drive account, making them accessible across devices.

## Features

- **Google Drive Integration**: Seamlessly sync notes to your Google Drive
- **Create and Edit Notes**: Simple interface for writing and editing notes
- **Theme Options**: Choose between light, dark, and system themes
- **Animated UI**: Smooth transitions and animations for better user experience
- **Secure Authentication**: Uses Google OAuth for secure access to your Drive

## Known Limitations

- Currently supports Android platform only
- No support for images or rich text formatting in notes
- Maximum note size is limited by Google Drive API constraints
- No offline functionality - active connection needed for all operations
  
## Getting Started

### Prerequisites

- Flutter SDK (2.10.0 or later)
- Android Studio or VS Code with Flutter extensions
- A Google Cloud Platform account

### Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/drivenotes.git
cd drivenotes
flutter pub get
```

2. Set up Google API credentials (See Below)

3. Run the app
```bash
flutter run
```

## Setting Up Google API Credentials

### Step 1: Create a Google Cloud Project
- Create a new project
- Enable the Google Drive API:

### Step 2: Configure OAuth Consent Screen
- Go to "APIs & Services" > "OAuth consent screen"
- Select "External" user type
- Add the required scopes:
  - `https://www.googleapis.com/auth/drive.file`
  - `https://www.googleapis.com/auth/drive.appdata`
- Add your email as a test user if using External user type
- Create OAuth credentials for Android
- Add your SHA-1 fingerprint and package name
  
### Step 3: Configure the App with Your Credentials
- Create a `secrets.properties` file in the project root:
  ```
  GOOGLE_CLIENT_ID=your-client-id-without-the-com.googleusercontent.apps-prefix
  ```
- Make sure your app's build.gradle is set up to read from this file

## Project Structure
```
lib/
├── controller/ - Contains providers and services
├── models/ - Data models for the application
├── view/ - UI components and screens
└── main.dart - Application entry point
```

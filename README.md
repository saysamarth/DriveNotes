# DriveNotes

DriveNotes is a Flutter application that allows you to create, edit, and manage notes synchronized with Google Drive. Your notes are stored securely in your Google Drive account, making them accessible across devices.

## Features

- **Google Drive Integration**: Seamlessly sync notes to your Google Drive
- **Create and Edit Notes**: Simple interface for writing and editing notes
- **Offline Support**: View and edit your notes even without an internet connection
- **Automatic Sync**: Changes are automatically synced when you're online
- **Secure Authentication**: Uses Google OAuth for secure access to your Drive

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
```

2. Install dependencies
```bash
flutter pub get
```

3. Set up Google API credentials (see below)

4. Run the app
```bash
flutter run
```

## Setting Up Google API Credentials

### Step 1: Create a Google Cloud Project
- Go to the Google Cloud Console
- Create a new project or select an existing one
- Enable the Google Drive API:
  - Navigate to "APIs & Services" > "Library"
  - Search for "Google Drive API" and enable it

### Step 2: Configure OAuth Consent Screen
- Go to "APIs & Services" > "OAuth consent screen"
- Select "External" user type (or "Internal" if using Google Workspace)
- Fill in the required application information
- Add the required scopes:
  - `https://www.googleapis.com/auth/drive.file`
  - `https://www.googleapis.com/auth/drive.appdata`
- Add your email as a test user if using External user type

### Step 3: Create OAuth Credentials
- Go to "APIs & Services" > "Credentials"
- Click "Create Credentials" > "OAuth client ID"
- Select "Android" as the application type
- Enter your app's package name (e.g., com.example.drivenotes)
- Generate an SHA-1 fingerprint using:
  ```bash
  keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
  ```
- Enter the SHA-1 fingerprint in the form
- Click "Create"

### Step 4: Configure the App with Your Credentials
- Create a `secrets.properties` file in the project root:
  ```
  GOOGLE_CLIENT_ID=your-client-id-without-the-com.googleusercontent.apps-prefix
  ```
  (Your client ID will look like `123456789-abcdefg.apps.googleusercontent.com`. Only include the `123456789-abcdefg` part)
- Make sure your app's build.gradle is set up to read from this file (as explained in the project documentation)

## Project Structure

```
lib/
├── controller/ - Contains providers and services
├── models/ - Data models for the application
├── view/ - UI components and screens
└── main.dart - Application entry point
```

## Known Limitations

- Currently supports Android platform only
- No support for images or rich text formatting in notes
- Maximum note size is limited by Google Drive API constraints
- Requires internet connection for initial login and synchronization

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

# CartFinder App Setup Guide

## 🔐 API Keys Configuration

This app requires API keys for Google Maps and Firebase. For security, these keys are not committed to git.

### 📋 Required API Keys

1. **Google Maps API Key** - For map functionality
2. **Firebase API Key** - For authentication and database

### 🚀 Setup Instructions

#### 1. Create Environment Files

Copy the template files and add your API keys:

```bash
# Copy environment templates
cp src/environments/environment.template.ts src/environments/environment.ts
cp src/environments/environment.prod.template.ts src/environments/environment.prod.ts
cp src/index.template.html src/index.html
cp android/app/src/main/AndroidManifest.template.xml android/app/src/main/AndroidManifest.xml
```

#### 2. Configure API Keys

**Google Maps API Key:**
- Go to [Google Cloud Console](https://console.cloud.google.com/)
- Create a new project or select existing
- Enable Maps JavaScript API
- Create credentials (API Key)
- Replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` in:
  - `src/environments/environment.ts`
  - `src/environments/environment.prod.ts`
  - `src/index.html`
  - `android/app/src/main/AndroidManifest.xml`

**Firebase API Key:**
- Go to [Firebase Console](https://console.firebase.google.com/)
- Create a new project or select existing
- Add a web app to your project
- Copy the config object
- Replace the firebase config in:
  - `src/environments/environment.ts`
  - `src/environments/environment.prod.ts`

#### 3. Example Configuration

```typescript
// src/environments/environment.ts
export const environment = {
  production: false,
  googleMapsApiKey: 'AIzaSyYourGoogleMapsApiKeyHere',
  firebase: {
    apiKey: "AIzaSyYourFirebaseApiKeyHere",
    authDomain: "your-project.firebaseapp.com",
    projectId: "your-project-id",
    storageBucket: "your-project.appspot.com",
    messagingSenderId: "123456789",
    appId: "1:123456789:web:abcdef123456"
  }
};
```

### 🔒 Security Notes

- ✅ API keys are in `.gitignore`
- ✅ Template files show placeholder values
- ✅ Real keys are only in local files
- ✅ Never commit actual API keys to git

### 🛠️ Development

After setting up API keys:

```bash
# Install dependencies
npm install

# Run development server
ionic serve

# Build for Android
ionic capacitor build android
```

### 📱 Testing

- Test on browser: `ionic serve`
- Test on Android: `ionic capacitor run android`
- Test on iOS: `ionic capacitor run ios`

### 🚨 Troubleshooting

**Map not loading:**
- Check Google Maps API key
- Verify API key has Maps JavaScript API enabled
- Check browser console for errors

**Firebase errors:**
- Verify Firebase config
- Check Firebase project settings
- Ensure Authentication is enabled in Firebase Console

**Build errors:**
- Run `npm install` to ensure dependencies
- Clear cache: `ionic capacitor sync`
- Check API key in AndroidManifest.xml 
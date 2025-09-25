# Email Setup Guide for Error Reporting

## Current Issue

You're getting this error:

```
Authentication Failed (code: 535), response:
< 5.7.8 Username and Password not accepted. For more information, go to
< 5.7.8  https://support.google.com/mail/?p=BadCredentials
```

This means your Gmail credentials are not properly configured.

## Solution: Gmail App Password Setup

### Step 1: Enable 2-Factor Authentication

1. Go to [Google Account Security](https://myaccount.google.com/security)
2. Click on "2-Step Verification"
3. Follow the setup process to enable 2FA

### Step 2: Generate App Password

1. Go back to [Google Account Security](https://myaccount.google.com/security)
2. Click on "App passwords" (you'll only see this if 2FA is enabled)
3. Select "Mail" as the app
4. Click "Generate"
5. Copy the 16-character password (it looks like: `abcd efgh ijkl mnop`)

### Step 3: Update Configuration

Open `lib/core/constant/const_data.dart` and update:

```dart
class EmailConfig {
  static const String senderEmail = 'your-actual-gmail@gmail.com'; // Your Gmail
  static const String senderPassword = 'abcdefghijklmnop'; // 16-char App Password
  // ... rest stays the same
}
```

### Step 4: Test

Run your app and trigger an error. You should see:

```
✅ Error email sent successfully
```

## Alternative: Use Different Email Provider

If you prefer not to use Gmail, you can use:

### Outlook/Hotmail

```dart
class EmailConfig {
  static const String smtpHost = 'smtp-mail.outlook.com';
  static const int smtpPort = 587;
  static const String senderEmail = 'your-email@outlook.com';
  static const String senderPassword = 'your-outlook-password';
  // ... rest stays the same
}
```

### Yahoo

```dart
class EmailConfig {
  static const String smtpHost = 'smtp.mail.yahoo.com';
  static const int smtpPort = 587;
  static const String senderEmail = 'your-email@yahoo.com';
  static const String senderPassword = 'your-yahoo-app-password';
  // ... rest stays the same
}
```

## Important Notes

- **Never use your regular Gmail password** - always use App Passwords
- **App Passwords are 16 characters** without spaces
- **2-Factor Authentication must be enabled** to generate App Passwords
- **Test with a simple error** first to verify the setup works

## Troubleshooting

If you still get authentication errors:

1. Double-check the email address (must be exact)
2. Double-check the App Password (16 characters, no spaces)
3. Make sure 2FA is enabled
4. Try generating a new App Password
5. Check if Gmail is blocking the login attempt (check Gmail security settings)

🧠 Thambi AI – Desktop AI Assistant (Windows)

**Thambi AI** is a Windows desktop AI assistant that combines **Google Gemini AI** with local system automation.  
Built with **Flutter (Windows desktop)** and **Python (Flask)**, it enables users to chat with AI, control apps, search files, send emails, and automate daily tasks — all from a single interface.

## ✨ Features

*   💬 AI Chat powered by Google Gemini
    
*   🎤 Voice Commands (Speech-to-Text & Text-to-Speech)
    
*   📧 Email Automation
    
*   📂 Instant File & Folder Search
    
*   🌐 Open Apps & Websites
    
*   🛒 Task Automation Workflows
    
*   🔒 Local-only Data Storage
    

## 📌 To make like this in your PC follow the steps

## 🧩 Prerequisites

👉 Ask Chat GPT if you face any errors or Doubts

### 🐍 Python

*   Python **3.10 or above**  
    _(For better experience install 3.10 only)_
    

**Download:**  
👉 [https://www.python.org/downloads/](https://www.python.org/downloads/)

✅ Enable **“Add Python to PATH”**

* * *

## 🔑 Required Keys

### Google Gemini API Key

👉 [https://aistudio.google.com/](https://aistudio.google.com/)

### Google App Password (for email feature)

👉 [https://myaccount.google.com/apppasswords](https://myaccount.google.com/apppasswords)

## 🖥 Flutter Windows Setup

### Step 1: Install Flutter SDK

Download **Flutter Stable**:  
👉 [https://docs.flutter.dev/get-started/install/archive](https://docs.flutter.dev/get-started/install/archive)

Extract to:

    C:\flutter
    

Add to PATH:

    C:\flutter\bin
    

Verify:

    flutter --version
    

### Step 2: Enable Windows Desktop Support

    flutter config --enable-windows-desktop
    

### Step 3: Install Visual Studio (Build Tools)

Flutter Windows builds require **Visual Studio Build Tools**, not Android Studio.

Download **Visual Studio 2022 Community**:  
👉 [https://aka.ms/vs/16/release/vs_community.exe](https://aka.ms/vs/16/release/vs_community.exe)

During installation, select:

*   ✔ Desktop development with C++
    
*   ✔ MSVC v143
    
*   ✔ Windows 10 SDK
    

Click **Install** (this may take some time)

* * *

## 🧪 Verify Installation

Run:

    flutter doctor
    

Make sure in terminal you see:

*   ✔ Flutter
    
*   ✔ Windows desktop
    
*   ✔ Visual Studio build tools
    

## 🧑‍💻 VS Code Setup (Recommended)

In **VS Code → Extensions**, install:

*   Flutter
    
*   Dart
    
*   Python
    

## 📥 Step 3: To Download the App

1.  Download the **project ZIP file**
    
2.  Extract it in **C drive**
    
3.  You should see the folder name as:
    

    ThambiAI-main (If you not see like this change the folder name as given "

## ⚙️ Backend Setup (Python)

### Step 1: Open Backend Folder

    cd backend
    

### Step 2: Install Dependencies

    pip install -r requirements.txt
    

### Step 3: Configure Environment Variables

Copy:

    .env.example
    

Rename to:

    .env
    

Fill in:

    GEMINI_API_KEY="your_gemini_api_key_here"
    EMAIL_ADDRESS="your_email@gmail.com"
    EMAIL_PASSWORD="your_google_app_password"
    

## ⚙️ Frontend Setup (Flutter)

### Step 1: Create New Flutter Project

Create a new Flutter project using VS Code or terminal.

### Step 2: Copy Dart Code

*   Copy **`main.dart`** from `frontend/lib/`
    
*   Replace your Flutter project’s `lib/main.dart` with **my main.dart**
    

* * *

### Step 3: Replace pubspec.yaml

*   Replace your project’s `pubspec.yaml` with **my pubspec.yaml**
    
*   Also copy **assets** from my folder to your Flutter project folder  
    _(For app logos)_
    

## ▶️ To Run the App

Run this in your Flutter project folder:

    flutter run -d windows
    

## 📦 Step 8: Build Windows App (Release Mode)

To build a Windows executable:

    flutter build windows
    

Output folder:

    build/windows/runner/Release/
    

## 📄 Step 9: Create MSIX Installer (Downloadable App)

### 1️⃣ Install MSIX Tool

    flutter pub add msix
    

### 2️⃣ Configure msix\_config in pubspec.yaml

Example:

    msix_config:
      display_name: Thambi AI
      publisher_display_name: Your Name
      identity_name: com.yourname.thambi_ai
      msix_version: 1.0.0.0
      logo_path: assets/logo.png
      capabilities: internetClient
    

* * *

## 🔐 Step 10: Create a Certificate (Required)

Windows requires a certificate to install MSIX apps.

Create Certificate (**PowerShell as Admin**):

    New-SelfSignedCertificate `
      -Type Custom `
      -Subject "CN=ThambiAI" `
      -KeyUsage DigitalSignature `
      -FriendlyName "Thambi AI Certificate" `
      -CertStoreLocation "Cert:\CurrentUser\My"
    

Export it and install it in **Trusted Root Certification Authorities**.

## 📦 Step 11: Build MSIX Installer

    flutter pub run msix:create
    

Output file:

    build/windows/runner/Release/thambi_ai.msix
    

👉 This is the **downloadable installer**

## ✅ Step 12: Install the App

*   Double-click `.msix`
    
*   Click **Install**
    

App appears in:

*   Start Menu
    
*   Installed Apps
    

✅ **Backend starts automatically when app launches**

## 🧠 Tech Stack

*   **Frontend:** Flutter (Windows Desktop)
    
*   **Backend:** Python (Flask)
    
*   **AI Engine:** Google Gemini
    
*   **Voice:** SpeechRecognition, Pyttsx3
    
*   **IDE:** VS Code
    
*   **Platform:** Windows


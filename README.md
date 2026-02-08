🧠 Thambi AI – Desktop AI Assistant (Windows)

**Thambi AI** is a Windows desktop AI assistant that combines **Google Gemini AI** with local system automation.  
Built using **Flutter (Windows Desktop)** and **Python (Flask)**, it allows users to interact with AI, control system applications, search files, send emails, and automate daily tasks — all from a single desktop interface.

* * *

## ✨ Features

*   💬 AI chat powered by **Google Gemini**
    
*   🎤 Voice commands (Speech-to-Text & Text-to-Speech)
    
*   📧 Email automation
    
*   📂 Instant file and folder search
    
*   🌐 Open applications and websites
    
*   🛒 Task automation workflows
    
*   🔒 Local-only data processing (no cloud storage)
    

* * *

## 📌 How to Set Up Thambi AI on Your PC

> 👉 If you face any errors or doubts during setup, feel free to ask ChatGPT.

* * *

## 🧩 Prerequisites

### 🐍 Python

*   Python **3.10 or above**  
    _(Recommended: Python 3.10 for best compatibility)_
    

**Download Python:**  
👉 [https://www.python.org/downloads/](https://www.python.org/downloads/)

✅ While installing, **enable “Add Python to PATH”**

* * *

## 🔑 Required Keys

### 🔹 Google Gemini API Key

👉 [https://aistudio.google.com/](https://aistudio.google.com/)

### 🔹 Google App Password (for Email Feature)

👉 [https://myaccount.google.com/apppasswords](https://myaccount.google.com/apppasswords)

* * *

## 📂 Project Setup

### Step 1: Download Project

1.  Download the **project ZIP file**
    
2.  Extract it inside **C Drive**
    
3.  Ensure the folder name is exactly:
    

    ThambiAI-main
    

(If the name is different, rename it to **ThambiAI-main**)

* * *

## ⚙️ Backend Setup (Python)

### Step 2: Open Backend Folder

    cd backend
    

### Step 3: Install Dependencies

    pip install -r requirements.txt
    

### Step 4: Configure Environment Variables

1.  Copy the file:
    

    .env.example
    

2.  Rename it to:
    

    .env
    

3.  Fill in the required values:
    

    GEMINI_API_KEY="your_gemini_api_key_here"
    EMAIL_ADDRESS="your_email @ gmail.com"
    EMAIL_PASSWORD="your_google_app_password"
    

* * *

## 🚀 Running the Application

### Step 5: Run the Desktop App

1.  Click the provided **EXE file**
    👉 [Download Thambi AI for Windows](https://github.com/BhumulaLakshmiNarayanaReddy/ThambiAI/releases/download/v1.0.0/thambi_ai.exe)
2.  Double-click the EXE to launch the app
    
    *   The backend starts automatically when the app launches
        
3.  (Optional) **Pin the app to the taskbar** for quick access
    

* * *

## 🧠 Tech Stack

*   **Frontend:** Flutter (Windows Desktop)
    
*   **Backend:** Python (Flask)
    
*   **AI Engine:** Google Gemini
    
*   **Voice:** SpeechRecognition, pyttsx3
    
*   **IDE:** Visual Studio Code
    
*   **Platform:** Windows
    

##

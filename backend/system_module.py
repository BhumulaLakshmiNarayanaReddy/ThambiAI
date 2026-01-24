# system_module.py

import os
import subprocess


def open_app(app_name):
    app_name = app_name.lower()

    # Map common names to their executable paths or system commands
    apps = {
        "settings": "start ms-settings:",
        "vs code": "code",
        "visual studio code": "code",
        "notepad": "notepad",
        "calculator": "calc",
        "chrome": "start chrome",
        "file explorer": "explorer",
        "task manager": "taskmgr"
    }

    try:
        if app_name in apps:
            # use shell=True for system commands like 'start'
            subprocess.Popen(apps[app_name], shell=True)
            return f"✅ Opening {app_name} for you."
        else:
            # Fallback: try to run the command directly as a system call
            subprocess.Popen(app_name, shell=True)
            return f"🚀 Attempting to launch {app_name}..."
    except Exception as e:
        return f"❌ Sorry, I couldn't open {app_name}. Error: {str(e)}"
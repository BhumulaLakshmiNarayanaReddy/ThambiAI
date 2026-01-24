import os
import time
import pyautogui
import pygetwindow as gw


def open_whatsapp():
    """Ensure WhatsApp is open and focused."""
    os.system("start whatsapp://")
    time.sleep(3)  # Wait for app to load
    try:
        window = gw.getWindowsWithTitle('WhatsApp')[0]
        window.activate()
        if not window.isMaximized:
            window.maximize()
    except:
        pass


def search_contact(contact_name):
    """Search for a contact name."""
    open_whatsapp()
    pyautogui.hotkey('ctrl', 'f')
    time.sleep(0.5)
    pyautogui.write(contact_name)
    time.sleep(1.5)
    pyautogui.press('enter')
    time.sleep(1)


def send_whatsapp_message(contact_name, message):
    """Search and send a text message."""
    search_contact(contact_name)
    pyautogui.write(message)
    pyautogui.press('enter')
    return f"✅ Message sent to {contact_name}"


def start_whatsapp_call(contact_name, is_video=False):
    """Search and start a call using image recognition."""
    search_contact(contact_name)

    icon = "assets/video_call.png" if is_video else "assets/voice_call.png"
    try:
        # Locate the button on screen
        location = pyautogui.locateOnScreen(icon, confidence=0.8)
        if location:
            pyautogui.click(pyautogui.center(location))
            return f"📞 Calling {contact_name}..."
        else:
            return "❌ Could not find the call button. Is the chat open?"
    except Exception as e:
        return f"Error: {e}. Make sure {icon} exists."
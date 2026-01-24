import os
import json
import re
from datetime import datetime
from flask import Flask, request, jsonify
from flask_cors import CORS
from main import get_thambi_response
from urllib.parse import unquote

app = Flask(__name__)
CORS(app)


BASE_DIR = os.path.dirname(os.path.abspath(__file__))
HISTORY_FOLDER = os.path.join(BASE_DIR, "history")
os.makedirs(HISTORY_FOLDER, exist_ok=True)


# Global variable to track the active session file
current_session_file = None


def sanitize_filename(text):
    """Clean the first message to create a safe Windows filename."""
    # Remove special characters and limit length
    clean = re.sub(r'[^\w\s-]', '', text)
    return clean.strip()[:40]


def save_message_to_json(sender, text):
    """Handles creating or appending to the session-specific JSON file."""
    global current_session_file

    # 1. Capture the FIRST question to name the file
    if current_session_file is None:
        name_part = sanitize_filename(text) or "Untitled_Chat"
        timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
        # Example: "How_to_cook_pasta_2026-01-14_14-30-00.json"
        current_session_file = os.path.join(HISTORY_FOLDER, f"{name_part}_{timestamp}.json")

    # 2. Prepare the message entry
    new_entry = {
        "sender": sender,
        "text": text,
        "timestamp": datetime.now().strftime("%I:%M %p")
    }

    # 3. Load existing messages and append
    messages = []
    if os.path.exists(current_session_file):
        with open(current_session_file, "r", encoding="utf-8") as f:
            try:
                messages = json.load(f)
            except json.JSONDecodeError:
                messages = []

    messages.append(new_entry)

    # 4. Save back to the file
    with open(current_session_file, "w", encoding="utf-8") as f:
        json.dump(messages, f, indent=4)


@app.route('/auto', methods=['POST'])
def auto_route():
    """Main chat route used by Flutter."""
    data = request.json
    user_msg = data.get("message", "")

    # Save the User's question (creates file if it's the first message)
    save_message_to_json("user", user_msg)

    # Get the AI response from your main logic
    reply = get_thambi_response(user_msg)

    # Save Thambi's reply to the SAME file
    save_message_to_json("thambi", reply)

    return jsonify({"reply": reply})


@app.route('/new_chat', methods=['POST'])
def start_new_chat():
    """Triggered when the user clicks 'New Chat' in Flutter."""
    global current_session_file
    current_session_file = None  # Forces the next message to create a new file
    return jsonify({"status": "success", "message": "New session started"})


@app.route('/history', methods=['GET'])
def get_sessions():
    """Returns a list of all JSON files in the history folder."""
    files = [f for f in os.listdir(HISTORY_FOLDER) if f.endswith('.json')]
    # Sort by date (newest first)
    files.sort(key=lambda x: os.path.getmtime(os.path.join(HISTORY_FOLDER, x)), reverse=True)
    return jsonify(files)


@app.route('/history/<filename>', methods=['GET'])
def get_session_details(filename):
    """Returns the full conversation inside a specific JSON file."""
    file_path = os.path.join(HISTORY_FOLDER, filename)
    if os.path.exists(file_path):
        with open(file_path, "r", encoding="utf-8") as f:
            return jsonify(json.load(f))
    return jsonify({"error": "File not found"}), 404  

@app.route('/delete_history/<filename>', methods=['DELETE'])
def delete_history(filename):
    """Deletes a specific session file from the history folder."""
    # 1. Decode the filename (converts %20 back to spaces)
    clean_filename = unquote(filename)
    
    # 2. Use your defined HISTORY_FOLDER variable, NOT the string 'history_folder'
    file_path = os.path.join(HISTORY_FOLDER, clean_filename)
    
    print(f"Attempting to delete: {file_path}") # Debugging log

    try:
        if os.path.exists(file_path):
            os.remove(file_path)
            return jsonify({"status": "success"}), 200
        else:
            print("File not found on server.")
            return jsonify({"status": "error", "message": "File not found"}), 404
    except Exception as e:
        print(f"Delete error: {str(e)}")
        return jsonify({"status": "error", "message": str(e)}), 500

@app.route('/health', methods=['GET'])
def health():
    return jsonify({"status": "ok"}), 200


if __name__ == "__main__":
    app.run(
        host="127.0.0.1",
        port=5000,
        debug=False,
        use_reloader=False
    )

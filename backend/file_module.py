# file_module.py
import os
import glob


def search_files(filename):
    # Get the current user's home directory (e.g., C:\Users\YourName)
    user_path = os.path.expanduser("~")

    # Define folders to search in for better performance (searching the whole C: drive is too slow)
    search_locations = [
        os.path.join(user_path, "Documents"),
        os.path.join(user_path, "Downloads"),
        os.path.join(user_path, "Desktop")
    ]

    found_files = []

    try:
        for folder in search_locations:
            # Recursive search for the filename with any extension
            # Example: searching for "resume" will find "resume.pdf", "resume.docx", etc.
            pattern = os.path.join(folder, "**", f"*{filename}*")
            matches = glob.glob(pattern, recursive=True)
            found_files.extend(matches)

        if not found_files:
            return f"📂 I couldn't find any files matching '{filename}' in your common folders."

        # Format the first 3 results to keep it clean
        result_text = f"📂 I found {len(found_files)} matches. Here are the top ones:\n"
        for file in found_files[:3]:
            result_text += f"- {os.path.basename(file)} (In {os.path.dirname(file)})\n"

        # Automatically open the first folder found
        os.startfile(os.path.dirname(found_files[0]))
        return result_text + "\n📂 Opening the folder for the best match..."

    except Exception as e:
        return f"❌ Error searching for files: {str(e)}"
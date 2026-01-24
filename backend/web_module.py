# web_module.py

import webbrowser
import urllib.parse

def search_youtube(query):
    try:
        # Encode the query for a URL (e.g., spaces become %20)
        encoded_query = urllib.parse.quote(query)
        url = f"https://www.youtube.com/results?search_query={encoded_query}"
        webbrowser.open(url)
        return f"📺 Searching YouTube for '{query}'..."
    except Exception as e:
        return f"❌ Failed to search YouTube: {str(e)}"

def open_website(url):
    try:
        if not url.startswith(("http://", "https://")):
            url = "https://" + url
        webbrowser.open(url)
        return f"🌐 Opening {url}..."
    except Exception as e:
        return f"❌ Failed to open website: {str(e)}"
from assistant_utils import send_email, get_code
from shopping_module import add_to_cart
from whatsapp_module import send_whatsapp_message, start_whatsapp_call
from system_module import open_app
from web_module import search_youtube, open_website
from file_module import search_files

# State managed globally for the local server
conversation_state = {"mode": None, "data": {}}


def get_thambi_response(command):
    global conversation_state
    cmd = command.lower().strip()

    # --- 1. HANDLE ACTIVE MODES FIRST ---

    # Mode: Shopping (Handles the ITEM name)
    if conversation_state['mode'] == 'shopping':
        item = command
        # Reset mode immediately so the next message is a fresh command
        conversation_state = {"mode": None, "data": {}}
        # IMPORTANT: Return the result from the shopping module
        return add_to_cart(item)

    # Mode: Email
    if conversation_state['mode'] == 'email':
        if 'email_to' not in conversation_state['data']:
            conversation_state['data']['email_to'] = command
            return "📬 What is the subject?"
        elif 'subject' not in conversation_state['data']:
            conversation_state['data']['subject'] = command
            return "💬 What is the message?"
        else:
            send_email(conversation_state['data']['email_to'], conversation_state['data']['subject'], command)
            conversation_state = {"mode": None, "data": {}}
            return "✅ Email sent successfully!"

    # Mode: Code/Doubt
    if conversation_state['mode'] == 'code_doubt':
        res = get_code(command)
        conversation_state = {"mode": None, "data": {}}
        return res

    # Mode: WhatsApp Messaging
    if conversation_state['mode'] == 'whatsapp_msg':
        if 'contact' not in conversation_state['data']:
            conversation_state['data']['contact'] = command
            return "💬 What is the message?"
        else:
            contact = conversation_state['data']['contact']
            res = send_whatsapp_message(contact, command)
            conversation_state = {"mode": None, "data": {}}
            return res

    # Mode: WhatsApp Calling
    if conversation_state['mode'] == 'whatsapp_call':
        name = command
        is_video = conversation_state['data'].get('is_video', False)

        conversation_state = {"mode": None, "data": {}}
        return start_whatsapp_call(name, is_video=is_video)

    # --- 2. HANDLE NEW TRIGGER PHRASES ---

    # Trigger: Shopping
    if any(x in cmd for x in ['shop', 'buy', 'add to cart']):
        # Attempt to extract item if user said "buy laptop"
        item_search = cmd.replace('buy', '').replace('shop', '').replace('add to cart', '').strip()
        if item_search:
            return add_to_cart(item_search)

        # Otherwise, enter shopping mode to wait for the next message
        conversation_state = {"mode": "shopping", "data": {}}
        return "🛒 What do you want to buy? (I will search Amazon for you)"

    # Trigger: Email
    if any(x in cmd for x in ['mail', 'email']):
        conversation_state = {"mode": "email", "data": {}}
        return "👤 To whom should I send the email?"


    # Trigger: Doubt
    if any(x in cmd for x in ['doubt', 'help', 'question']):
        conversation_state = {"mode": "code_doubt", "data": {}}
        return "🤔 What is your question?"

    # Trigger: Greetings
    if any(x in cmd for x in ['hi', 'hello', 'hey']):
        return "Hello! I'm Thambi AI. How can I help you today?"

    if any(x in cmd for x in ['open app', 'launch', 'open settings', 'open vscode']):
        # Clean the command to get just the app name
        app_to_open = cmd.replace('open app', '').replace('launch', '').replace('open', '').strip()
        if not app_to_open:
            return "🖥️ Which app would you like me to open?"
        return open_app(app_to_open)

    # Trigger: YouTube Search
    if 'youtube' in cmd:
        # Get everything after "youtube" as the search term
        video_query = cmd.split('youtube')[-1].replace('search', '').replace('for', '').strip()
        if not video_query:
                return "📺 What would you like to watch on YouTube?"
        return search_youtube(video_query)

    # Trigger: Open Website
    if any(x in cmd for x in ['website', 'browse', 'go to']):
        site = cmd.replace('open website', '').replace('browse', '').replace('go to', '').strip()
        if not site:
                return "🌐 Which website should I open?"
        return open_website(site)

    # Trigger: Local File Search
    if any(x in cmd for x in ['search file', 'find file', 'look for']):
        file_query = (
            cmd.replace('search file', '')
               .replace('find file', '')
               .replace('look for', '')
               .replace('for', '')
               .strip()
        )
        if not file_query:
            return "📂 What is the name of the file?"
        return search_files(file_query)

    # Trigger: WhatsApp Call (MUST BE FIRST)
    if cmd.startswith("call") or cmd.startswith("video call"):
        is_video = "video" in cmd
        name = cmd.replace("video", "").replace("call", "").replace("to", "").replace("whatsapp", "").strip()

        if name:
            return start_whatsapp_call(name, is_video=is_video)

        conversation_state = {"mode": "whatsapp_call", "data": {"is_video": is_video}}
        return "👤 Who should I call?"

    # Trigger: WhatsApp Message
    if ("message" in cmd or "whatsapp" in cmd) and "call" not in cmd:
        name = cmd.replace("message", "").replace("whatsapp", "").replace("to", "").strip()

        if name:
            conversation_state = {"mode": "whatsapp_msg", "data": {"contact": name}}
            return f"💬 What message should I send to {name}?"

        conversation_state = {"mode": "whatsapp_msg", "data": {}}
        return "👤 Who do you want to message?"

    # --- 3. FALLBACK ---
    return "I'm not sure how to help with that. Try asking to 'send an email', 'shop', or 'solve a doubt'."
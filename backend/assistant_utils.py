import google.generativeai as genai
import config
import smtplib
from email.message import EmailMessage

# Configure Gemini API
genai.configure(api_key=config.GEMINI_API_KEY)

# Create model instance
model = genai.GenerativeModel("gemini-flash-latest")

def send_email(to, subject, body):
    try:
        msg = EmailMessage()
        msg["Subject"] = subject
        msg["From"] = config.EMAIL_ADDRESS
        msg["To"] = to
        msg.set_content(body)

        with smtplib.SMTP_SSL("smtp.gmail.com", 465) as smtp:
            smtp.login(config.EMAIL_ADDRESS, config.EMAIL_PASSWORD)
            smtp.send_message(msg)

        return "Email sent successfully!"
    except Exception as e:
        print(f"❌ Email Error: {e}")
        return "Failed to send email."

def get_code(prompt):
    try:
        response = model.generate_content(prompt)
        return response.text
    except Exception as e:
        print(f"❌ Gemini Error: {e}")
        return "Sorry, I'm having trouble thinking right now."

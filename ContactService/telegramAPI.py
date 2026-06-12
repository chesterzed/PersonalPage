import os
import requests
from dotenv import load_dotenv
from pathlib import Path

# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent

# Load environment variables from .env
load_dotenv(BASE_DIR / '.env')

def send_telegram_message(name: str, email: str, message: str) -> bool:
    """
    Sends a formatted message to a Telegram chat.
    Returns True if successful, False otherwise.
    """
    bot_token = os.getenv('TELEGRAM_BOT_TOKEN')
    chat_id = os.getenv('TELEGRAM_CHAT_ID')

    if not bot_token or not chat_id:
        # In a real app, you might want to log this to a file
        print("Error: Telegram Bot Token or Chat ID not found in environment variables.")
        return False

    # Format the message as requested
    formatted_message = (
        f"<b>Имя:</b> {name}\n"
        f"<b>Почта:</b> {email}\n\n"
        f"{message}"
    )

    url = f"https://api.telegram.org/bot{bot_token}/sendMessage"
    payload = {
        "chat_id": chat_id,
        "text": formatted_message,
        "parse_mode": "HTML"
    }

    try:
        response = requests.post(url, json=payload, timeout=10)
        response.raise_for_status()
        return True
    except requests.exceptions.RequestException as e:
        print(f"Failed to send Telegram message: {e}")
        return False

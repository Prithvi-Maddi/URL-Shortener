import string, random
from .models import ShortURL

def generate_unique_short_code(length=6):
    chars = string.ascii_letters + string.digits  # a-z, A-Z, 0-9
    while True:
        code = ''.join(random.choices(chars, k=length))
        if not ShortURL.objects.filter(short_code=code).exists():
            return code

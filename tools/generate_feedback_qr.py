"""Regenerate the offline WoW texture and independently verify its payload.

Development dependencies: qrcode==8.2, Pillow, zxing-cpp==2.3.0.
No generator or decoder is shipped with the addon.
"""
from pathlib import Path
import re

from PIL import Image
import qrcode
import zxingcpp

ROOT = Path(__file__).resolve().parents[1]
url = re.search(r'local FEEDBACK_URL = "([^"]+)"',
                (ROOT / 'QuestTargets/UI.lua').read_text()).group(1)
qr = qrcode.QRCode(error_correction=qrcode.constants.ERROR_CORRECT_M, border=4)
qr.add_data(url)
qr.make(fit=True)
matrix = qr.get_matrix()
scale = 256 // len(matrix)
assert scale >= 4, 'URL requires a larger texture to remain readable'
image = Image.new('RGB', (256, 256), 'white')
offset = (256 - len(matrix) * scale) // 2
for y, row in enumerate(matrix):
    for x, dark in enumerate(row):
        if dark:
            image.paste((0, 0, 0), (offset + x * scale, offset + y * scale,
                                   offset + (x + 1) * scale, offset + (y + 1) * scale))
destination = ROOT / 'QuestTargets/Textures/FeedbackQR.tga'
image.save(destination, compression=None)
# Verify the actual saved texture, not just the matrix used by the encoder.
decoded = zxingcpp.read_barcode(Image.open(destination))
assert decoded is not None and decoded.text == url, 'Saved QR payload mismatch'
print(f'{destination.name}: verified {decoded.text}')

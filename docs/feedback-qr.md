# Feedback QR code

The existing copy-link popup includes a reusable inserted frame with a 256×256
black/white QR texture and a localized phone-scanning hint. The URL field and
Select link action retain their existing behavior. Both link and QR encode
`https://feedback.jacknine.org/`. The texture is bundled in the universal ZIP;
the addon makes no network request and has no runtime QR dependency.

Regenerate after changing FEEDBACK_URL in UI.lua:

```sh
python -m pip install qrcode==8.2 Pillow==11.3.0 zxing-cpp==2.3.0
python tools/generate_feedback_qr.py
```

The generator uses integer module sizes, a white quiet zone of at least four
modules, medium error correction and an uncompressed 24-bit power-of-two TGA.
It decodes the saved TGA with independent zxing-cpp before reporting success.
Neither dependency nor generator is included in the addon package.

XERJ lookup for `StaticPopup_Show insertedFrame` was unavailable (XERJ is not
installed). Fallback inspection used local rg and the Blizzard native UI sources:

- [StaticPopup.lua](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_StaticPopup/StaticPopup.lua):
  StaticPopup_Show accepts an inserted frame as its fifth argument; closing the
  dialog hides and releases it.
- [GameDialog.lua](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_StaticPopup_Game/GameDialog.lua):
  SetupInsertedFrame reparents/shows the frame and the popup layout anchors it.
- Equivalent inserted-frame support was checked in the local Classic Era source.

Automated tests cover insertion/reuse, localized hint refresh, retained URL copy
behavior and inclusion of the exact texture bytes in the universal package.
Client rendering and scanning a real display still require an in-game check.

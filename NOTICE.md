# Third-party assets and trademarks

This is an independent technical study. **It is not affiliated with, endorsed
by, or sponsored by Google LLC.**

## Google Sans Flex — SIL Open Font License 1.1

`fonts/GoogleSansFlex-subset.woff2` is a modified copy of Google Sans Flex:
every axis instanced to the font's default except weight, then subset to the
43 characters this piece renders. The same bytes are base64-embedded in
`index.html` so the page is self-contained.

    Copyright 2015 Google LLC. All Rights Reserved.
    This Font Software is licensed under the SIL Open Font License, Version 1.1.

The full licence is in `fonts/OFL.txt`. No Reserved Font Name is declared
after the copyright statement, so the modified font keeps its name. The font
is not sold, on its own or bundled. `tools/build-font.sh` regenerates the
subset from an installed copy of the original.

## Google name, logo and trade dress

The Google wordmark, the "G" mark and the AI Mode interface are trademarks of
Google LLC, reproduced here to study the motion of an existing piece of
design. Their inclusion is descriptive, not a claim of ownership and not an
implication of any relationship with Google.

The wordmark is drawn from Google Sans Flex's own logo glyphs, which the font
ships in its private-use range (`U+E000`–`E004`, `U+E006`).

## Source footage

The advertisement this reconstructs is Google's copyright. **It is not
included in this repository**, and neither is the side-by-side comparison
built from it — see `.gitignore`. `docs/recreation.mp4` shows only this
recreation's own output.

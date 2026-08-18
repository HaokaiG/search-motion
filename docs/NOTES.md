# Working notes

Enough to pick this up cold. The measurements themselves are in `../README.md`;
this is the how-to-work-on-it and what's-still-open.

## The verify loop

Nothing here is judged by eye. Every change goes through the same loop:

1. **Render stills** — headless Chrome against `index.html`, one frame per run:

   ```
   #bare        hides the controls
   #t=<seconds> freezes one instant   (frame n  ->  t = n/23.976)
   #q=<text>    an edited query
   #a=<text>    edited answer copy
   ```

2. **Measure** — compare against the source frame with numpy: run-detection on a
   threshold for geometry, saturation for the gradient effects, 1st-percentile
   luminance for opacity (position-independent), stem widths on the x-height for
   type weight.

3. **Score** — `score.py`: agreement on lit pixels only, after a small blur, so
   it reads layout rather than font hinting. White background excluded — it is
   trivial to match and would flatter the number.

4. **Rebuild** — `mkvid2.sh` stitches the side-by-side.

### Traps hit more than once

- **Chrome hangs on exit** with `--screenshot`. Launch it backgrounded, poll for
  the file, then `kill -9`. Waiting on the process blocks the whole batch.
- **Every parallel render needs its own `--user-data-dir`**, or instances fight
  over the profile lock and the batch stalls. These are pure throwaway and they
  are *enormous* — 28 of them reached 7.2GB. Delete them after every batch.
- **Frames fail silently.** One did, twice, and ffmpeg wrote a broken video
  around the gap. Always check for missing/zero-length files before stitching.
- **A metric that does not move is not proof.** The 4px text jump when typing
  ended never showed up in the score — one frame cannot shift a 132-frame mean.
  It took someone watching it.
- **Only `#stage` and the `<style>` tag are serialised, so a runtime override on `<html>` never
  reaches the export.** Setting `--bar-scrim` on the root changed the preview and left exported
  frames on the stylesheet's value — an A/B that read a ratio of exactly 1.000 and looked, for a
  moment, like the effect was missing entirely. Dial these constants in the stylesheet, or set
  them on an element inside `#stage`. Same family as the `body` font-family trap below.
- **A `<video>` cannot cross the export, and it does not fail quietly.** An `<img>`-loaded SVG
  will not decode media, but the element still *lays out* inside the foreignObject and paints an
  opaque placeholder — a flat `#333` over the whole frame, hiding the footage composited
  underneath. It has to be hidden for the length of the serialise.
- **Wait for decoded data, not the `seeked` event.** A cold first seek fires `seeked` while
  `readyState` is still 1, and drawing then paints nothing at all. Poll for `readyState >= 2`.
- **`render()` runs off rAF, so anything it touches is touched ~60x a second.** Syncing the
  video's `currentTime` from inside it re-issued the seek before it could ever land, and the
  element sat at `readyState` 1 forever. A frozen frame is not a still world.
- **Alpha cannot go through WebCodecs here, and the failure is a flat no.** Every VP8/VP9 config
  with `alpha: "keep"` comes back unsupported, so the H.264 path cannot carry a matte at all and
  nothing else in a browser will. The answer is `proresFrame` — ProRes 4444 written out by hand,
  which is what the notes below are about. It replaced a MediaRecorder VP9 WebM that worked but
  had to be *played* into the encoder at the real rate, because MediaRecorder timestamps by wall
  clock while a frame here takes far longer to render than it lasts; that cost about 2% of drift
  on the duration. The ProRes path has none, being deterministic end to end.
- **Write the decoder first.** A bit-exact encoder cannot be debugged by looking at it. What
  made ProRes tractable in an afternoon was going the other way: encode a known pattern with
  ffmpeg's own `prores_ks`, then write a parser in Python (`scratchpad/prores/pdec.py` while it
  lasted) until it reproduced ffmpeg's decode to the value. That pins every field, and the
  encoder is then written as the exact inverse of something proven rather than from memory. The
  DCs of a flat block came out at exactly `32V - 16384` over `qmat[0] * qscale`, which confirmed
  the transform's scale, the DC bias and the quantiser in one number.
- **The chroma blocks of a macroblock are ordered down-then-across; luma is across-then-down.**
  Four 8x8 blocks either way, and no reference file will show up the difference unless its chroma
  varies *inside* a macroblock — flat colour fields do not, and neither does a grey ramp, whose
  chroma is 512 everywhere. It survived the first three test images and then put a mean error of
  6.4 across a noisy one, luma pixel-exact beside it. If a codec is right on flat content and
  wrong on detail, suspect the block order before the transform.
- **ProRes's default quantisation matrices are all 4s**, which is what a matrix-flags byte of
  zero selects — so the whole quantiser is `4 * qscale` and qscale 1 is "round each coefficient
  to the nearest integer". ffmpeg writes its own 128-byte matrices instead; there is no need to.
- **The forward transform's 4x scale is not a choice.** The decoder's inverse divides by it, so a
  flat block of value V has to arrive as DC = 32V or everything is wrong by a constant factor.
- **A slice narrows at the right edge by halving, and never widens back.** 8, then 4, 2, 1 as the
  row runs out — 30 macroblocks come out as 8+8+8+4+2. The decoder halves by the same rule and
  the two are never told about each other, so an encoder that resets to 8 mid-row desynchronises
  every slice after it.
- **A newline in the query is two different strings.** `QUERY` keeps it, because the act-2 bubble
  draws a row there; `QUERY_BAR` swaps it for a space, because act 1 is one pill and `pre` on the
  bar would break the text onto a second line and take `offsetWidth` — and so the bar's width,
  the chip's position and the pan — off the longer half. Substituting a **space rather than
  nothing** is the whole trick: every index in the piece is a position in this string (the typing
  schedule, the caret's frame table, the camera's progress), so the length has to survive. Verified
  by breaking the reference query in two and checking the bar stayed on 2491px and the pan on 1583.
- **Walking a string for its line breaks must not walk its newlines.** `fieldLines` groups
  characters by which line box they landed on, and a literal `\n` lands in a group of its own —
  which put an empty row in the bubble between every hard break. Split on the newlines first and
  find the soft wraps inside each piece. Worth checking on the mirror element too: it lives on
  `<body>`, deliberately outside `#stage`, so it cannot reach the export the way anything inside
  the stage would — confirmed by grepping the serialised SVG for its own off-screen offset.
- **A still plate has to be hidden from the serialiser too, for a different reason.** The video is
  hidden because an `<img>`-loaded SVG will not decode media and paints an opaque placeholder over
  the footage composited underneath. An `<img>` will not fetch a `blob:` URL in that context
  either, so it goes out the same way, and both are restored afterwards. Worth checking by reading
  the tag out of the serialised string rather than grepping it for `display:block`: the stylesheet
  travels with it, so `#stage.has-bg.bg-still #bgimg{display:block}` matches a naive regex and
  reads as a failure when the element itself is correctly `display: none`.
- **The GIF export is a different document.** It serialises `#stage` into a
  foreignObject inside a plain `<div>`, so any rule hung on `body` — or on
  anything outside `#stage` — silently does not apply. `font-family` lived on
  `body`, so every exported frame fell through the stack to `sans-serif` and
  set the query ~5% wide while the preview was perfect. Keep what the stage
  needs on `#stage` or below. Worth checking against the live DOM rather than
  by eye: rasterise a frame and compare an ink extent.

## Open decisions

Departures from the plate that were deliberate, and the one-line way back:

| | |
|---|---|
| `LOGO_NUDGE = 0` | The plate has the wordmark **12px left** of the bar's centre. Centring it exactly cost ~0.10 of act-1 agreement. `-12` restores the plate's position and keeps the centring behaviour. |
| Sidebar icons at `--side-icon: 0.975` | 1px under the measured size, by request. |
| Edit icon at `top: 425.5` | ~4px **below** the plate. Its ink is at y402-441 and its square body at 406-441; this is a design call, not a match. |
| Bubble corner `10px` | Specified. The plate's own corner reads closer to **5-6px**. |
| Active nav ink `#1f1f1f` | The plate reads `rgb(0,0,0)`. Would darken the AI Mode label and its caret together. |
| The outline's spin eases, and runs slow | The plate turns it at a flat 771 units/frame. It now enters fast and leaves 30% slower (`RING_EASE`), and the whole thing runs 15% under the measured rate (`RING_SLOW`). Frame 120 — the frame the hues were solved from — stays the anchor either way. The two constants happen to cancel in `RING_V0` (both 0.85), so the start rate lands back on 771 by coincidence; the mean is 655. Back: set both to 0. |
| The outline is cut by the press, over a second | The measured envelope runs the outline up to the press and is then **held**, and `RING_PRESS_FADE` takes it from that 0.204 to 0 over a full second. The plate has it gone by 128; this carries it to 151. It cannot finish: act 1 is gone by 136, about 9 frames in, so roughly a third of the second plays and the cut takes the rest. Back: `RING_PRESS_FADE = 2` and drop the `Math.min(f, PRESS_F0)` hold. |
| Outline glow +2px | `RING_GLOW_GROW`. The plate's glow reads ~12px across at its peak; the bloom's width and its blur are scaled together by 14/12 so the falloff keeps its shape rather than just growing a fatter core. Back: set it to 0. |
| `CHIP_GAP_BG = 140` | Over footage only, against the measured 111. The bar is a scrim there and the chip only 75% opaque, so the two crowd each other at the plate's spacing. **By eye — no measurement behind it**; opened to 200, then pulled 30% back. It pushes the chip right, so the bar and pan grow with it, and the Medium query adds to that too: together they take the bar 2491 → 2577. The white card keeps the measured 111. Back: set it to 111. |
| The camera is a bezier on the typing's progress | **The baked `PAN` curve no longer drives the camera at all.** The pan is a function of how far through the query the typing has got, not of the clock, so it re-times with the rate and lands exactly as the last character does. `CAM_BEZ` is the easing — the same four handles After Effects and CSS use, editable in the panel with a live curve, carried as `#bez=`; `CAM_SPEED` scales the progress so a faster camera finishes before the text does. Held until `CAM_START_S` (1.92s at 1x, stored as a fraction of the span) against the plate's own 51-frame hold. **The default is solved against the clip, not copied from the reference panel** — that panel reads 0.40, 0.00, 0.00, 1.00, which run here peaks at 109 px/frame, twice what the clip does; searching the handles for the clip's own profile lands on 0.35, 0.08, 0.35, 1.00, giving peak 52 at frame 67 against the measured 54 at 66. Progress runs on the typing schedule rather than the caret's measured x on purpose: reading the caret inherits the per-character steps and the pan comes out jagged, a 150 px/frame peak jumping 5, 64, 46, 27, 33, 5. `PAN`/`PAN_REF` are kept as the record and the way back. |
| The bar's G mark is 8.72% over its measured size | The wide shot gives 124.8 tall at our scale, and that is what the mark was. By request it now runs 8.72% larger — 132.53 x 135.68 — taken about its own centre so it grows in place rather than off one edge. Two things it preserves: the artwork's 250x256 aspect (0.9768 either way) and its centring on the bar, which lands on 537 exactly with 49.16 of inset above and below. One thing it moves: the mark's right edge goes 508.0 to 513.32 and the query starts a fixed ink gap past it, so `GMARK_RIGHT` had to follow or the text would have overlapped the bigger mark. That takes the query's start to 580.7 and the bar to 2517px with the pan at 1609 — the plus is untouched at 425/58/58 and its own bar stays 2491. Back: `left:386.1px;top:474.6px;width:121.9px;height:124.8px` and `GMARK_RIGHT = 508.0`. |
| The bubble's rows come from the query field | The plate never shows a wrapped query, so nothing about a second row comes off it. By request the bubble now takes the field's own line breaking: `fieldLines` mirrors the field — same font, same content width, same wrapping — and reads which line each character landed on, and act 2 draws those lines. So the field is a preview of the bubble and the row counts always agree. It cuts both ways, which is the thing to know: the field breaks at about 44 characters and the plate's query is 43, so the reference sits ONE character inside a single row, and anything that narrows the field — a classic scrollbar in the panel rather than an overlay one — would wrap the field and so wrap the bubble, moving the answer with it. That is the coupling behaving as asked, not a fault. A row is 54px, the measured 102 less 24 of padding either side, which is also the body's line-height ratio (1.414) at 38.22 to within 0.05. `max-width:1438` survives as a bound rather than a cap — the field's line length settles the width long before it. Verified in exported pixels: 43 and 95 characters both draw 854-1679 at 825 wide, 102 and 210 tall, the answer 54 lower per row. Back: hand `qq` the raw string instead of `fieldLines(str).join("\n")`. |
| The MOV's alpha is `a * 257`, not ffmpeg's | 8-bit alpha goes straight to 16, so opaque is exactly 65535. ffmpeg's own encoder goes through its 10-bit plane and stores 65343 — 99.71% opaque, which over a stack of layers is a real 0.75-of-255 error on something that should be solid. The cost, measured: read back *through ffmpeg* 127 of 256 alpha values come out 1 off, because ffmpeg divides by 65280 rather than 65535 on the way back. Every editor reads the 16-bit channel directly. Back: `(a << 2) << 6 | (a >> 2)`. |
| The GIF's transparency is a threshold at half | GIF has one all-or-nothing palette index, not a channel, so a partly covered pixel has to fall one side of a line. At 128 the query, the chip fill (75%) and the gradient survive and the bar's 30% scrim (76) does not — the bar reads as an outline. Lowering the line keeps the bar but paints a 30% wash as solid black, which is a bigger lie about the design than leaving it out; the MOV is the one that carries the real matte. Back: change the 128 in `GifWriter.prototype.frame`. |
| The GIF renders the piece twice | Its palette is sampled across the whole animation, so it cannot be settled until the last frame has been seen. Holding the frames to come back to is frames x W x H x 4 — 3.4 GB at 1920 and 60fps — so the largest combinations used to be refused outright. Time instead of memory: 1920 at 60fps is 406 frames, 812 renders, and it finishes. The sample stride is also chosen from the total now rather than fixed at every 23rd pixel, so the list the median cut runs on stays near 400k colours whatever the export. |
| The GIF samples at the rate it can hold, not the one asked for | Its delay field is whole centiseconds, so 60fps is not expressible — the shortest frame is 2cs, which is 50 — and 30 rounds to 3cs, which is 33.3. It used to sample at the requested rate and then stamp the rounded delay, so a 60fps GIF carried 406 frames and played for 8.12s instead of 6.76 — 17% slow. It now samples at `100/delayCs`, so the frame count changes and the duration is right. The MOV and MP4 have a 90000 timescale and are exact at every rate. |
| The typing's length sets the act's | `TYPE_PER_CHAR` is taken from the plate — 43 characters across frames 18…108, so 2.093 frames each — and the run is that times the query's length. The plate stretched or crammed every query into the same 90 frames; this gives a short query a short act. The reference length reproduces the plate exactly, since 43 × 2.093 is 90 again. Everything downstream follows through `TAIL`: 2 chars is a 76-frame piece, 8 is 89, 43 is 162, 73 is 225, and the outline lights 7 frames after the last character in all of them. **Very short queries are violent** — 2 characters gives the camera 2.9 frames for its whole move, a 272 px/frame whip, and the pan is 1.2px shy at that instant before landing on the next frame. Nothing is clamped; the rate is the rate. Back: `typeEnd` returning `TYPE_F0 + (TYPE_F1 - TYPE_F0) / TYPE_SPEED`. |
| Everything after the typing rides on it | `TAIL` is how far the text's landing has moved off the plate's 108, and every downstream beat — outline, press, push, act 2 — reads a clock shifted by it, so the whole tail follows the typing speed. `NF_EFF` and `DUR` carry it too, so the piece gets longer or shorter rather than running off its own end: 162 frames at 1x, 127 at 2x, 209 at 0.6x, with act 2 fully resolved at the last frame in each. The plate's beats are fixed. Back: set `TAIL = 0` in `setTail`. |
| Typing starts on frame 18, with the beam | The text's first character and the bar's gradient arrive on the same frame. The caret keeps the plate's own 8 on / 8 off up to that point and then stops — solid from the first character until the string completes, which is the plate's behaviour too. Between the caret arriving on 6 and the beam on 18 that is one full on-phase and part of an off-phase rather than a whole number of blinks; the alignment to the beam is what is being held, not a blink count. Verified frame by frame: gone to 5, solid 6-13, off 14-17, then solid from 18 with the first character and `BEAM_FADE`'s first entry, solid through to 108, gone from 109. The plate types from 26 with the beam already running. Back: `TYPE_F0 = 26`. |
| `TYPE_SPEED` moves the end | The rate is anchored on the start, so 1x still lands the last character on 108 but anything slower runs past it — and past 113 it is still typing when the button lights. Not prevented, but the panel says so. The plate's uneven cadence survives: for the reference string `TYPE_REF` is remapped onto the new window rather than replaced by an even spread. Back: set the slider to 1. |
| The bar's outline sits **on** the bubble, its glow outside | The two halves go opposite ways by request. The core is pulled in by half its width so its outer edge lands on the bar's edge and it reads as drawn on the pill; the bloom keeps the outward mask, so the glow is a true outer glow. The plate has the whole thing on the border centre-line with the glow outward, so only the core's position departs — the glow direction still matches the measurement. Profiled in an export: glow rising 24 → 63 across y 396-418, core 168 across 420-424, and a flat 0 over the white face from 426 in. The chip's ring is outside on both counts. Back: negate `BEAM_OFF` at its three uses in `layoutBar`. |
| Glow louder over footage | `RING_GLOW_BG` (1.35 on the spread) and a CSS rule taking `#ringBloom` from the measured .55 to .85 opacity. A flat white card and a moving plate are not the same backdrop. Applies only with footage loaded. Back: set the constant to 1 and drop the `#stage.has-bg #ringBloom` rule. |
| Answer heading at Medium | `.body h2` at 500 against the plate's SemiBold. Its stems measure 7.0px on the x-height where the body's are 4.0 — a 1.75 ratio, which is what put it on 600 in the first place, and 700 came out 8.0 and visibly too thick. By request. Read back off an exported frame the median stem goes 7 to 6. Back: 600. |
| Query at `font-weight:356` | Was a plain 400. Comparing the word "what" in both panels of the side-by-side — 96×33 on the plate against 99×34 here, so the same type size — the plate carries **6.6% less ink per unit area**. On the axis that density sits between 350 (0.9234 of regular) and 360 (0.9411), and 356 interpolates it; the applied value reads back at 0.9296 against the 0.9336 target. Hold it loosely: the comparison is half-res through H.264, and the stem metric argues ~334, so the honest range is ~335–356 and this takes the blur-robust end. It also narrows the query slightly, so bar 2586 → 2578 and pan 1678 → 1670. Back: set it to 400. |
| `ICON_TEXT_INK_GAP = 73` | The plate's close-up starts the query 33.7 past the plus. That is not arbitrary — the ad's wide shot runs its gap at 0.585 of its mark's width, and 0.585 × the plus's 58 is 33.9, so the plate scales the gap to the icon. Holding the wide shot's absolute 73 for both icons instead was requested, and it is the one departure that moves the **default** off the measured geometry: bar 2547 → 2586, pan 1639 → 1678. Back: set the constant to 33.7. |
| No legal line | The plate carries a disclaimer across `y 1039`, measured at 16.94px `#5f6368`. Removed by request. Back: restore the `.row.legal` div in `#act2` and its `.legal` rule with `--legal:#5f6368`. Act 2's other blocks are unaffected — nothing was positioned off it, and the answer's overflow bound is the 1010 constant, not the element. |
| Both gradients drift **clockwise** | The plate drifts both counter-clockwise. By request. Back: negate the beam's `shift` at its `paintRamp` call, and set `RING_DRIFT = -771`. Each flip pivots on its own reference frame (30, 120), so the measured hues *at* those frames hold either way. |

## Not done

**The repo has never been pushed.** No `gh`, no Homebrew, no SSH keys, no stored
credentials on this machine — so the last step needs a human. Create an empty
public repo, then:

```
git remote add origin https://github.com/YOUR-USERNAME/search-motion.git
git push -u origin main
```

Then Settings → Pages → `main` / root, and replace the `YOUR-USERNAME`
placeholder in the README's demo link.

## Weakest part

The cut — five frames at ~0.45 agreement. Two of them are ~99% white, where the
metric has almost no ink and swings wildly; the other three are heavily smeared
and were fitted from only three data points. It reads correctly at speed and
will not survive a freeze-frame.

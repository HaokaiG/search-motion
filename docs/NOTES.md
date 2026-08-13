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
| The camera is triggered by the text, eased by the plate | **The baked `PAN` curve no longer sets the timing, only the shape.** The move opens on the frame the 4th character lands (`CAM_CHAR`) and closes on the frame the AI Mode outline is about to light (`RING_F0 + TAIL`), and in between runs `PAN`'s own normalised profile with its 51-frame hold stripped, since the hold is now expressed by when the window opens. Both ends re-time with the speed on their own — one is a character in the schedule, the other is the outline's own frame put back on the real clock — so nothing is computed from the rate. Verified at 1x: opens 23, closes 114, outline first visible 114.5, pan 0 → 1583 = `PAN_END`; at 2x, 21 → 69 against an outline visible on 69.5. The move runs slightly PAST the typing (108 → 114 at 1x), which is the tail of the plate's easing and nearly stopped by then. Velocity reads 0, 22, 45, 43, 30, 21, 14, 10, 6, 3, 1, 0 — a 45 px/frame peak against the plate's 56 over its own window. `PAN`/`PAN_REF` are kept as the record and the way back. |
| Everything after the typing rides on it | `TAIL` is how far the text's landing has moved off the plate's 108, and every downstream beat — outline, press, push, act 2 — reads a clock shifted by it, so the whole tail follows the typing speed. `NF_EFF` and `DUR` carry it too, so the piece gets longer or shorter rather than running off its own end: 162 frames at 1x, 127 at 2x, 209 at 0.6x, with act 2 fully resolved at the last frame in each. The plate's beats are fixed. Back: set `TAIL = 0` in `setTail`. |
| Typing starts on frame 18, with the beam | The text's first character and the bar's gradient arrive on the same frame. The caret keeps the plate's own 8 on / 8 off up to that point and then stops — solid from the first character until the string completes, which is the plate's behaviour too. Between the caret arriving on 6 and the beam on 18 that is one full on-phase and part of an off-phase rather than a whole number of blinks; the alignment to the beam is what is being held, not a blink count. Verified frame by frame: gone to 5, solid 6-13, off 14-17, then solid from 18 with the first character and `BEAM_FADE`'s first entry, solid through to 108, gone from 109. The plate types from 26 with the beam already running. Back: `TYPE_F0 = 26`. |
| `TYPE_SPEED` moves the end | The rate is anchored on the start, so 1x still lands the last character on 108 but anything slower runs past it — and past 113 it is still typing when the button lights. Not prevented, but the panel says so. The plate's uneven cadence survives: for the reference string `TYPE_REF` is remapped onto the new window rather than replaced by an even spread. Back: set the slider to 1. |
| The bar's outline sits **on** the bubble, its glow outside | The two halves go opposite ways by request. The core is pulled in by half its width so its outer edge lands on the bar's edge and it reads as drawn on the pill; the bloom keeps the outward mask, so the glow is a true outer glow. The plate has the whole thing on the border centre-line with the glow outward, so only the core's position departs — the glow direction still matches the measurement. Profiled in an export: glow rising 24 → 63 across y 396-418, core 168 across 420-424, and a flat 0 over the white face from 426 in. The chip's ring is outside on both counts. Back: negate `BEAM_OFF` at its three uses in `layoutBar`. |
| Glow louder over footage | `RING_GLOW_BG` (1.35 on the spread) and a CSS rule taking `#ringBloom` from the measured .55 to .85 opacity. A flat white card and a moving plate are not the same backdrop. Applies only with footage loaded. Back: set the constant to 1 and drop the `#stage.has-bg #ringBloom` rule. |
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

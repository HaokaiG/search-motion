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
| The outline's spin eases | The plate turns it at a flat 771 units/frame. It now enters fast and leaves 30% slower, `RING_EASE = 0.30`. `RING_V0` is solved so the **mean** rate over the outline's life is still 771, so the ramp covers the same total distance (10794 either way) and frame 120 — the frame the hues were solved from — is untouched. Back: set `RING_EASE` to 0. |
| The outline is cut by the press | An extra fade tied to `PRESS[0][0]`, so the outline goes as the button starts down. Worth knowing it barely does anything today: the measured envelope is already at 0.204 on 127 and 0 on 128, so at 24fps the integer frames are unchanged and only sub-frame samples differ. It is there so the two stay tied if the press is ever re-cut. Back: drop the `RING_PRESS_FADE` factor. |
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

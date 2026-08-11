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

## Open decisions

Departures from the plate that were deliberate, and the one-line way back:

| | |
|---|---|
| `LOGO_NUDGE = 0` | The plate has the wordmark **12px left** of the bar's centre. Centring it exactly cost ~0.10 of act-1 agreement. `-12` restores the plate's position and keeps the centring behaviour. |
| Sidebar icons at `--side-icon: 0.975` | 1px under the measured size, by request. |
| Edit icon at `top: 425.5` | ~4px **below** the plate. Its ink is at y402-441 and its square body at 406-441; this is a design call, not a match. |
| Bubble corner `10px` | Specified. The plate's own corner reads closer to **5-6px**. |
| Active nav ink `#1f1f1f` | The plate reads `rgb(0,0,0)`. Would darken the AI Mode label and its caret together. |
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

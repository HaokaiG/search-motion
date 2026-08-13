# Search Motion

A 6.8-second Google Search "AI Mode" spot, rebuilt from the footage in plain HTML, CSS and
JavaScript. No build step, no libraries, no framework — `index.html` is one self-contained file.

**[▶ Live demo](https://YOUR-USERNAME.github.io/search-motion/)** ·
[recreation.mp4](docs/recreation.mp4)

The source clip is 1920×1080, 23.976 fps, **162 frames (6.757 s)**. Every number in the code
came out of those frames; nothing was matched by eye. The point of the exercise was to see how
far measurement alone could get, so each value below is something read off the pixels rather
than dialled in until it looked right.

```
index.html          the piece — open it, or serve the folder
fonts/              the subset webfont and its licence
tools/build-font.sh regenerates that subset from an installed Google Sans Flex
docs/recreation.mp4 this recreation's own output
NOTICE.md           third-party assets and trademarks — read this before republishing
```

## Running it

Open `index.html` directly, or `python3 -m http.server` and visit it. The controls sit in a side
panel on the right, grouped by what they do; the stage centres in the space beside it. The panel
lets you:

- **edit the query** — always lower case, as the plate's is. The typing re-times around fixed
  beats, so the last character still lands on frame 108 and the button still lights and is
  clicked on schedule whatever length you type. The bar sizes itself to the question and the
  camera move follows from that: the pan covers whatever distance parks the bar's right cap on
  screen x=1236, which is where the plate parks it
- **set the typing speed** — a slider from 0.2x to 5x, or type the number in for anything up to
  20x; the two drive each other, and past 5x the bar simply sits at its end while the field
  carries the value. Typing always begins on frame 18 — the same frame the bar's gradient does — whatever
  the rate, so the speed moves the *end*. The caret blinks at the measured 8 on / 8 off until
  then and goes solid as the first character lands. 1x still lands the last character on 108 as
  the plate does; slower runs past it, and past 113 it is still typing when the button lights,
  which the panel says outright rather than preventing
- **set the camera speed** — the pan follows the newest character rather than running a baked
  curve: it chases a target derived from the caret by a fixed fraction of the remaining distance
  each frame, which makes it smooth by construction and lets it settle rather than stop. The
  slider scales that fraction. At 1x it is measured against the source clip's own camera — peak
  53 px/frame against the plate's 54 — and parks the bar's cap on x=1236 as the outline lights.
  Everything after the typing — the outline, the click, the cut, act 2 — rides on the text too,
  so the piece runs 162 frames at 1x and 117 at 2x
- **edit the answer** — blank line starts a paragraph, `## ` makes a heading, `**…**` marks a
  highlighted run. The copy reflows in the measured 1290px column, and the reveal re-derives its
  lines from where layout actually put the words, so the top-down gradient survives the edit
- **turn the wordmark off** — Act 1's Google logo drops out and the bar sits alone in the white.
  Nothing measures back off the logo, so the bar width, the pan and the beam are untouched; the
  small G in the Act 2 header is a separate mark and stays
- **switch the bar's icon** — the plus at the left of the search bar becomes the G mark, measured
  off the ad's own wide shot: there the bar is 165 tall and the mark 88 square, inset 38.5
  vertically and 41 on the left, so at our 234 the mark is 124.8 tall and inset 54.6 / 58.1.
  Keeping the gap that frame puts between mark and text moves the query's start from 516 to
  575.3, and since the bar's right edge derives from where the text ends, the bar grows 59px and
  the pan with it — the cap still parks on x=1236, it just travels further. The plate's plus is
  the default
- **drop footage behind act 1** — pick a video and it plays under the search bar instead of the
  white card, with the bar, the beam and the AI Mode button compositing over it. Act 2 is
  untouched: its own white background covers the footage as the answer page rises, which is how
  the reference cuts out of the live shot. Over footage the furniture changes with it: the bar
  swaps its white fill for a black scrim at `--bar-scrim` (0.30), the AI Mode chip's fill drops
  to 75% so the plate reads through it while its label and gradient outline stay fully opaque,
  and the query and the chip's label both step up to Medium, the query going white — the plate's
  356 is too light to hold against a moving background. The video follows the piece's clock and
  wraps if it is shorter than 6.757s
- **export a GIF or an MP4** — width and frame rate selectable, shared by both. The MP4 is
  H.264 via WebCodecs, with the container written by hand alongside the GIF encoder, so there
  is still nothing to install. Both walk the same deterministic render path rather than
  capturing the screen, so a frame is a frame whatever the machine is doing

Both fields warn when the text outruns its room: the query when it reaches the AI Mode button,
the answer when it passes the bottom of its measured column.

`#t=<seconds>` freezes a single instant and `#bare` hides the controls — that pair is how the
stills for the frame-by-frame diff were rendered. `#q=` and `#a=` carry an edited query and
answer, `#logo=0` drops the wordmark, `#icon=g` puts the G in the search bar, `#speed=` sets
the typing rate and `#cam=` the camera's, so an edit survives a reload and works in headless renders.

---

## What the footage actually does

**Act 1 — 0.000 → 5.464 s.** An extreme close-up of the Google homepage. A query types into
the search bar and the camera pans right to reveal the *AI Mode* chip at the bar's right end.

**The click — 4.713 → 5.464 s.** The query lands (last character, frame 108), the AI Mode
button lights up with a gradient outline that rotates around it, the outline fades, and the
button is pressed — scaling to 0.897 on frames 129-130. That press is what motivates the cut.

**The cut — 5.464 → 5.672 s.** The chip alone swells toward the viewer, smears, and blows the
frame out.

**Act 2 — 5.506 → 6.757 s.** The AI Mode answer page rises a few dozen pixels into place and
fades up out of the white.

---

## What was measured, and how

| Quantity | Method | Result |
|---|---|---|
| Camera path *(measured; the move is now triggered by the typing and only shaped by this — see `docs/NOTES.md`)* | Phase-correlate the static logo band, frame to frame | Pure horizontal pan. **0 px** vertical, bar height held at 234 px throughout → **no tilt, no zoom** |
| Pan curve | Cumulative sum of the above | Holds 51 frames, ramps to a **56 px/frame** peak, then decays exponentially (**≈0.95 per frame**) into a **1639 px** landing. Baked into the `PAN` array verbatim |
| Typing | Track the caret's right edge across frames 20-110 | **Not** a clean 2-frame cadence. 43 change-frames, first on 26, last on 108, with two 1-frame steps (26→27, 69→70) — a ~12.3 char/s rate quantised onto the 23.976 fps grid. Baked frame by frame, not modelled |
| Type sizes | Solve each run's size from its measured ink width using the real font's metrics | Query **90.95px**; body **37.97px**; heading 46.22px; nav 35.34px; chip label 63.53px; legal 16.94px — all at the font's default optical size and default tracking |
| Type weights | Stem widths on the x-height, against the body as reference | Body stems 4.0px. The answer's highlights measure 5.0px (**Medium**) and the heading 7.0px — a 1.75 ratio, which is **SemiBold**, not Bold. At `wght 700` the heading came out 8.0px, visibly too thick |
| Caret | Same signal, before typing starts | Appears frame 6, **8 frames on / 8 off** (0.667 s cycle); solid while typing; gone once the string completes |
| Shutter | 10–90 % edge width of the green `l` stem vs. pan speed | **3.5 px at rest → 8.0 px at 56 px/frame**, i.e. a ~9 px smear — a short **≈60° shutter**, not the 180° a live-action plate would give |
| Chip push | Chip width across frames 131–134 | 1.00 → 1.58 → 4.45×, fitted as `1 + 0.575·u^2.58` |
| Act-2 settle | Topmost dark row per block, frames 137→161 | One shared exponential, ratio **0.835/frame → τ = 0.253 s**; travel 27–48 px depending on block |
| Act-2 fade | 1st-percentile luminance per block (position-independent) | Every body block rides the **same** ramp, 5.6 → 6.0 s. Chrome and the query chip come in faster and earlier |
| Button outline | Saturated ink summed over the chip, every frame | Absent until 114, first light on **115**, **peak on 122**, gone by **128**. It never holds: the envelope is a triangle, at full strength for one frame only, and the earlier reading of "up by 118, down from 123" flattened everything between. Same ramp as the bar's beam, but closing on itself once per lap of the 1090 px perimeter — 4.65 ramp units per arc px, phase moving 771 units per frame |
| The click | Label ink width and icon width through the press | The button is pressed before the cut: scales to **0.897** on frames 129-130, springs back on 131, and the push through it starts from there |
| Gradient beam | Saturated-pixel search on the bar's top edge, bottom edge and left cap | Enters where the bottom run meets the right cap on frame 18, sweeps left, turns the left cap on frame 20, crosses the top by 22, then closes down the right cap; tail clears from 34 and it is gone by 45. Head ≈**800** arc-px/frame, tail ≈**310**, over a 4987 px outline. The colour ramp itself slides forward at ≈**47** px/frame. It also **fades in** rather than switching on with the head: dividing the plate's ink curve by the sweep's own leaves a residual of 0.087, 0.405, 0.638, 0.734, 0.953 across frames 19-23, reaching full by 26. The lap is all four sub-paths — the perimeter always counted both caps, so drawing only the left one left the right cap dark |
| Glow direction | Chroma profile perpendicular to the bar's top edge, either side | The plate's glow is **entirely outward**. Crossing inward from the stroke it reads 9, 6, 0 and stays 0 across the bar's face; outward it falls 66, 52, 42, 38, 25, 17 over ~32px. The bloom is a fat stroke, so a plain blur put half of it inside, and masking it is what the measurement asks for. **The bar's outline has since been moved onto the bubble by request**, though its glow still reads outward as measured — only the crisp core's position departs. See the open-decisions table in `docs/NOTES.md` |
| Geometry | Edge/run detection on single frames | Bar `x 328…2875, y 420…654, r 117`; chip `x 2375…2830, y 459…617`; wordmark letter bounds and stroke weights; every act-2 line box and ink width |
| Bar sizing | The three gaps implied by those numbers | The query ink ends at 2258, the chip runs 2375…2830, the cap is at 2875 — so the bar's right edge is the text end + 617 and the chip hangs 500 in from it. Feeding the reference question back through those rules reproduced the measured bar (2547px) and pan (1639px) exactly, so the adaptive layout is the measurement, not an approximation of it. The icon-to-text gap has since been widened by request, which moves the default to 2586 / 1678 — set `ICON_TEXT_INK_GAP` to 33.7 to get the measured pair back |
| Colours | Direct pixel sampling | chip `#f5f6f8`, act-2 chip `#f1f2f6`, rules `#ebebeb`, nav `#535353`, caret black. Wordmark palette is set to brand values (`#3186FF` `#FC413D` `#FEC700` `#00AF57`), which happen to sit closer to the plate than the older ones — mean per-channel error per letter drops from 8/10/15/24 to 6/11/7/16 |

Two first readings the measurements overturned:

- **There is no white flash layer.** Frame means run `.968 .951 .930 .942 .991 .984`. The dip
  is the swollen near-white chip covering the frame; the spike on 136 is that chip *leaving*
  before the answer has faded up. On frames 135–136 the only genuinely dark thing in the plate
  is its legal line, which this recreation no longer draws.
- **The answer does not stream in word by word.** It looks like it, but measuring each block's
  darkness independently of its position shows every block on one identical ramp. It is a plain
  fade-up with a faint top-down gradient.

And one detail that is easy to miss at speed: the gradient beam's colour is a function of
**arc length around the outline**, not of screen x. At any given x the top edge and the bottom
edge are different colours — green underneath while it is already red on top.

---

## The typeface

The original is set in **Google Sans Flex**, and the copy installed on this machine is what
the recreation uses. It ships as `GoogleSansFlex-subset.woff2` (**29.7 KB**) and is also
base64-embedded in `index.html` so the page stays self-contained:

- instanced to defaults on `wdth`, `GRAD`, `ROND` and `slnt` — the piece never varies them
- `opsz` and `wght` kept live as real axes (verified: "Soccer" measures 361 px at `opsz 6`
  against 293 px at `opsz 144`, so the axis is genuinely driving the render)
- subset to the 43 characters the piece actually draws → 70 glyphs

`font-optical-sizing` is set to `none` and `opsz` pinned per element. It has to be: these are
video pixels at a 5.35× zoom, not type points, so letting the browser derive `opsz` from a
91 px `font-size` would pick an optical size roughly five times too large.

How well it fits: each text run still gets a `letter-spacing` correction computed at runtime to
land on the measured ink width. With the substitute face that correction was **+5.5 px per
character** on the query. With Google Sans Flex at the solved size it is **+0.14 px** — about
6 px across a 1742 px string. That near-zero residual is the real evidence the face and the
sizes are right.

Google Sans is proprietary and trademarked. Embedding it here is fine for local work; it is a
redistribution question if the file leaves this machine.

## How it is built

- One flat **content plane** holds act 1 in the same pixel grid the camera pans across, so
  every element sits at its measured coordinate. The camera is a single `translate3d` on it.
- Motion blur is a real directional filter — an SVG `feGaussianBlur` with `stdDeviation="σ 0"`,
  σ recomputed each frame from pan velocity × shutter ÷ √12.
- The Google wordmark is the real artwork. Google Sans Flex carries the logo in its
  private-use range — `U+E000`–`E004` are `G.logo`, `o.logo`, `g.logo`, `l.logo`, `e.logo`, and
  `U+E006` is the whole word. Those outlines are laid out on their own advances and coloured per
  letter. The glyph metrics corroborate the pixel measurements exactly: the `g` descender is 464
  font units, which at the fitted scale is 93.6 px — the footage measures 94.
- The AI Mode spark is the supplied `search_spark.svg` artwork, its ink placed on the measured
  67x67 px at content x 2434, y 504.
- The answer page's G, menu and edit icons are the supplied artwork, each fitted to its measured
  box. The G's conic gradient arrives from Figma as a `foreignObject` hack, so it is rebuilt as a
  CSS `conic-gradient` masked by the supplied outline — and the plate agrees with the reading:
  red at the top, blue right, green bottom, yellow left, all four hues matching.
- Everything is driven by one `render(t)` function off `requestAnimationFrame`.

## Verifying it

`#t=<seconds>` freezes on an instant and `#bare` hides the HUD, which is how the stills for the
frame-by-frame diff were rendered:

```bash
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless=new --disable-gpu --window-size=1920,1080 --screenshot=out.png "file://$PWD/index.html#bare&t=2.836"
```

Agreement with the source over **all 162 frames**, scored on lit pixels only (a white background
is trivial to match, so it is excluded) after a small blur, so the metric reads layout rather
than font hinting:

```
                 substitute   Google Sans Flex   + outline & click   + real logo art
act 1   (0-131)     0.792          0.785              0.798              0.881
the cut (132-136)   0.447          0.427              0.461              0.475
act 2   (137-161)   0.714          0.769              0.776              0.778
whole clip          0.769          0.772              0.784              0.853
```

Act 1 peaks at **0.960**. Dropping the reconstructed wordmark for the font's own logo glyphs was
the single largest gain in the whole exercise — it is a big, high-contrast element and it sits
in nearly every frame of act 1, so the few pixels each hand-drawn curve was off by cost more
than everything else combined.

Every section is now at or above where it started, and the whole clip is up **+0.015** on the
original substitute-font version — with the typeface, the button outline, the click and the
typing schedule all now taken from the footage rather than guessed.

Worth being straight about this: swapping in the real typeface moved the overall number by
**+0.003**. Act 2, which is nothing but text, gained a clear **+0.055**. Act 1 lost 0.007 even
though its geometry now matches the source more closely than before — the chip icon, the chip
label, the cap heights and the typing schedule all landed on measured values in the process.
The metric is dominated by whether thin strokes overlap to the pixel, and the substitute face's
wide `letter-spacing` happened to land some glyphs closer by luck. It is a fair score, not a
flattering one, and it is the one worth reporting.

`comparison.mp4` in this folder is the original and the recreation side by side.

## Licence

The code is MIT (`LICENSE`). The assets are not mine: Google Sans Flex is under the SIL Open
Font License and the Google marks belong to Google. **`NOTICE.md` has the details** — and the
source advertisement is deliberately not in this repository.

## Where it falls short

- **Sub-pixel glyph placement.** Chrome lays the string out ~16 px wider across 1742 px than the
  font's own metrics predict, so individual glyphs sit within a pixel or two of the source
  rather than exactly on it. The metric is sensitive to that in a way the eye is not.
- **The two low minima (0.033 and 0.152) are frames 136 and 137** — the blown-out ones. Both the
  source and the recreation are ~99 % white there, so the metric has almost no ink to compare
  and swings wildly. That is measurement noise, not a visible mismatch.
- **The cut is the weakest section.** Four heavily-smeared frames, fitted from three data points.
  It reads correctly at speed but will not survive a freeze-frame.

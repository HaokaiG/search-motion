# Search Motion

Two Google Search "AI Mode" spots, rebuilt from their footage in plain HTML, CSS and
JavaScript. No build step, no libraries, no framework — `index.html` is one self-contained file.
The **Piece** selector at the top of the panel switches between them; they share the frame, the
clock and every export path, and share no markup and no constants.

| | |
|---|---|
| **AI Mode search** | 6.8s. The query types itself into the search bar, the camera pans, the AI Mode button lights and the answer page arrives. 162 frames. |
| **Prompt / response** | 8.0s. A prompt is typed into a dark box, sent, flashes to the answer page, and the answer's own words come back at 5× with one phrase lit. 192 frames. |

**[▶ Live demo](https://HaokaiG.github.io/search-motion/)** ·
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
panel on the right — playback, query, answer, look, motion, footage, export — with the stage
centred in the space beside it. The panel lets you:

- **edit the query** — always lower case, as the plate's is. Its **length sets the length of the
  act**: the plate types 43 characters across frames 18-108, so 2.093 frames each, and the run is
  that rate times whatever you type. Everything after the typing rides on it, so the whole piece
  follows — 8 characters is 3.70s, the plate's 43 is 6.76s, 73 is 9.38s — and the outline always
  lights 7 frames after the last character. The bar sizes itself to the question too, and the
  pan covers whatever distance parks the bar's right cap on screen x=1236, where the plate parks it
- **set the typing speed** — a slider from 0.2x to 5x, or type the number in for anything up to
  20x; the two drive each other, and past 5x the bar simply sits at its end while the field
  carries the value. Typing always begins on frame 18 — the same frame the bar's gradient does — whatever
  the rate, so the speed moves the *end*. The caret blinks at the measured 8 on / 8 off until
  then and goes solid as the first character lands. At 1x the plate's own query lands its last
  character on 108, as the plate does; any other rate or length moves that frame and the rest of
  the piece with it, and the panel reports the run and the total it implies
- **shape the camera move** — the pan is a function of how far through the query the typing has
  got rather than of the clock, so it tracks the text at any rate and lands exactly as the last
  character does. Its easing is a cubic bezier with the same four handles After Effects and CSS
  use, dragged on the curve itself, with a reset back to the measured default under it and a
  speed slider scaling the progress on top.
  It holds until 1.92s at normal typing speed — the plate holds its own camera 51 frames. The
  default handles are solved against the source clip rather than picked: 0.35, 0.08, 0.35, 1.00
  gives a peak of 52 px/frame at frame 67, against the clip's measured 54 at 66.
  Everything after the typing — the outline, the click, the cut, act 2 — rides on the text too,
  so the piece runs 162 frames at 1x and 117 at 2x
- **edit the answer** — blank line starts a paragraph, `## ` makes a heading, `**…**` marks a
  highlighted run. The copy reflows in the measured 1290px column, and the reveal re-derives its
  lines from where layout actually put the words, so the top-down gradient survives the edit
- **act 2's query bubble takes its line breaks from the query field** — what the field shows is
  what the bubble draws. Its soft wraps become rows in act 2, so the shape is visible while you
  type and needs no Enter to ask for, and the two row counts always agree. The field breaks at
  about 44 characters and the plate's query is 43, so the reference stays on one row and every
  measured position with it. The bubble's width then follows its longest line — 120px at two
  characters, 353 at fifteen, the plate's 825 at 43 — with a 1438px limit behind it for safety,
  that being the answer column's own span, the bubble's right edge being pinned 241 from the
  frame's and the column beginning on 241.
  The query field is a text area, so **Enter puts a break in** as well, wherever you want one,
  and the bubble takes a row there too. Each extra row is 54px and pushes the
  answer down by exactly that, which means a one-row query leaves every measured position where
  the plate has it and only a wrapped one moves anything. The column's overflow warning counts
  the room the bubble took, so a long query and a long answer are weighed together.
  Act 1 cannot have rows — it is one pill — so the bar types a break as a space. That keeps the
  string's length, and every index in the piece is a position in it: the typing schedule, the
  caret, the camera. Breaking `what is the most popular sport in the world` in two therefore
  leaves the bar on 2491px and the pan on 1583 exactly where they were, and only act 2 changes.
  The panel reports the rows the bubble actually draws rather than the newlines counted — a
  trailing break makes no row of its own, and a long line makes one without any break at all
- **turn the wordmark off** — Act 1's Google logo drops out and the bar sits alone in the white.
  Nothing measures back off the logo, so the bar width, the pan and the beam are untouched; the
  small G in the Act 2 header is a separate mark and stays
- **switch the bar's icon** — the plus at the left of the search bar becomes the G mark, measured
  off the ad's own wide shot: there the bar is 165 tall and the mark 88 square, inset 38.5
  vertically and 41 on the left, so at our 234 the mark is 124.8 tall and inset 54.6 / 58.1.
  It then carries **+8.72% by request**, taken about its own centre so it grows in place —
  132.53 x 135.68, still on the artwork's 250x256 aspect. Its margins are then set by request
  rather than measured, and all three now differ. Vertical is what centring in the 245.44 bar
  gives, (245.44 − 135.68) / 2 = **54.88**. Horizontal started at 19% over that, 65.31, and each
  side has since been asked for on its own: the left is that plus 2, **67.31**, and the right is
  that times 1.167 and then 5% again, **80.03**. Against the vertical they run 1.2265 and 1.4583.
  The right-hand figure is what the mark faces the *query* across rather than an edge of the bar,
  so it replaces the 73.0 icon-to-text ink gap for the G; being an ink gap it is quoted to the
  query's ink, and the 'h' bears 5.596, so the text box starts 602.27 to put the first stem 80.03
  clear. The plate uses none of this — its own left inset is 58.1 against 54.6 vertical, about 6%
  wider.
  **The text-to-chip gap is untouched by any of it**, and structurally so: the chip hangs off
  wherever the text ends by `CHIP_GAP`, so moving the text moves the chip with it. Measured the
  same 110.62 whichever icon the bar carries. The bar itself grows to 2559px and the pan to
  1651 — the cap still parks on x=1236, it just travels further.
  **The bar itself also runs 4.89% over the plate's while the G is in it**, by request, and the
  AI Mode button scales with it rather than sitting in a bigger box. One factor throughout: the
  bar 234 → 245.44 taken about its own centre line, so 537 stays 537 and the pill grows 5.72
  either way; the button 455x158 → 477.25x165.73 with its radius, padding, gap, spark and label
  all following; and `CAP_R`, `CHIP_W`, `CHIP_TO_CAP` and the beam's y extent with them. The
  button's outline scales for free because it is an SVG with a viewBox *inside* the button — its
  arc lengths are in viewBox units, so the perimeter the hues were solved against never moves.
  The plate's plus is the default, and on it every one of these is the measured number again
- **play and export one half at a time** — *Whole piece*, *Search Query Only*, *AI Mode Chat
  Only*. The piece is one move but really two: the search bar up to the button being pressed, and
  the answer that comes out of it. The seam is frame 136 — the chip starts blowing up on 131 and
  act 1's opacity reaches zero at 135.8, so 136 is the first frame with nothing of act 1 left in
  it and the whole zoom behind you. **The preview follows the choice**, not just the export: it
  starts at the seam and stops on it rather than running past. It loops straight back with no
  pause on the last frame — there used to be one, 0.9s on the whole piece and scaled down on a
  half, and measured at 0.883s, 0.835s and 0.149s it read as a stall rather than a beat.
  Nothing else changes: every constant keeps
  its measured frame, and an exported half starts its own clock at zero. The two partition the
  piece exactly — at 480px and 8fps the query half is 46 frames and the chat half 9, against 55
  for the whole. The seam rides the typing like everything else after it, so a 7-character query
  puts it at 2.53s and a 95-character one at 10.21s, while the chat half stays 1.08s either way.
  The query half ends on the cut, where act 2 has already begun showing through the swelling chip
  — so on that setting act 2 keeps its white card and loses everything drawn on it, and the half
  blows out to white instead of to a glimpse of the answer. Measured: its last frame is white at
  every sampled pixel, against 2.4% of the frame carrying the answer on the whole piece, which
  keeps the cut intact. Act 1 is identical either way. What the half blows out *to* is whatever
  that mode puts behind act 2, so it follows one rule in three places: white on the plain card,
  where the last frame is white at every sampled pixel; nothing over transparency, where it
  measures 100% clear; and the plate over footage, where it measures 0% white and the corner
  reads the footage's own colour
- **drop footage behind act 1, and through the cut** — pick a video **or a still image** and it
  sits under the search bar instead of the white card, with the bar, the beam and the AI Mode
  button compositing over it. **The plate crosses to the background at the click**: it holds at
  full strength to frame 127, where the press opens, then fades out over exactly the frames the
  button spends being pressed and blowing up, reaching the background on 136 as act 1 does. Both
  ends are constants the piece already had, so there is nothing new to keep in step. Measured in
  exported pixels, a plate reading 38 in its red channel goes 38, 86, 133, 182, 222, 255 across
  frames 127 to 136 — a straight ramp to white. Act 2's white card is behind that: it no longer
  arrives with the cut on frame 132 but comes up on the answer body's own ramp, 0 through 133,
  0.181 on 136, 0.598 on 140, flat white from 144, so the handover is plate → background → card
  with no step anywhere in it. Over footage the furniture changes with it: the bar
  swaps its white fill for a black scrim at `--bar-scrim` (0.20), the AI Mode chip's fill drops
  to 75% so the plate reads through it while its label and gradient outline stay fully opaque,
  and the query steps up to Medium and goes white — the plate's 356 is too light to hold against
  a moving background. The chip's label does not: it is Regular in every mode by request, having
  been Medium here on the reasoning that the pill is only 75% opaque and the label needed the
  weight. A video follows the piece's clock and
  wraps if it is shorter than 6.757s; a still has no clock to follow, so every seeking and
  wrapping path returns early on it and the same frame composites under every frame of the move
- **go transparent instead** — the same treatment footage mode gives the bar, but with nothing
  behind it: the scrim, the white Medium query and the 75% chip, over an empty background.
  It is spaced like footage mode too: the wider text-to-chip gap goes with the look rather than
  with the video, so both sit at 140 and measure the same 140.22 on screen. It used to key off
  the video alone, which left the two modes spaced differently while looking otherwise identical.
  Act 2 still ends on its white card, and **the card waits for the chat here as it does over
  footage**. On the plain card it arrives with the cut on frame 132, opaque the instant it does,
  which is invisible against white. Against a matte, or a plate, it was not: it filled the frame
  six frames before any of the chat had drawn, taking the alpha from 82% clear to none of it with
  nothing to show for it. It now comes up on the answer body's own measured ramp, that being the
  first act-2 ink there is: the query chip's is 5.672 and the chrome's 5.756, both later.
  Measured, frame 132 goes from 0% clear to 80%.
  Frames 133 to 135 are still not clear, and should not be — act 1's own chip is blown up across
  the whole frame by then. That is the foreground, not the background.
  Turning it on puts the alpha into both exports that can hold one — the MOV keeps the whole
  graded matte, the GIF what its single transparent index can — for compositing the move over
  your own plate in an editor
- **export a MOV, a GIF or an MP4** — every size up to 1920px at every rate up to 60fps, and
  all three share the one size and rate. All three walk the same deterministic render path
  rather than capturing the screen, so a frame is a frame whatever the machine is doing:
  - the **MOV is ProRes 4444 with an alpha channel**, and the codec is written here — the DCT,
    the quantiser, the run-level entropy coder and the frame layout, then the container. Nothing
    in a browser will produce ProRes, and WebCodecs will not keep an alpha channel at all: every
    VP8/VP9 config with `alpha:"keep"` comes back unsupported. Writing it was possible because
    ffmpeg's own output could be used as ground truth — see `docs/NOTES.md`. It is quantised at
    qscale 1, which with ProRes's default matrices rounds each coefficient to the nearest integer
    and does nothing else, so it is visually lossless and correspondingly large: 63 MB for the
    6.8s piece at 1920 and 24fps. Verified by decoding the export back with ffmpeg — RGB matches
    the canvas to within the 1 code the sRGB → BT.709 video-range round trip costs, and the alpha
    exactly — and then again through macOS's own AVFoundation, which is the stricter reader of
    the two and the one an editor here would use
  - the **GIF** is opaque whatever the stage is set to, and spends all 256 entries on colour.
    It used to reserve one for transparency when the transparent mode was on; one all-or-nothing
    index is a poor matte and the PNG sequence is the answer for that instead.
    Its palette is built from a histogram of **every pixel of every frame** rather than a sparse
    sample, split classic-median-cut style — widest box first, cut at the population median — and
    each entry is the exact weighted mean of the colours behind it. Frames are then mapped by
    exact nearest-neighbour with **Floyd–Steinberg** error diffusion, which is what turns 256
    entries into a gradient that reads as continuous. Flat colour dithers to nothing, since the
    error is zero when the colour is already in the palette, so it costs noise only where there
    was banding to fix.
    Measured as error integrated over 4x4 blocks — which is how the eye sees a dither — this goes
    from 0.131 to **0.047** on the piece and from 2.368 to **0.312** on a gradient. Per *pixel*
    the error rises slightly, 0.62 to 0.85, and that is the dither working rather than failing:
    it trades pixel accuracy for local accuracy
  - the **PNG sequence** is the answer when that is not good enough, which for a transparent GIF
    it usually is not: a PNG has the whole channel and 8 bits of alpha a pixel, so the frames are
    what the canvas actually drew rather than an approximation of it. Measured on a transparent
    480px export, the PNGs carry 18–21% of the frame at partial alpha — the scrim and every
    antialiased edge — all of which a GIF has to round to on or off. The browser's own encoder
    writes them, so they are lossless; they come out in one archive because a browser will hand
    over one file, and the ZIP is written here like the other containers, stored rather than
    deflated since a PNG is already deflated
  - the **MP4** is H.264 via WebCodecs, with the container written by hand alongside the others;
    the profile level is asked for at export time rather than hard-coded, since Baseline 3.0
    cannot carry 1080p at all and 4.0 cannot carry it at 60
  The GIF used to hold every frame as raw RGBA — the palette is sampled across the whole
  animation and could not be settled until the end — which is 3.4 GB at 1920 and 60fps, so it
  declined the largest combinations. It now renders the piece twice instead, once for the
  colours and once for the frames, and has no ceiling

The answer field warns when the copy passes the bottom of its measured column. The query field
used to report the bar's width and the pan's distance beneath it; both are still derived from
what is typed, they are simply no longer printed.

`#t=<seconds>` freezes a single instant and `#bare` hides the controls — that pair is how the
stills for the frame-by-frame diff were rendered. `#q=` and `#a=` carry an edited query and
answer — `%0A` in `#q=` is a row break, so a broken query survives a reload and a headless
render — `#logo=0` drops the wordmark, `#icon=g` puts the G in the search bar, `#speed=` sets
the typing rate, `#cam=` the camera's and `#bez=` its easing, so an edit survives a reload and works in headless renders.

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
| Type weights | Stem widths on the x-height, against the body as reference | Body stems 4.0px. The answer's highlights measure 5.0px (**Medium**) and the heading 7.0px — a 1.75 ratio, which is **SemiBold**, not Bold. At `wght 700` the heading came out 8.0px, visibly too thick. *The heading now runs Medium by request; see `docs/NOTES.md`* |
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

## The second piece: prompt / response

The reference is 1920×1080, **192 frames**, and its background measures pure `(0,0,0)` — which
is a transparent plate composited onto black rather than a black one, so the recreation treats
it as transparent and paints black underneath only when an export asks for opaque pixels.

It runs in three acts joined by two transitions, neither of which is a cut: the prompt typing
into a dark rounded box (frames 3–47), the box **morphing into the answer page's query chip**
(48–52), the page held (52–79), the page **rushing out sideways** while act 3 arrives already
moving (80–96), and the answer's own words at 5× with one phrase lit, swapping once across
116–138.

### The two joins

| Quantity | Method | Result |
|---|---|---|
| Act 1 → 2 | Track the box's own rect frame by frame | It is a morph, not a flash. (959,540,1069,300) on f49, (998,518,1028,275) on f50, (1099,464,929,220) on f51, and the chip by f52 — one interpolation at .008, .115, .391, 1, which is **t^3.25** on t=(f−48)/4. The target is read off act 2's chip, so editing the prompt re-aims it |
| The wash under it | Empty background, frame by frame | Exactly linear and exactly four frames: **0, 0, 85, 170, 255** on f48–52. An earlier fit against whole-frame means put it at 48.72–52.06 — the mean also carries the box's face lifting on f49, and the box is 15.5% of the frame, which is that frame's whole rise |
| The box's face | Median inside the tracked rect | 0, 149, 211, 234, 240 on f48–52 — as a share of the chip's `#F0F1F4` that is **1−(1−t)³**. It goes opaque almost at once; the plate's box is a light grey through the morph, not the 35% wash it is while act 1 runs |
| The query through it | Extremes inside the box | It **flips**, it does not fade: 255 against a black face on f48, 0 against a 151 face on f49, and 0 while the face keeps lifting. Lerping the ink puts it within 19 of the face on that first frame, which reads as the text vanishing |
| Act 2's arrival | Correlating the answer's row profile against its settled frame | It **rises**, it does not fade up: 143px low on f56 reaching 0 on f67, peak correlation climbing 0.92 → 1.00, and the whole block moves together. **180·(1−t)^2.4** across f55–67. The chrome does something else again — the chip fades up from f52, the nav from f55, and the mark never moves at all |
| Act 2 → 3 | Line centres on the answer's left half, which stays sharp | It **scales up and out**. Those centres spread from a fixed point — 1.0067, 1.027, 1.080, 1.157, 1.304 on f80–84, all about **y=600** to within 2.2px — and the pivot's x is the block's own left margin, **241**, which is what holds that edge still. Growth fits **1 + 0.0067·(f−79)^2.25**. The chrome does not go with it: scaling about that pivot would have walked the mark 14px by f82 and it measures unmoved, so it fades on its own |
| Its blur | Frame-to-frame change over the answer's rows | A steady **19–21 per frame**, where a gaussian smear's decays to 3 however wide it is set. The blur is a **box** — real motion blur is a subject sampled evenly along its travel — and it is a symptom of the scale, not the motion: each point's smear is its own velocity, which is why it grows with x while the left edge stays crisp. Nine taps, driven by the frame's own displacement |
| Act 3's arrival | The lit phrase's extents, f87–96 | It arrives already moving at **0.808** scale and settles as **1 − 0.192·0.63^(f−87)**, about a point at **(268, 609)** solved from those extents — which reproduces them to a pixel |

Act 1's layout came from a supplied design file rather than from the frames, and
the two agree everywhere they can be compared — the mark at (67,64) 72×73 against
a measured 67–137 / 64–137, the rail glyphs and the mic landing on their measured
boxes to the pixel, and the design's own opacities checking out: `#F0F2F5` at 50%
over `#0A0A0A` at 35% predicts (122,123,124) for the **+** pill where the plate
reads (119,120,123). Its icon paths are used directly, in page coordinates, so
each `viewBox` *is* the measurement.

| Quantity | Method | Result |
|---|---|---|
| The box | Threshold and take runs on the ring | **1067.86×300.24** at (426.01, 389.58), radius **57**; face `#0A0A0A` at 35%, ring 2px |
| Footage behind it | Plate loaded, exported frames | The piece composites over footage the same way the search one does — **60%** of act 1's frame is plate (the 30% scrim is over it), 0% of act 2's, where the answer page covers it, and **90%** of act 3's. The `<video>`/`<img>` live in the other piece's stage, which stays in the layout as a plate holder rather than being duplicated |
| Two box looks | The supplied `Seach Query Box_Dark Blur.svg` and `..._White.svg` | The geometry is the same in both — 1067.86×300.24 at (426.02,389.58) — so only the skin changes. **Dark blur** is `#0A0A0A` at 35% with white type and a send that starts white; **white** is an opaque white box with black type, a dark mic, and a send that is `#346BF1` from the first frame, because a white pill on a white box is invisible and both the file and the clip show it already blue. A **Box** control switches them. **The radius is shared, at the dark file's 57**, by request — the white file draws its own on 69 (two stacked rects, rx 72.53 and 69.03), which the white look used to carry. One radius means the Box control changes the skin and nothing else, and it puts the halo's inner rect — a fixed 57 — back in agreement with the shape it is cut against. Fitted off an export of the white look, `r = (dx+dy) + √(2·dx·dy)` on seven rows down the top-left arc: 57.30, 56.29, 57.36, 58.00, 57.98, 57.44, 56.59, mean **57.28** |
| The backdrop blur | Its own control | The design's 10px backdrop blur is the expensive part of the look and is now a separate switch rather than riding on the scrim |
| The glow | `PromptBox_20260819.mp4`, profile out from the box edge | Reaches **38–53px** on the four sides, **18–29** at 20px out and **4–7** at 60. The build read 43–45 / 25–26 / 2 at the fitted `.65` — already tuned to this look against the other clip. **It now runs at full opacity by request**, which is the design file's own number for the brighter of the two glow layers it stacks (a 50-blur one at .5 on the box's rect, a 37-blur one at 1 on a shorter 1070×249). The single fitted layer takes the 1, so the profile is half again as bright — 67–69 / 39–41 / 4 — and sits above the clip's measured band. The face is untouched: `#0A0A0A` at **.35** is already the file's `fill-opacity`, verified on the computed style at every act-1 frame. Act 1's frame means move 4.7 → 5.1/5.7/6.0 against the plate's 5.0/5.2/5.5, and the whole-piece rms 1.96 → **1.92**. Back: `.65` on `.nglow` and `0.65 * ring` in `render2` |
| The scrim | Empty background, plate vs build | The design puts a 30% `#0A0A0A` wash with a 10px backdrop blur under everything. The plate's empty background is a flat **(0,0,0)**, and carrying the scrim regardless put act 1 at 8.1 against its 5.5 — so it rides the footage, which is the only thing it has work to do over |
| The wheel's shape | Ring colour at 124 points around the perimeter | Not a screen-space sweep. Drawn on a **square** and squashed, so the whole top edge is one blue while the entire spectrum crowds along the bottom, and it runs **anticlockwise**. Squash fitted at **0.436** — the design file's transform implies the box's own 0.281, at which the hues land ~120px left of the plate's |
| The wheel's colours | 17,672 ring samples across all 47 frames, mapped through that squash and phase and taken as a median per degree | All 360° covered, and not what the design file says. Its blue is a saturated `#3186FF`; the video's is **(63,131,229)** over most of the wheel. Its teal at 260–270° crosses straight back to blue; the video's is wider and runs to **(14,169,167)**. Reduced to **25 stops** the measured curve is reproduced to 6.8 per channel, and the top edge then reads (63,131,230) against the plate's (60,131,231) where the file's stops gave (49,134,255) |
| The wheel's phase | Same, frame by frame | `from` = **43.99 − 1.149·f**, to 1.15° rms across all 47 frames of the act |
| Typing | Caret's right edge, frame to frame | Frames **3→34**; caret 3.4×32 at the text's ascender |
| Prompt type | x-height on the settled line | 23px x-height → **44px**, pure white, starting x=473 |
| Context above the box | Row bands and x-height, then the supplied `Common Confusion….svg` | Two lines of the previous turn, **37px** from x=258, on a pitch the plate measures at 48 and which now runs **1.4** by request — 51.8 at this size, so each row sits 3.8 further from the one below it. Written as the ratio rather than the product, since the ratio is what was asked for and it survives a change of size. **Anchored by its bottom edge** so a longer turn grows up and out of frame rather than down into the box, and that bottom is now **183** — 18 lower than the plate's 165, by request. The action sheet hangs off the same pair of custom properties, `ctx-bot + ctx-gap`, so the **55px** under it is fixed however long the line runs: nothing in act 1 carries an absolute y for either any more. Verified in an export at two lines and at four — bottom 183 and gap 55 in both, with the fourth line at y=−9, out of frame. The ink is the design file's, reduced to what survives a **white** line with a **60%** ceiling: its fill runs (619.343,249.316) → (611.843,−114.184) over a 1433×138.4 block — white@50% then `#666666`@50% at 62.706% along — which resolves to 180.6 ink at the bottom row and 102 at 117.04 up, a ratio of **.565**. That ratio is the ramp, which then **stops dead at 155.40 — three rows, 3 × 51.8** — so a fourth line and anything above it is not drawn, by request. A hard edge rather than a fade, since hiding is what was asked for, and it costs nothing below it: measured at four lines, row 3's ink tops out 147 up from the bottom and row 4's begins at 162, so the cut sits in the 15px gap between them with 8px of clearance either side. No count-based rule was needed — the ramp is px from the bottom and the block hangs off the bottom, so a cut at three rows never reaches a block that has three or fewer. Verified in an export: 2 laid-out lines draw 2 bands, 3 draw 3, and **4 and 6 both draw the same 3**, topmost ink at y≈35 against a cut at y=27.6. The file's **layer blur** is declared at `stdDeviation="0"`, and it is asked for here and **heavier toward the top**. A CSS blur is uniform and the amounts are specified **per row** — **0.5px** on the bottom, **1px** on the second, **2px** on the third, **3px** on a fourth — so the line is drawn once per row and each copy masked to its own band. Bands rather than a crossfade: being disjoint they simply sum to the fill, with no correction for layers compositing as `1−(1−a)(1−b)`. The band edges go where consecutive rows' **blurred reaches** part, which is inside the gaps between them: the rows ink at 7–42, 58–94, 110–147 and 162–198 up from the bottom, reaching 5.5–43.5, 55–97, 104–153 and 153–207 at three sigma, so the edges sit at 73.25, 124.5 and 177 in the box's coordinates, each band carrying the fill's value across it (1.0, .81695, .62647, .565 from the knee). At these amounts the reaches separate cleanly — at 4px they did not, rows 3 and 4 meeting exactly at 153, which is why an edge there could clip one or admit the other. **The copy is trimmed to three rows before it is set**, not masked — a masked fourth row is still drawn and still blurred, and at 4px its ink reaches 12px below its own box, which surfaced as a sliver at y18–24 on a six-row turn; nor is there an edge that fixes it, since at 4px row 3 reaches up to 159 and row 4 down to 150. **And the whole thing sits in 24px of padding, which is what the visible limit was**: a mask ends at its element's box and the box was exactly the text, so blur spilling off the first character was chopped at x=258 — measured across it, 0 at 257 and **6.83 at 258**, a straight vertical line down the left of the block. It now ramps 0, 0.2, 1.08, 2.48, 4.67, 20.72 across 250→260. The padding is given back through `left`, `width` and `bottom` so the type has not moved, and every mask stop is quoted 24 higher. Verified in an export at four lengths: 2 rows draw 2 bands, and 3, 4 and 6 all draw 3, with spreads **1.31 / 2.01 / 2.28** against an unblurred reference's 1.33 — monotonic, the bottom row all but sharp at 0.5px — and peaks **149 / 108 / 64** |
| Send button | Fill colour sampled on the button | Pure white through f39, then a straight three-frame ramp — **.33, .67, 1.00** on f40, f41, f42 — to the design's `#346BF1`. The press after it shows as the pill's left edge coming in 2, 6, 7, 4px over f43–46, a scale easing to **0.887** on f45 and back |
| Halo | Profile out from the box edge | Reaches **57–60px** on every side: 40 at 2px out, 35 at 10, 22 at 30. Cut off at the box's own edge so none of it washes into the face, which is why the plate reads pure black inside |
| Flash | Frame means, inverted through this build's own opacity-to-mean response | Plate reads 5.3, 25.9, 102.2, 175.5, 250.3 over f48–52, so the card has to sit at .094, .430, .716, .984. A straight ramp over **48.75…51.75** reproduces them to 5.4 rms — a ramp running the full four frames to 52 gives 7.1 |
| The rail glyphs | The supplied `icon.svg` and `edit_square.svg` | Used as-is in both acts, at the boxes the plate measures — 36×32 at (84,292/293) and 39×39 at (84,402/403), which is what they are drawn at. Their own `#56595E` is act 2's measured rail colour to three levels ((86,89,94) against (85,88,91)), so on the answer page the file's fill is what is used; over the dark ground act 1 wears white at 60%, which is what the plate reads there |
| Both glows had a visible edge | Profiles out from the box, and out from the lit phrase | **Both were masks ending where their element did**, which is a cut, not a falloff — and full opacity made them plainer. The box's halo lived in a 70px ring around a `blur(34px)`: out from the edge the level ran 8.7, 5.7, 3.7, 2.0 and then a flat **0 from 71px**, up, left and along the corner diagonal alike. Sigma 34 carries to about 3σ = 102, so the ring is now **140** and the glow reaches nothing on its own — 8.7, 4.3, 1.7, 0.3, 0. Act 3's phrase was cut by its own line box: below the lit rows the halo read 2.29, 2.19, 2.14 and then **0.38, 0, 0** at 17px out. Its widest shadow is `0 0 88px`, and a text-shadow's blur radius is two sigma, so that carries to ~132: **140px of vertical padding**, cancelled by a negative margin so the wall still wraps to identical lines. The largest step anywhere in 130px is now 1.14. Sideways it stays at 70 — nothing was clipping there, and the figure is not free to change, because the hue handover is a `90deg` gradient in *percent*: at 140 each side the far hue began fading in 15px into the phrase instead of 74 |
| The + button, the mic, the query and the action sheet | `Add.svg`, and the design's own grouping | **By request.** The + is `Add.svg` as drawn — a 94.2012×70.6509 pill on a 35.3254 radius in `#F0F2F5` with the file's own path over it in `#0A0A0A`, kept in the file's coordinates with the `viewBox` set to the pill's rect, the same way the mic and rail glyphs are carried. Its 50% now sits on the **whole button** rather than on the pill's fill, which is how `box_dark.svg` groups it — `<g opacity="0.5">` around both — so the + dims with its pill. This also **fixed a real bug**: the morph writes an inline opacity onto the +, the mic and the send every frame, and it wrote a flat `1`, so the mic had been rendering opaque against a stylesheet that said `.5` since it was written. It multiplies the resting value now. The query sits **7px lower** (top 39, not the file's 32) and the action sheet 7px lower with it (238 / 240 / 243 / 247); those icons were already the 60% white asked for |
| Act-2 page | Edge/run detection on f70 | Mark **72px** at (66,65); nav ink band y 87–121 with items at 242, 483, 585, 761, 933, 1150 and carets at 401, 1253; rule at **207**; chip **711×99** at (969,291), text inset 45; body from x=241 on a **51px** pitch; rail glyphs at y 293–324 and 403–441 |
| Both shapes follow the prompt's length | The bubble's right edge across two sources; every inset on the box | **By request.** The bubble hugs its text and is pinned by its **right** edge, the same rule the search piece's uses: `AIM Chat_White.svg` draws it 861…1680 for its own string and the plate 969…1680 for this one — two lengths, one edge, 240 in from the frame's. It grows leftward to at most **1439**, where it meets the answer column at 241, and a row is 99: the plate's height, and 24 of padding either side of the body's own 51px line. Extra rows push the answer down by 51 each. Its corners are the design file's path — **49.5 / 10 / 60 / 49.5**, squaring the one nearest the sender — where a plain 45 pill had been assumed. The prompt box keeps every inset it is drawn with (text 32 down, controls ~30 up, 114 of air between) so a second row makes it one line taller, growing about the frame's centre because that is where it sits to within a third of a pixel. And the bubble takes the **box's** line breaks, not its own width: the box is this piece's field, so its two rows become the bubble's two rows instead of the text reflowing partway through the morph. The panel's prompt field is then sized to agree with both — same typeface, so matching the width in **ems** matches the break positions, and 960/44 is 21.818em, an **11.05px** field at the panel's 241px. Field, box and bubble break identically on all 50 prefixes of a 48-word prompt |
| Act-2 weights | Stem widths on the x-height | 3px through the first paragraph's opening, **4px** from the claim to the end of that paragraph, and 4px on the two quoted names — so the emphasis is a real weight change, not a colour one |
| Act-2 trailing line | Darkest pixels per paragraph | The last line is `(154,154,154)` where the paragraphs above it read `0` — it is greyed and still arriving |
| Act-3 type | x-height and ascender-to-baseline on the lit line | x-height **82px**, ascender-to-baseline **120px** → **156px** type; the four visible rows sit **207px** apart → 1.33 leading |
| Act-3 weight | Stem widths across the lit line's x-height | **17px** at 156px type — the 500 the page sets the phrase in, not the 400 around it. At 400 the phrase's ink came out a fifth short |
| Act-3 wall | Edge rise on a stem, and banded coverage | The body is thrown out of focus — a stem rises over **55px** there against the lit line's 13. 24.1% of the frame carries wall at a mean of 24.1. **The unlit copy is white ink at 35% under an 8px blur**, by request, where it was a flat opaque `#252525` under 15. Both numbers matter together, which is why one alone was not enough: a 15px blur spreads a 156px glyph's ink far enough that its core never reaches the alpha it was given — at .35 the exported matte peaks at **55 against a nominal 89**, so the wall drew at 62% of its setting whatever the alpha said. Halving the blur takes that peak to **76, 85% of nominal**, and the copy reads. Total ink is unchanged either way: the matte's mean alpha is 14.2 at every blur from 4 to 15, because a blur redistributes rather than removes. The cost is act 3's plate match, and it is the one place in the piece where a request is paid for in rms: those frames go 16.00 / 20.46 / 16.65 / 20.05 / 19.57 on f87/95/124/160/192 against the plate's 15.6 / 16.0 / 14.5 / 14.0 / 14.5, so the two that used to read dim now land and the three settled ones run 4–6 high. **Whole-piece rms 1.92 → 2.75.** Back: `rgba(255,255,255,.145)` with `blur(15px)`, which is the measured pair, or `#252525` for the flat grey |
| Act-3 swap | The lit core's centre, frame by frame | 14, 48, 120, 297 … 1498, 1617, 1681, 1718, 1739, **1749** — nearly flat for six frames, then almost the whole travel inside four. A **tanh centred on f124** fits it to 36px rms, 2% of the travel; an ease-in-out is out by ten times as much |
| Act-3 handover | Lit pixels and frame mean through the swap | The plate never fades the phrase out: on f124 it still carries 5.4% of the frame at a mean of 119, peaking 192. It **smears** — the camera is doing 350px in that frame |
| Act-3 wall grid | Row bands across the whole act | Identical on every frame — 37–152, 219–385, 418–598, 667–797. **Zero vertical movement**, so the swap has to be a purely horizontal move |
| Glow | Halo hue at the phrase's near end on eight frames | 29° at f94, 2 at f104, 227 at f114, 188 at f140, 149 at f150, 65 at f160, 44 at f170, 271 at f190 — a constant **4.70°/frame decreasing through 75° at f160**, to 29° rms. The far end runs **83°** ahead of the near end. The letters themselves are white all along `(251,254,253)`; only the halo turns |

**How closely it lands.** Comparing frame means against the plate on 29 frames spanning all 192:
**1.55 rms**, every frame inside ±3.2 but for the first act-3 frame (−4.2) and the one the phrase
swaps on (−3.7). Run against the *decoded 1920×1080 MP4* rather than the preview it is **2.02**
over fourteen frames including both joins — 192 frames in the file, frame for frame with the
plate, decoding without error.

Export it at **23.976 · source** to get that. Both plates are 23.976, so choosing 24 resamples:
193 frames land on a 192-frame piece and the drift reaches a whole frame by the end, which is
invisible on the held stretches and obvious on the two joins.

### How act 3 is drawn

The lit phrase sits **inline in the wall's own paragraph** — the plate lights it in place rather
than pulling it onto a caption line — which means the page has to be drawn four times over at
identical metrics under one shared transform:

1. `.n3wall` — the copy, dim and blurred, the whole wall
2. `.n3tip` — the glow at the near hue, masked to fade out across the phrase
3. `.n3lit` — the glow at the far hue, masked complementarily to fade in
4. `.n3ink` — the white letters, unmasked

The two glow layers carry no ink at all, because a transparent glyph still casts its shadow.
That separation is the whole trick: masking a layer that also held the letters faded the letters
with it, and the phrase's bright core came out a fifth short of the plate's.

The camera is aimed by asking the layout where each phrase ended up (`n3Aim`), so editing the
copy, the phrase or the wall's size re-aims it instead of desynchronising a baked translate. The
wall's width is what decides whether the two phrases share a row — they must, or the swap tilts —
and the panel says so when they do not.

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

## The MOV's alpha is premultiplied

`prPlanes` multiplies each channel by its alpha before packing the planes, and
that is deliberate. Straight and premultiplied hold the same bytes and mean two
different pictures: a reader expecting premultiplied and handed straight data
*adds* the stored colour where it should scale it, so everything semi-transparent
blooms. Measured on this piece's glow at f160 — stored straight, its partial
pixels average RGB (212,253,226) at alpha 0.143 and 99.9% break the invariant
`RGB <= alpha*255`; premultiplied they average (16,22,18) and none do.

It also removes the canvas's own noise. A canvas stores premultiplied and divides
on the way out, so at low alpha it hands back the division's rounding error —
which the encoder was faithfully spending bits on. One slice of frame 1 used to
overrun its declared size on that garbage (`ac tex damaged 2050, 2048`); the same
export now decodes without a warning.

Composited over black — which for premultiplied data is just the stored RGB —
the file reads **1.41 rms** against the plate.

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

No licence is granted for the code — all rights reserved.

The assets are a separate matter and are not mine either way: Google Sans Flex is under the SIL
Open Font License and the Google marks belong to Google. **`NOTICE.md` has the details**, and its
terms still apply — and the source advertisement is deliberately not in this repository.

## Where it falls short

- **Sub-pixel glyph placement.** Chrome lays the string out ~16 px wider across 1742 px than the
  font's own metrics predict, so individual glyphs sit within a pixel or two of the source
  rather than exactly on it. The metric is sensitive to that in a way the eye is not.
- **The two low minima (0.033 and 0.152) are frames 136 and 137** — the blown-out ones. Both the
  source and the recreation are ~99 % white there, so the metric has almost no ink to compare
  and swings wildly. That is measurement noise, not a visible mismatch.
- **The cut is the weakest section.** Four heavily-smeared frames, fitted from three data points.
  It reads correctly at speed but will not survive a freeze-frame.

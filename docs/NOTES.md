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
- **A global set in one code path is stale in the other.** `BG_OP` — the plate's
  opacity, which the search piece fades at the click — was written only inside
  that piece's `render`. The prompt piece returns before it, so scrubbing the
  search piece past its click and then switching left `BG_OP` at 0 and the
  footage vanished from the second piece entirely. It reads as "footage does not
  work here" and it is really "the other piece turned it off". Anything shared
  between two render paths has to be written by both.
- **A child cannot outrank its parent's stacking context.** The prompt box has to
  sit above the white wash while the rest of act 1 sits below it. Giving `#n1` a
  z-index so it could go under, and the box inside it a higher one so it could go
  over, does nothing: the z-index on `#n1` makes it a stacking context, and every
  descendant is then confined to it. The symptom was subtle — the box rendered,
  but its black text came out at exactly 85, which is the wash's own value over
  black, and it took reading a serialised frame that was *correct* to notice the
  compositing was not. The box had to become a sibling.
- **A whole-frame mean cannot separate two things happening at once.** Fitting the
  act-1 flash against frame means gave a ramp over 48.72..52.06. Measured on the
  background alone it is exactly 49..52 — the mean was also carrying the box's
  face lifting on f49, and the box is 15.5% of the frame, which is the whole of
  that frame's rise. Measure the thing, not the frame it is in.
- **An epsilon is not zero.** `f = T * FPS + 1e-6` makes the first frame test
  `f > 48` true at f=48, which flipped the query's ink to black a frame early —
  against a face that was still black. Gate on the quantity that matters (here,
  whether the face is light enough to carry dark text) rather than on a raw
  frame comparison that an epsilon can tip.
- **A nearest-colour lookup cannot locate a flat.** Fitting act 1's wheel by
  inverting ring pixels back to a position on the gradient gave 1.773 deg/frame
  with a 3.6 deg residual — because blue occupies stops 298.8..360 and 0..122.4,
  half the wheel at one colour, so every blue sample answered with an arbitrary
  point inside that flat. Restricted to the purple-to-teal arc the same fit
  landed at 0.869 with 0.63 residual. The two disagree by 40 deg by mid-act.
  Fit only where the signal can actually distinguish positions.
- **A design file's stated geometry is not the rendered geometry.** The supplied
  file's transform implies its angular gradient is squashed by the box's own
  aspect, 0.281. Built that way, the hues land about 120px left of the plate's
  along the bottom edge. Fitting squash and phase together against colours at
  124 points around the perimeter picks 0.436. Take a design file's *layout* —
  it agreed with the plate to the pixel on every box, glyph and opacity — and
  still measure anything it only implies.
- **A transparent glyph still casts its text-shadow.** Setting the act-3 glow on the *page*
  element rather than on each phrase lit the entire wall — every one of its transparent
  letters cast the coloured shadow. Frame means went from 16 to 59. The shadow belongs on the
  span that is meant to glow, never on a transparent container above it.
- **Masking a layer masks its ink as well as its glow.** The act-3 phrase's two hues are
  crossfaded with complementary masks; while the letters lived on those same layers, they were
  faded too, and the phrase's bright core measured 2.29% of the frame against the plate's 2.90%.
  The letters need an unmasked layer of their own.
- **A threshold can hide a whole mechanism.** Scoring the act-3 swap on pixels above 200 said
  the plate went completely dark on f124 — so the first build faded the phrase out and back. It
  does not: on that frame it still carries 5.4% of the frame at a mean of 119, peaking 192. It is
  *smeared*, not faded. The frame mean, which cannot be thresholded away, said 14.5 where the
  fade gave 4.2, and that gap is what exposed it.
- **A `filter: url(#id)` only resolves if its `<defs>` travel with the serialised stage.** The
  swap's smear filter lives inside `#stage2` for exactly that reason.
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
- **The ZIP is stored, not deflated, and the size field is written after the fact.** PNG is
  already deflated so re-compressing buys about a percent for the cost of the whole sequence in
  time. The one thing easy to get wrong is the end-of-central-directory record: it reports the
  directory's size, so that has to be measured BEFORE the record starts being written, or the
  bytes of the record itself land in the number. `crc32` is worth checking against the standard
  value rather than eyeballing — "123456789" must come out `cbf43926` — and the archive itself
  against a real `unzip -t` rather than against the browser, which will open almost anything.
- **One-bit alpha is not the problem; putting the cut at half is.** A GIF has one transparent
  index, so the instinct is to threshold at half covered — and that is exactly what loses this
  piece's search bar, whose scrim is alpha 51 of 255. Put the cut at *was anything drawn here*
  (8 of 255) and composite everything above it onto a matte, folding its alpha into its colour,
  and the bar comes back as a matted band while the background stays a real hole. Measured: the
  source PNGs are 82.4% clear and 13.7% partly covered, and the GIF lands at 71.5% clear and
  28.5% drawn — the 13.7% matted rather than dropped. The matte is a real choice, not a default
  to hide: it is baked in, so the GIF only sits correctly on a background near it.
- **A swap variable called `t` inside a loop that reads `t` from the enclosing scope is a
  temporal dead zone, not a shadow you get away with.** `const t = cur; cur = nxt; nxt = t;` at
  the bottom of the row loop made every earlier read of the outer `t` — the transparent index —
  throw "Cannot access 't' before initialization", from the top of the same block. The failure
  surfaced as the whole import failing, several steps from the line at fault.
- **Two ways a median cut quietly collapses, both found by counting the entries a frame used.**
  Weighting the choice of which box to split by `population x width` is the obvious improvement
  and it is wrong on content with a dominant flat colour: this piece is mostly one white, so that
  box wins every round and the palette fills with 256 shades of it — measured, TWO entries in a
  whole frame and a worst-case error of 255. Split the widest box instead and let population
  decide only where the cut falls. Then the cut itself: when one bin holds more than half the
  pixels the median lands on it, and if it also sorts last the right-hand box comes out EMPTY,
  can never split again, and every later round produces another empty — one real entry and 255 of
  `[0,0,0]`, which looks identical to the first bug from the outside. Clamp the cut so both sides
  keep something. The tell for both is `new Set(idx).size` on one frame: it should be in the
  hundreds, and it was 2.
- **Mean per-pixel error is the wrong way to judge a dither, and it will talk you out of one.**
  Floyd-Steinberg made the piece's per-pixel error WORSE, 0.62 to 0.85, because it is deliberately
  putting the wrong colour next to the wrong colour so the average comes out right. Integrated
  over 4x4 blocks — the same reasoning as scoring after a blur — it goes 0.131 to 0.047 on the
  piece and 2.368 to 0.312 on a gradient. Measure what the eye does, not what the pixel does.
- **The GIF export is a different document.** It serialises `#stage` into a
  foreignObject inside a plain `<div>`, so any rule hung on `body` — or on
  anything outside `#stage` — silently does not apply. `font-family` lived on
  `body`, so every exported frame fell through the stack to `sans-serif` and
  set the query ~5% wide while the preview was perfect. Keep what the stage
  needs on `#stage` or below. Worth checking against the live DOM rather than
  by eye: rasterise a frame and compare an ink extent.

## Removed: the GIF option panel, and the PNG sequence → GIF importer

Two features, taken out by request, neither lost. What follows is enough to put
either back without rediscovering anything.

### The GIF option panel

Never landed on `main`. It lives on the branch **`gif-photoshop-controls`**, two
commits: `5b3e3e2` put the first controls on the importer, `b4b90e9` built them
out to what Photoshop's Save For Web offers and made ONE panel group that both
the piece's GIF export and the importer read through a `gifOpts()` reader.

    Colour reduction  Selective / Perceptual / Adaptive
    Colours           256 / 128 / 64 / 32 / 16
    Dither            None / Diffusion / Pattern / Noise, with a percentage
    Transparency      a threshold, with a white or black matte
    Looping           forever / once / 3x / 10x
    Lossy             0 / 20 / 50 / 80
    Interlaced        on / off

The parts worth not re-deriving:

- **Selective** gives a box the exact colour of its most populous bin rather
  than the box's weighted mean. A flat area is one bin, so its entry is exactly
  right and the area does not shift — which is the whole of why type and line
  art look sharp. Measured, pixels reproduced exactly: 96.1% at 256 colours,
  94.8% at 64, 93.7% at 16, against 92.8% and 88.9% for the mean at the lower
  two. **Perceptual** picks the box to split on a 3/6/1-weighted extent rather
  than a raw one. **Restrictive** was deliberately not built: a fixed 216-colour
  cube would only throw colour away now.
- **Pattern** dither uses a fixed 8x8 Bayer matrix, which is stable frame to
  frame and so does not crawl on an animation the way diffusion can. Pattern and
  noise perturb flat colour too, which is why None was the default.
- **Lossy** lets a pixel keep the previous index when that is nearly as good,
  lengthening the LZW runs. It was calibrated wrong first: nine times the
  squared error let a pixel land 47 levels out — 18% of the frame still exact,
  mean error 21.7 — to take 3% off the file. Rescaled to `l*l/6.4`, so the
  number reads as levels of error, it does almost nothing on flat art (0.9% at
  lossy 80) and a great deal on dithered gradients (13.3% at lossy 20 with **no**
  measurable error change, 41.6% at 80). Both numbers matter: without the second
  the control looks pointless, without the first it looks free.
- Interlacing is four passes over the rows — every 8th from 0, every 8th from 4,
  every 4th from 2, every 2nd from 1 — plus 0x40 in the image descriptor.
- The loop count is the two bytes after `NETSCAPE2.0`, 0 being forever.

### The PNG sequence → GIF importer

Taken out by request. It is not lost — the code is reachable in the history and
the machinery it leaned on is all still here — so this is what it was and how to
put it back.

**Where it lives.** `cb127c8` added it alongside the PNG sequence export;
`3bb9215` gave it the matte. Two later commits, `d6d8c05` (its own frame rate)
and `447913a` (the 50% alpha cut), were reverted before it was removed, so they
are reachable too but were not part of the state it was in. `git show cb127c8`
and `git show 3bb9215` are the whole of it.

**What it was.** A `<select id="pmatte">` and an `<input id="pin" type="file"
accept="image/png" multiple>` under the export buttons, with a `#pstat` line, and
one `change` handler. The handler:

1. filtered to `.png` and sorted by name with `localeCompare(..., {numeric:true})`,
   so `frame_2` precedes `frame_10`;
2. decoded each with `createImageBitmap`, took the first bitmap's size as the
   GIF's and counted any that differed;
3. composited each frame onto the matte in a `read(bitmap)` helper — clear the
   canvas, draw, then walk the RGBA blending anything under 255 alpha toward the
   matte colour while LEAVING the original alpha in place, so the writer could
   still tell a hole from a matted pixel;
4. ran the two passes the piece's own GIF export runs: every frame into a `Hist`,
   then `paletteOf`, then a `GifWriter` frame per bitmap;
5. reported frames, size, the rate the GIF could actually hold, the palette size
   and the clear/matted split, then cleared `$pin.value` in a `finally`.

**What it needed that is still here.** `Hist` / `paletteOf` / `nearestIn`, the
`GifWriter` with its Floyd-Steinberg dither, `lzwInto`, `Sink`, and
`GIF_ALPHA_CUT`. `GifWriter` still takes a `trans` index and still writes the
transparent GCE — nothing calls it with one now, and that is the only dead
capability the removal left. Rebuilding the importer needs no new machinery,
only the handler and its two controls.

**The one thing to decide again on the way back.** Where the see-through half
goes. `GIF_ALPHA_CUT` at 8 keeps the bar's scrim by painting it onto the matte —
71.5% clear, 28.5% drawn, the bar a solid slab. At 128 it goes to the hole and
only what was opaque survives — 94% clear, 6% drawn, the gradient still reading
at 5.5% of the frame. Both were asked for, a month apart in the same afternoon.

## Open decisions

Departures from the plate that were deliberate, and the one-line way back.

**Prompt / response:**

| | |
|---|---|
| Wheel squash `0.436` | Fitted against the plate, not taken from the design file, which implies 0.281. Back: `scale(-1,0.281159)` on `.nring i,.nglow i`. |
| The scrim rides the footage | The design has a flat 30% `#0A0A0A` wash over the whole frame. It is only drawn when footage is loaded, because over nothing it lifts every pixel by 3 and the plate's empty background is (0,0,0). Back: drop the `bgOn` test on `nscrim`. |
| Halo opacity `.65`, blur 34 | The design says a 22px blur at full strength. That reached only 38px against the plate's 57 and ran the near field 16 over. These two reproduce the measured profile instead. Back: opacity 1, blur 22. |
| Caret 32px tall | The design draws it 40.1. The plate renders it 32, matching the text's ascender-to-baseline, and that is what is built. |
| Act 2's exit is a smear plus a fade | The plate's page is genuinely leaving, not only spreading, and no amount of blur alone reaches its 1st-percentile luminance. The split between the two is fitted, not measured separately. Back: nothing to restore — but if the page should only smear, drop the `0.75 * rush * rush` term and expect the frame to stay ~35 too dark at f86. |
| Act 2's chrome fades on a plain ramp | Measured, its rule goes in one frame, its nav in two and its mark by f84 — three different times. This uses a single 79→83 fade over all of it, which lands the nav and mark right and takes the rule out a frame or two late. |
| Act 3's arrival smear ÷8 | The settle's own velocity is 138px on the first frame, and feeding that straight in over-blurs the frame to a mean of 11.6 against the plate's 15.6. The divisor is by eye against the plate's own legibility on f87. |
| Wall width `4900px` | Not measurable from the plate — only its consequences are. This is the width that puts both lit phrases on one row 1693px apart (the plate's own rest positions measure ~1722), lands 25.5% of the frame carrying wall against its 24.1%, and leaves ~950px of copy to the right of the second phrase so the block's edge never walks into frame. Changing the copy or the type size re-wraps it; the panel warns when the two phrases stop sharing a row. |
| Wall `#252525`, `blur(15px)` | Fitted to the banded coverage rather than sampled — the plate's wall is blurred past the point where a stem has a colour to read. Back: nothing to restore, but the pair is what sets act 3's floor. |
| Glow radii and alphas | Fitted so the frame mean lands on the plate's. The band split does not match: the plate has 2.9% of the frame above 150 and only **0.2%** between 90 and 150, where this has ~1.1% in that middle band. Its halo falls off faster than three stacked shadows can. Suspect the plate's own compression crushed the skirt; not resolved. |
| Emphasis derived from the lit phrase | Act 2 bolds from the first lit phrase to the end of its paragraph, so the plate's "because **it is** nearly unstoppable" starts one word earlier here — the quote is `it is nearly unstoppable`. Back: set the quote to `nearly unstoppable`. |
| Act-2 rail glyphs | Drawn to the measured boxes (x 84–119 / y 293–324 and x 84–122 / y 403–441), but the shapes are by eye — the plate's second glyph is a pencil in a square and this is a pencil over a rule. |
| Flash worst frame +8.5 | The ramp is linear over 48.75…51.75, fitted to 5.4 rms. The plate's own ramp decelerates slightly (steps of .336, .286, .268) and no linear fit catches all four frames; f51 is the one that pays. Back: an eased ramp would fix f51 and cost f49. |

**AI Mode search:**

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
| `CHIP_GAP_BG = 140` | Over footage only, against the measured 111. The bar is a scrim there and the chip only 75% opaque, so the two crowd each other at the plate's spacing. **By eye — no measurement behind it**; opened to 200, then pulled 30% back. It pushes the chip right, so the bar and pan grow with it, and the Medium query adds to that too: together they take the bar 2491 → 2577. The white card keeps the measured 111. Back: set it to 111.  It keys off the LOOK rather than the video now: the transparent mode wears the same scrim, query and chip, so it takes the same gap — both 140, both measuring 140.22 on screen, where before only footage did and the two modes were spaced differently while looking identical. |
| The camera is a bezier on the typing's progress | **The baked `PAN` curve no longer drives the camera at all.** The pan is a function of how far through the query the typing has got, not of the clock, so it re-times with the rate and lands exactly as the last character does. `CAM_BEZ` is the easing — the same four handles After Effects and CSS use, editable in the panel with a live curve, carried as `#bez=`; `CAM_SPEED` scales the progress so a faster camera finishes before the text does. Held until `CAM_START_S` (1.92s at 1x, stored as a fraction of the span) against the plate's own 51-frame hold. **The default is solved against the clip, not copied from the reference panel** — that panel reads 0.40, 0.00, 0.00, 1.00, which run here peaks at 109 px/frame, twice what the clip does; searching the handles for the clip's own profile lands on 0.35, 0.08, 0.35, 1.00, giving peak 52 at frame 67 against the measured 54 at 66. Progress runs on the typing schedule rather than the caret's measured x on purpose: reading the caret inherits the per-character steps and the pan comes out jagged, a 150 px/frame peak jumping 5, 64, 46, 27, 33, 5. `PAN`/`PAN_REF` are kept as the record and the way back. |
| The G's bar is 4.89% over the plate's, and its button with it | By request, and only while the bar carries the G — on the plus every number is the measured one again. One factor throughout, taken about the bar's own centre line so 537 stays 537: the bar 234 to 245.44, the button 455x158 to 477.25x165.73, and its radius, padding, gap, spark and label with it. Measured back off the rendered boxes, the six ratios come out 1.04889, 1.04890, 1.04892, 1.04890, 1.04877 and 1.04895. The button keeps its measured 1px offset below the bar's centre — 538 in both modes. What made this cheap is that the button's outline is an SVG with a viewBox INSIDE the button: its arc lengths are in viewBox units, so `RING_P` and the hues solved against that perimeter do not move, and scaling the SVG's CSS box scales the drawing. What is not CSS follows in `iconGeom`: `CAP_R`, `CHIP_W`, `CHIP_TO_CAP`, the beam's y extent, and the beam mask's y/height/rx, which are attributes rather than styles. Back: `iconGeom` returning the plate's values for both modes, or `BAR_G = 1`. |
| The G's margins are set by request, not measured, and all three differ | The mark runs 8.72% over the wide shot's 124.8 — 132.53 x 135.68, grown about its centre, holding the artwork's 250x256 aspect. Its margins are then specified rather than read, and each side has been asked for separately over three passes. Vertical 54.88, which is centring it in the 245.44 bar the G wears. Horizontal began at 19% over that, 65.31; the left is now that plus 2 at 67.31, and the right that times 1.167 and then 5% again at 80.03 — 1.2265 and 1.4583 of the vertical. Measured back off computed style: 54.880 top, 54.878 bottom, 67.310 left, 80.037 ink gap right. The plate uses none of it; its own left inset is 58.1 against 54.6 vertical, about 6% wider. The right-hand figure is the mark's own icon-to-text gap (`GMARK_TEXT_GAP`) replacing the 73.0 the plus still keeps, and it is an INK gap, so the text box starts 602.27 to put the 'h' — which bears 5.596 — 80.03 clear. What none of this touches is the text-to-chip gap, structurally: the chip hangs off wherever the text ends by `CHIP_GAP`, so moving the text moves the chip, measured 110.62 with either icon. Downstream the bar is 2559px and the pan 1651. Back: `left:386.1px` with `GMARK_RIGHT = 508.0` and `TEXT_LEFT_G` reading `ICON_TEXT_INK_GAP`. |
| The chip's label is Regular in every mode | It was Medium over footage and transparency, on the reasoning that the pill is only 75% opaque there and the label needed the weight to hold. Regular throughout by request — checked at 400 plain, over footage and over transparency. The query's own step up to Medium in those modes is unchanged. Back: `#stage.has-bg .aichip b, #stage.has-alpha .aichip b{font-weight:500}`. |
| The plate fades out at the click | By request. It holds to frame 127, where the press opens, then crosses to the background over exactly the frames the button spends being pressed and blowing up, landing on 136 — the frame act 1's own opacity reaches zero. Both ends are `PRESS_F0` and `SPLIT_FP`, constants the piece already had, so the fade cannot drift away from what it is timed against. Measured in exported pixels: a plate reading 38 red goes 38, 86, 133, 182, 222, 255 across 127 to 136. Two things this needed. `bgDrawInto` reads a `BG_OP` that `render` sets, rather than the element's own opacity, or the fade would have been a preview-only thing and the export would have cut hard. And `#stage.has-bg` had to become white rather than transparent, since a fading plate has to reveal the background and not the near-black page behind the stage — with `stageSVG` forcing it transparent for the serialise, the same way it hides the video and the still, because the export composites the footage UNDER the serialised stage. Back: `BG_OP = 1` unconditionally, and `#stage.has-bg{background:transparent}` with the serialiser hook dropped. |
| Act 2's white card waits for the chat wherever there is something behind | The card arrives with the cut on frame 132 and is opaque the instant it does. Against white that is invisible and right; against a matte or a plate it is not — it filled the frame six frames before any of the chat had drawn, taking a matte from 82% clear to 0% and burying a plate while the button was still opening. So over footage and over transparency it comes up on the answer body's own measured ramp instead, the first act-2 ink there is (the chip's is 5.672, the chrome's 5.756). The chat still ends on a fully white card, and the numbers say where: over a plate `--a2bg` runs 0 through frame 133, 0.181 on 136, 0.598 on 140, then a flat 1.000 from 144, with the exported corner reading 255,255,255. An earlier pass removed the card over footage entirely, which put the answer's dark ink on the plate — reverted, since only the OPENING wanted the plate showing. The plain card is untouched: `--a2bg` is never set there. Back: `if (alphaOn)` for the footage half of it. |
| The bubble's rows come from the query field | The plate never shows a wrapped query, so nothing about a second row comes off it. By request the bubble now takes the field's own line breaking: `fieldLines` mirrors the field — same font, same content width, same wrapping — and reads which line each character landed on, and act 2 draws those lines. So the field is a preview of the bubble and the row counts always agree. It cuts both ways, which is the thing to know: the field breaks at about 44 characters and the plate's query is 43, so the reference sits ONE character inside a single row, and anything that narrows the field — a classic scrollbar in the panel rather than an overlay one — would wrap the field and so wrap the bubble, moving the answer with it. That is the coupling behaving as asked, not a fault. A row is 54px, the measured 102 less 24 of padding either side, which is also the body's line-height ratio (1.414) at 38.22 to within 0.05. `max-width:1438` survives as a bound rather than a cap — the field's line length settles the width long before it. Verified in exported pixels: 43 and 95 characters both draw 854-1679 at 825 wide, 102 and 210 tall, the answer 54 lower per row. Back: hand `qq` the raw string instead of `fieldLines(str).join("\n")`. |
| The MOV's alpha is `a * 257`, not ffmpeg's | 8-bit alpha goes straight to 16, so opaque is exactly 65535. ffmpeg's own encoder goes through its 10-bit plane and stores 65343 — 99.71% opaque, which over a stack of layers is a real 0.75-of-255 error on something that should be solid. The cost, measured: read back *through ffmpeg* 127 of 256 alpha values come out 1 off, because ffmpeg divides by 65280 rather than 65535 on the way back. Every editor reads the 16-bit channel directly. Back: `(a << 2) << 6 | (a >> 2)`. |
| The GIF's transparency is a threshold at half | GIF has one all-or-nothing palette index, not a channel, so a partly covered pixel has to fall one side of a line. At 128 the query, the chip fill (75%) and the gradient survive and the bar's 30% scrim (76) does not — the bar reads as an outline. Lowering the line keeps the bar but paints a 30% wash as solid black, which is a bigger lie about the design than leaving it out; the MOV is the one that carries the real matte. Back: change the 128 in `GifWriter.prototype.frame`. |
| The GIF renders the piece twice | Its palette is sampled across the whole animation, so it cannot be settled until the last frame has been seen. Holding the frames to come back to is frames x W x H x 4 — 3.4 GB at 1920 and 60fps — so the largest combinations used to be refused outright. Time instead of memory: 1920 at 60fps is 406 frames, 812 renders, and it finishes. The sample stride is also chosen from the total now rather than fixed at every 23rd pixel, so the list the median cut runs on stays near 400k colours whatever the export. |
| The loop has no hold on its last frame | It used to pause there before looping — 0.9s on the whole piece, scaled to 15% of the span on a half — on the idea that an ending wants a beat to register. It does not: measured at 0.883s, 0.835s and 0.149s across the three settings it read as a stall, and it is gone. What survives from that code is the part that matters, which is that the clock still cannot run PAST the segment's end: the loop turns over on the frame after the last one, and that is what keeps the query half from playing the chat half. Verified over full loops of all three — no pause over 60ms anywhere, and the peak clock 6.753, 5.662 and 6.756 against ends of 6.757, 5.672 and 6.757. |
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

## Footage under the prompt piece

The `<video>` and `<img>` live inside the search piece's stage, and that stage
used to be `display:none` whenever the prompt piece was live — so the export
composited footage correctly (it draws the plate itself, under the serialised
stage) while the preview showed none of it. The stage now stays in the layout
with `.plate-only`, which hides everything in it but those two elements and
turns off its own white. It sits before `#stage2` in the markup, so the plate
lands under the second piece without any z-index, and one decoder serves both.

Measured with a plate loaded: the exported frame is 60% footage through act 1 —
the design's 30% scrim is over it — 0% through act 2, where the answer page's
white covers it, and 90% through act 3.

One thing to know when using it: act 3's wall is `#252525` at full alpha, so over
footage it reads as dark type that darkens the plate behind it rather than as
faint light type sitting on it. Expressing it as white at 14.5% is identical over
black — the frame means agree to 0.1 — and different over footage. That was built
and then reverted by request; it is `836728e` on `main` if it is wanted back.

## Known defect

**ProRes 4444 writes one damaged slice on frame 1.** Decoding a 480px alpha
export of the prompt piece, ffmpeg reports `ac tex damaged 2050, 2048` — one
slice's AC data overran its declared size by two bits — once across all 192
frames, on the first. The decoder recovers, all 192 frames come out and the
alpha is correct throughout, so the file is usable, but a slice size is being
written short somewhere in `proresFrame`. Only the one export was checked, so it
is not isolated to alpha or to that size.

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

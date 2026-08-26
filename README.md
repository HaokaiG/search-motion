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

**Live:** <https://haokaig.github.io/search-motion/> — the repository's own `index.html`, served by
GitHub Pages, so it is whatever is on `main`. Turning it on is one dropdown, once:
*Settings → Pages → Source: Deploy from a branch → `main` / `root` → Save*. Until that is done the
address 404s.

Locally, open `index.html` directly, or `python3 -m http.server` and visit it. The controls sit in a side
panel on the right — playback, query, answer, look, motion, footage, export — with the stage
centred in the space beside it. The panel lets you:

- **run the piece** — the transport is a glyph: **▮▮** while it runs, which freezes the frame you
  are looking at, footage and all, and **▶** while it is stopped, which picks up from there rather
  than starting over. Bars rather than a square because it holds its place — **Replay** is the one
  that goes back to the top. **Space** does the same as the button, except while the focus is in a
  field or on a control that wants the key itself. The clock only runs while the piece is playing,
  so a stopped frame costs nothing
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
- **set the AI Mode button's bubble opacity** — the PILL only, on its own drag bar from 0 to 1 with a field beside it. The label, the lens and the gradient halo are untouched at every setting, which is exactly why this drives the **fill's alpha** and not the element's opacity: `opacity` on `.aichip` would have faded all four together, since the other three are its children. Measured — the label's ink holds alpha **255** and the halo is identical (same opacity, same mask angle) at 1, 0.4 and 0. **It is a multiplier on the mode's own alpha, not an absolute one**, so 1.00 means *as measured* wherever you are: solid on white, 0.75 over footage, the plate's solid blue at the press. One absolute number could not be all three, and a control that quietly restated the measurement as its own default would have moved the piece the moment it appeared. **It applies in every mode, and LETS GO as the blue arrives** — the second half by request, reversing an earlier one that the setting reach the blue too. Its influence is lerped out on `litK`, so the pill carries the setting while it is pale and lands on the mode's own alpha once it is blue, whatever the slider says. Measured over a matte, the blue at f130 is **`rgb(59,107,225)` at alpha 0.800 for every setting** — 1, 0.6, 0.3 and 0 alike — while the rest state still responds, 0.8 / 0.561 / 0.380 / 0.200; on white the blue is **`rgb(62,115,240)` opaque** at all of them. It is a ramp rather than a switch so the hand-off happens with the fill instead of popping on the frame it starts. **This gives up the property that made the previous version safe**, and knowingly: with the setting below 1 the bubble now gains opacity across the press (0.380 -> 0.522 -> 0.800 at 0.3), which is precisely what "not impacted when blue" asks for. **The blue is still blended into the base colour rather than laid over it**, which remains load-bearing: two stacked translucent layers composite to a + b(1-a), so the alpha at any given `litK` is exactly one number rather than two compositing into a third. Isolated from the bar behind it the alpha is precisely what was asked — **1, 0.749, 0.502, 0.251, 0** — and with the bar's own scrim at 0.2 every reading matches A + 0.2(1-A) to the third decimal, which is the plate showing through, not drift. Fixed in passing: this rule still carried **#f5f6f8** while `--chip` had moved to the design file's **#f4f6f7**, so the pill was a shade off its own colour over footage and under a matte. `#bubble=` carries it
- **set the bar's scrim, or take it away** — over footage or under a matte the bar's face is a black plate, and LOOK now carries its opacity as a drag bar from 0 to 1 with a field beside it. **At 0 the plate is gone** and what is left is the gradient ring and the white query over the footage itself, which is the other half of what this control is for. Measured across the range, the glow is untouched by it — **~30,150 lit pixels at mean saturation 184.5 at every setting**, 0 through 0.5 — so this removes the plate without ever dimming the thing it sits behind. It does nothing in plain mode, where the face is the plate's own white, and the hint line says so rather than leaving a control that looks broken. The default is **read from `:root`** instead of being repeated in the script, so the measured 0.2 and the comment explaining where it came from stay in one place — moving the stylesheet's value moves the control's starting point, its reset and the hash's idea of what counts as default, all from the one edit. It is written to **`#stage`**, not to the document element, and that is load-bearing: the export serialises the style tag and the stage into a foreignObject, so a property set on `:root` at run time would be outside that subtree and the exported frame would quietly come out at the stylesheet's value while the preview showed something else. Verified on exported frames rather than assumed — the bar's face reads alpha **0 / 0.2 / 0.251 / 0.6 / 1.0** for scrim 0 / 0.2 / 0.25 / 0.6 / 1. `#scrim=` carries it
- **set the glow speed** — a slider from 0x to 4x under the other two, or type the number in for anything up to 20x, the two driving each other the same way. It scales the search bar's gradient — the opening sweep and the constant turn together — as a **time scale** rather than as a rate on one of them: `angle(k x t)`, so the opening and the turn keep the proportion they were measured in and only the clock changes. Verified as exactly that, not approximately — at every setting from 0.25x to 20x the mask and gradient angles match the closed form to within **0.005 deg**, and the opacity and blur match exactly. Expect less than the number says at the fast end: the opening rides cubic-bezier(0,0,0,1), so compressing its time moves you further along a curve whose slope is already falling, the same reason the earlier 1.1x change lifted the rate at a fixed frame by only about 5%. **0 freezes it**, which is the honest reading of a time scale — no time has passed, so the burst has not begun and the bar sits with its grey border on and no gradient at all. That is also why this is the one field of the three that guards on `isFinite` rather than `|| 1`: the falsy idiom cannot tell a typed 0 from a typo, and 0 is a real setting here. **The AI Mode button's halo is deliberately left out of it** — its turn is pinned to the press and the cut, so it cannot be sped up without either overshooting the cut or not finishing its turn, and its blur reads the plate's own progress so the button looks identical at every setting (measured byte-identical at 0.25x, 1x and 4x). Unlike the typing and camera speeds this one cannot change the piece's length — the burst runs 374.9 frames, far past act 1 — so it neither relayouts nor restarts the clock, which would otherwise fling the piece back to frame 0 on every tick of a drag. The panel reports the rate the turn settles to and the lap time it implies
- **shape the glow's opening, and fold either editor away** — the bar's gradient opens on a cubic bezier and that curve is now editable too, on its own chart under Glow speed, with the same four handles CSS and After Effects use. **Only the ANGLE reads it**: the burst's opacity and border tracks keep `CB_STD_DECEL`, because those are separate measured ramps and are not what "the glow's easing" means. **The default is LINEAR, `0,0,1,1`, by request** — it was the source's own standard-decelerate, `0,0,0,1`, and that is a real change to how the opening reads rather than a tidy-up. The old curve is violently front-loaded: measured across act 1 it ran **15.74 deg a frame at its peak down to 1.13 at its slowest**, a 13.9x spread, over 316.2 deg of travel. Linear turns at **1.324 deg a frame and never varies** — peak and slowest are the same number — for 190.7 deg of travel, so the glow covers **40% less ground** across the act and covers it evenly. That constant is the two halves added: the opening gives 290 deg over the burst's 374.9 frames, 0.7736 a frame, and the constant spin adds 0.5506, summing to 1.3241 against the 1.324 measured. It also makes two other dials behave — `BAR_BURST_MS` now means what it looks like it means, and Glow speed scales the opening in proportion instead of sliding along a curve whose slope was already falling. Still lit and turning on **every one of the 117 frames** the glow is up. At f70 the mask runs **-21.15 deg** here against **91.3** on the old curve and **-60.85** on a late-start, each matching the closed form exactly. The camera's chart **moved up under Camera speed**, where it belongs beside the control it shapes, and both are now **collapsible and both start closed** — with two 252px charts this was much the longest group in the panel, and the fold row is itself the label saying what is behind it. **The two now sit the same distance below their sliders**: Camera speed's fold row is 9px under its slider, and Glow speed's was 32px because the readout line sat between them with a full gap either side. The readout moved ABOVE its slider — it elaborates the number in the field it now sits under, and the fold below is the same 9px as the camera's, measured identical. One implementation serves both: the editor was written against the camera's canvas and `CAM_BEZ` directly, and two copies of a drag-and-hit-test editor is exactly the pair that drifts apart. `#gbez=` carries the glow's curve, `#bez=` still the camera's
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
- **prompt/highlight splits in two as well** — *Whole Piece*, *Prompt Only*, *Response Only*, its own select beside the search piece's rather than one that rewrites its wording, so each piece's halves are named after what is actually in them and the hidden one keeps its choice. **The seam is frame 49, asked for as "when the button click motion is finished"**, and three independent things put it there: the press's own arithmetic ends at `N2_PRESS` + 350ms = **48.994**, the button's measured `scaleX` is back to exactly **1.000 by 49** (1.0008 at 48.5), and 49 is `N2_FLASH0`, where the answer page starts washing in. Not a coincidence — the move is built to wait for the click, so the click's end IS the join. Quoted in the clock frames `segStart`/`segEnd` use rather than plate frames, which after the hold differ by `N2_HOLD`: `N2_SPLIT_SEG` = 50.3976 round-trips to plate frame **49.0000** exactly. The halves run **2.102s** and **5.964s** against the whole 8.066s, and the seam renders identically from both sides — button at rest, flash not started. **One thing this seam does not clear**: the energy blob runs 400ms against the press's 350 and is still at 0.199 on frame 49, gone by 50.5. Splitting there instead would clear it but start the response half **half-way through the flash** (0.5 by 50.5), which is the worse trade. Unlike the search piece this needs no class on the stage — `seg-query` exists there because act 2's card already bleeds through before that split, and here nothing of the response is drawn before the frame the flash starts on. The preview loops inside the chosen half and the exports walk it: 194 frames whole, **51** prompt, **144** response, the extra one being the fractional seam rounding up on both sides rather than a duplicated frame. **The prompt half holds its own look to the last frame.** The morph opens on 48 and that half's last exported frame lands on plate **48.60**, a fifth of the way in — measured there the box had already gone from `rgb(10,10,10)` at face 0.35 to **`rgb(99,99,101)` at 0.742**, with the glow down to 0.841 and the send to 0.699. One frame out of 51, and a loud one on a loop where every other frame is the settled look. `mt`, the move and the halo are held at rest for that half, so it stays dark — or white, whichever look is on: measured across all 51 frames it now has **one face colour and one opacity**, `rgb(10,10,10)` / 0.35 dark and `rgb(255,255,255)` / 1 white, and the exported pixels agree at `[3,3,3]` on the last three. The press is untouched, running off `N2_PRESS` on its own clock and finishing inside the half, and the whole piece and the response half still morph exactly as before — 10,10,10 -> 143 -> 211 -> 236 -> **240,241,244**, the chip's own colour
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
  swaps its white fill for a black scrim at `--bar-scrim` — 0.2, and a panel control now, so
  it runs from a full black plate down to none at all — the AI Mode chip's fill drops
  to 75% — a panel control now, from solid down to no pill at all — so the plate reads through
  it while its label and gradient outline stay fully opaque,
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
    6.8s piece at 1920 and 24fps. At the source rate the container declares **24000/1001**, not 90000 over 23.976 —
    that rounds to a delta of 3754 and would write 23.9744fps into the file. Every other
    rate on offer divides 90000 exactly.
    Verified by decoding the export back with ffmpeg — RGB matches
    the canvas to within the 1 code the sRGB → BT.709 video-range round trip costs, and the alpha
    exactly — and then again through macOS's own AVFoundation, which is the stricter reader of
    the two and the one an editor here would use
  - the **GIF** caps at **20fps**, and the higher rates resample to it rather than being stamped
    at the rate you asked for. A GIF's delay is in whole centiseconds, so 24fps is written as
    4,4,5,4… — correct on paper, and the file does declare 23.99fps — but a decoder that rounds
    anything under 5cs up to 10cs turns those 4s into 10s, and the result plays at 10.9fps:
    **slower than the 12fps export**, whose 8s and 9s clear the floor untouched. That is why the
    trouble began exactly above 12. Capped, the delay is a flat 5cs and the motion runs at the
    speed asked for on any viewer; the status line reports what it capped from. 24fps and above
    belong in the MP4.
    Otherwise it is opaque whatever the stage is set to, and spends all 256 entries on colour.
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
the typing rate, `#cam=` the camera's, `#glow=` the bar's glow rate, `#scrim=` the bar's plate over footage, `#bubble=` the AI Mode pill's opacity, `#bez=` the camera's easing and `#gbez=` the glow's, so an edit survives a reload and works in headless renders.

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
| Type sizes | Solve each run's size from its measured ink width using the real font's metrics | Query **90.95px**; body **37.97px**; heading 46.22px; nav 35.34px; chip label 63.53px (now **60.4**, off `AIM Button.svg` — see below); legal 16.94px — all at the font's default optical size and default tracking |
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
| Bulleted answers | `NKE_Response1_1.svg`, subpath bboxes off the body's compound path, plus stem runs on three scanlines | The body margin is **241** — the same 241 both pieces already set — the disc is ink from x **263.88 to 273.11**, so **9.25px centred on 268.5**, and the item's first line and every line it wraps to begin at **298**. Baseline to baseline across the two item joins reads 71.55 and 71.32 against the 51.0 leading, so the band between items is **20.43px**. The type measures a **27.21** cap, which against this font's 0.72 cap ratio is **37.79px** — piece 1's own 37.97 to within half a percent — so all four are quoted as ratios of the size (**1.482em** indent, **0.728em** to the disc centre, **0.245em** disc, **0.541em** band) and each piece computes its own from its setting. The lead-in phrase measures **4px stems against the body's 3** on three scanlines, which is the ratio already carried as `font-weight:500`, so it reuses that weight rather than adding one. It is derived from the colon rather than marked up, capped at 60 characters. Applies to the answer in both pieces and to the prompt piece's context and trailing lines. Back: drop the `- ` and the line is an ordinary paragraph again |
| Half the blue dissolves | `NFL_Gatorade_15s_PromptResponse_01_V02_AB.mp4`, the glow sampled 22px outside the card, clockwise from the top-left | The wheel carries **one** blue arc, not two — 268deg runs through 360/0 to 134, so **226 of 360 degrees, 63%, were blue** and the ring came out lit the whole way round. The clip does not: its ring reads `.33 B64 G52 Y29 R27 M5 .120`, the spectrum running from the middle of the top edge round the right to the middle of the bottom with **the whole left edge black**. Over the perimeter that is **38.8% carrying no colour at all** against this build's 0%, and blue is the hue that is partly gone — 25.6% of the ring, of which only **74.6% clears visibility**, at a mean **36** where yellow reads 65. **By request**, the half adjoining the purple is taken out (312 through 0 to 130) and the half adjoining the green kept, fading out over 40deg and back in over 4 so the edge is the gradient's own. **Alpha only — not one stop moves and no hue changes**, so the rotation and its 1.149deg/frame are untouched; measured back at 1.148-1.150. On the ring, meaned over 1.2/1.6/2.0s: blue **63% -> 20.9** against the reference's 19.0, and bare perimeter **0% -> 41.5** against its 46.7. Still out is the warm end, which was fitted off a different clip and is not what this touched: green +3.0, magenta +2.2, yellow -2.7. Applies to both box looks. Back: `#3F83E5 0deg,#3B82EA 52deg,#2C82FF 59deg,#3284FC 120deg,#4482FC 124deg,` for the first three stops and `#3E84E9 300deg,#3F83E5 360deg` for the last three |
| Glow radius | Same clip, profiled perpendicular to the card edge — out from inside the face until it ends, then every 3px | The clip's glow falls to **half by 9-12px** and is gone by **51-66**. At `blur(34px)` this build held half out to **24px**, carried to 72, and read about twice the clip at every distance — 45 against 21 at 30px out, 21 against 8 at 45. Half-width scales with sigma, so 24 -> 10.5 puts it at 34 x 0.44 = 15 and the tail fit wants 17; **17** measured back closest and is the rounder. Now: half at **12px**, matching. The far tail is shorter than the clip's — reach 36 against 51-66 — because the design draws the glow as **two** stacked layers (a 50-blur at .5 and a 37-blur at 1) and this is one fitted layer, so it cannot hold a tight core and a long tail at once; erring short is the direction asked for. Back: `blur(34px)` |
| Where the sweep starts | Phase swept in 5deg steps, asking where the dissolve's dark run ends | **By request**: the gradient begins at the box's **top-left corner** rather than partway along the top edge. 85deg puts the first colour 6 samples clockwise of the corner and 90deg puts it 10 short, so the crossing is **87** — and since fRaw is 1 at the first frame, `N2_RING_F0` carries one frame of rate with it: 87 + 1.149 = **88.15**. Measured back: 86.97deg at the first frame, colour starting 6 samples of 456 from the corner. `N2_RING_RATE` is untouched and measures 1.148-1.150 against its fitted 1.149 — this moves where the sweep starts, not how fast it runs. Back: 43.99, the angle measured off the plate |
| Bar + button, the new look | `SearchBar_20260819.mp4`, saturation profiled across the bar's edge and around the button | **The clip has no crisp outline on either.** Across the bar's edge it ramps smoothly over ~20px to a peak of **78** right at the edge, then falls away inside; this build read `49,52,56,58, 193,193,193,193, 3,3,3` — a modest ramp with a **4px wall of 193** on it. So both crisp core strokes are gone (the bar's 5-wide `g`, the chip's 4-wide) and the blooms carry the look alone, raised **.62 -> .83** and **.55 -> .78** to land the peak in the clip's band: now **57-88** against its 52-88, with the profile a plain ramp. The button also **fills blue with white ink**: from t=4.55 the clip's pill is solid blue, sampled (51,115,244) a fifth down, (64,115,240) at the middle, (88,117,209) four fifths down, against this build's pale (245,246,248) with black ink throughout. Reproduced as a blue laid over the chip's own colour, measuring **(63,115,240)** at the middle. It rises on the **press**, `PRESS_F0` over three frames — **127..130** — and then **holds**; riding the halo both ways put the button back to pale exactly as it was being pressed, and the clip is still blue at its last frame with the press inside that. (This row and a code comment both used to say it rose on the outline's own 113..118. It never did: sampled off exported frames the face is the pale 244,246,247 through 127, then 184,202,245 / 123,158,242 / **62,115,240** — the clip's middle sample within a count — with the ink crossfading 31 -> 255 across the same three frames.) Back: restore the two `g` groups (and `beamPaths[i+NSEG]` in layoutBar and the dash setter, which addressed the core's four paths), the .62/.55 opacities, `color:#1f1f1f` on `.aichip b` and `fill="#1f1f1f"` on the lens |
| No border, no shadow | Same clip, luminance and saturation profiled across the bar's edges | Profiled at t=0.30, with the glow down at the bottom, the bar's **top edge reads luminance 255 at saturation 0** across all three columns — page 255, face 255, and nothing marking the edge. The bottom edge dips to ~200 but at **saturation 30-84**, so that is the coloured glow and not a grey shade. The `4px #ebebeb` border and the `0 10px 15px -7px` shadow both go; `box-sizing` is border-box globally, so the bar does not resize. Measured back: border 0px, shadow none, top edge 255/0. Back: restore both declarations on `.bar` |
| The glow never stops | Band just outside the bar sampled every 0.25s across the clip | The clip **never has a dark frame** — `everDark` came back empty from t=0.1 to 4.35 and peak saturation holds **78-110** throughout. This build ran a head AND a tail: a second front from frame 31.09 that caught the head up and put the beam out. The tail is gone (`bt = 0`), so the head races round and it then stays lit, with the colour ramp still drifting on BEAM_DRIFT. BEAM_TAILPUSH goes with it — with no tail to sit behind, any push just opens a gap at the seam. Measured back: **96-100% of the perimeter lit from frame 20 through 134**, peak 89-117; the only unlit frames are 17 and 18.5, before it arrives. Back: restore the `bt` clamp and the push |
| The click | Label ink tracked frame by frame while the button is still pale | The clip presses to **0.90** — ink narrowing 190 -> 171 over t=4.295..4.462, about 4 frames — and the blue is there by 4.503, **the frame after it bottoms**; the halo is already round the pale pill at 4.42, so the order is halo, press, fill. The press depth was already right (PRESS bottoms at **0.91**) but the fill was arriving on the halo at 113-118, well before it. Moved onto `PRESS_F0` over 3 frames: measured back, press starts f127, bottoms 0.91 at f130 with the blue fully arrived there. The clip cuts at 4.96, so **the release is not measurable** — the existing return to 1.00 and the blow-up into act 2 are left alone. Back: `sat((fp - 113) / 5)` |
| The bar's glow, recreated | `SearchBar_20260819.mp4`, 200-400 points round the bar with the peak saturation taken along each outward normal | Three things. **It stops at blue:** the ramp was flat blue outside 1250..3520 and paintRamp was called with cycle 0, so it never tiled — once the drift carried the coloured span past the bar every stop clamped to those flat ends and the ring sat on blue. Re-based to 0 with `BEAM_CYCLE` and `rampStops(id,3)`, the three tiles carry it for as long as the piece runs; measured back, f110 and f125 still show B/G/Y/R/M rather than a ring of B. **The dissolve:** the clip's settled ring is 22.2% carrying no colour, stable to a point or two from t=2.1 to 4.4. A fade still reads as colour for most of its length — blue only drops under the floor below ~7% alpha — so it is the CLEAR span that must be 22.2%, not the whole gap; 650/2920 measured back at just 10.3%, which is how 960/3590 was found. It sits at the ramp's own seam, blue either side, where the clip puts it. **Where it opens:** it used to start at arc 0, the bottom-RIGHT corner, and grow one way. The clip opens it on the bottom EDGE — first colour at t=0.165 spanning indices 67..76 of 200 from the top-middle, and the bottom edge occupies 57..143, so **7.5% of the perimeter along the bottom from the right corner** — and grows both ways, the fronts moving +27 and -12 indices in the next frame, so BEAM_HEAD's 800/frame is split 2:1 rather than re-fitted. Note that is **not** the bar's mid point; the bottom edge's own middle is `BEAM_ORIGIN` 0.232, one number away. The hue ORDER and every colour value are untouched, but two boundaries moved to match the clip's mix: green 530 units -> 180 and the seam blue lengthened by the same, because the ring read 31.7% blue / 27.8% green against the clip's 42 / 15.6. Composition now fits to **1.51 rms** — blue 41.2 (42), dark 19.3 (22.2), green 16.2 (15.6), yellow 8.0 (7.7), red 10.5 (8.8), magenta 4.8 (3.7). Back: `BEAM_ORIGIN` 0, `bt = 0`, cycle 0, `rampStops(id,1)`, and the ramp's flat `[-9000]`/`[20000]` ends with green at [370..900] |
| The bar's glow, from the source | The supplied `input-plate` CSS/JS | **The measurement guesswork is gone — this is the source's own structure and curves.** The glow is not a bloom ringing the pill: a solid fill in the border colour, the gradient over it, and a solid overlay inset by the border width, so the only thing either layer can show is that ring — the border and the gradient are the SAME ring and they cross-fade. Reproduced verbatim: the two conic masks (`transparent 0/50, black 68/75, transparent 89` and the sharp-tip variant), the `composit-clip`, the `7 x 1.5` squash, the 16-stop wheel, and the burst's four tracks — gradient opacity 0->1 by .25 on cubic-bezier(0,0,0,1), hold to .5, out by 1 on (0.3,0,0.8,0.15); border the exact inverse; blur 1->20 by .15 ->5 by .25 ->7 by .45 ->1, linear; `--gradient-angle` 170->225 and `--mask-angle` -90->200 over the one 650ms interval. **Three adaptations, all stated in the code.** (1) Sampled per frame rather than handed to `element.animate()`: the export serialises the DOM and a WAAPI animation's current value is not in the serialisation, so an exported frame would come out at the underlying value. Same curves, evaluated at the frame's time. (2) Scaled by the plate's height, 234/112 = 2.089 — the 1px border and the blur keyframes only; every angle, stop percentage and curve is the source's, unscaled. (3) Looped. The source fires a burst per interaction; a single 650ms burst 18 frames in would leave the rest of the typing bare, against **by request** that the glow runs non-stop. The angles and blur loop; the cross-fade runs once and holds, because looping opacity too blacked the ring out at every seam (measured dark at f30 and f34) and the border would have pulsed back on each lap. That also settles the earlier no-border/no-shadow finding: the source HAS both, and the reason the clip shows neither is that they are faded out 46% into a burst, exactly where BURST_BORDER holds 0. Measured back: ring colour survives the serialiser at peak saturation 155, and 112 of 116 frames of act 1 carry glow — the 4 that do not are where the lit arc has panned off screen. Back: `BAR_BURST_LOOP = false` plus `track(BURST_OPACITY, burst)` and `track(BURST_BORDER, burst)` is the source exactly |
| How long one glow run takes | `SearchBar_20260819.mp4`, following the travelling GAP round the bar at 360 points | The ring fills early and stays about **280 of 360 lit**, so the moving feature is the dissolve rather than a leading edge — tracking a leading edge just saturates at the end of the lit run. The gap's centre runs from **310 at t=0.25 to 600.5 at t=4.42**, which is **290.5 samples of a 360 perimeter**; the source's mask sweeps -90 -> 200, which is **290 degrees**. One sample to one degree, so the clip is showing exactly **one** full sweep and it takes about **4.3s**. The source's 650ms is the length of one PRESS, not of the sweep the film shows — at 650ms looping it ran about seven and a half times across act 1. So `BAR_BURST_MS` is **4300** and `BAR_BURST_LOOP` is **false**. The travel is not uniform — 129 samples/s early, ~45 by the end — but that is the decelerate curve the angles already ride, so no easing changed, only the time it is given. Measured back: the mask sweeps -90 -> 200 once, arriving at f122 and holding, and the ring is lit on every frame of act 1. Note the run ENDS at f121 against act 1's f136, so the sweep holds static for the last ~0.7s — the clip does the same, finishing right at its own end. Back: 650 and loop true |
| The bar goes dark over footage | Composite ratio, inside the bar against just outside it | **By request**, the plate switches to a dark scrim the moment Transparent is on or footage is loaded. It has been 0.30, then 0.25, and is now **0.2** — each by request, and the last move went TOWARDS the measurement rather than away from it: the six interpolated frames of the reference give a median of **0.216**, so 0.2 is the plate's own reading to within a hundredth and the 0.30 and 0.25 before it were the departures. The rule for this already existed and had stopped working: rebuilding the plate off the source made `.barover` the FACE — the overlay inset by the border width that confined the gradient to the ring — and it carried an opaque white, so the scrim on `.bar` underneath was painted and then covered. Over footage the bar was still a white card. **That overlay no longer exists** — it was taken out when both ring layers were masked to the ring instead, which is also what removed the bright hairline at the bar's edge — so the scrim sits on `.bar` itself and the face runs edge to edge, with `.barfill` (the border colour and its shadow) going transparent alongside it, which is what the old rule's `border-color:transparent;box-shadow:none` did before the border became its own layer. (An earlier version of this row described the scrim as living on the overlay; it has not since the overlay went.) Re-measured at 0.2 on an exported frame composited over a flat grey: inside/outside reads **0.800** against the 0.800 the scrim predicts, and the interior picks up **no** colour from the gradient (saturation 0) — the mask keeps it to the ring. Plain mode is untouched, face and bar both #fff. Back: the single `#stage.has-bg .bar` rule; the value itself is a panel control now |
| The sweep keeps turning, and leaves nothing | Edge profile across the bar, and the ring with the gradient layer toggled | Two faults with one root: **the sweep stopped**. Clamped at 200deg it froze whatever arc was lit there, and that frozen arc IS the outline that was left behind — measured at f122 and f128 it still carried saturation 89-113 on the top edge, not faint, just thin and motionless. Past its opening the sweep now runs at a constant **47.6 deg/s** — the rate the clip settles to, from the last three intervals of its travelling gap (44.3, 46.8, 51.6 samples/s on a 360 perimeter), a lap every 7.6s. The conic mask takes any angle, so there is no wrap and no seam; the wheel keeps its own 55:290 share of the turn. Measured back: 1.985 deg per frame, 47.6/s, still advancing at f135. **A second outline, structural.** The face was an overlay inset by the border width, so the outer 2px of the pill was reached by nothing: over footage it measured **255 against the face's 191**, a bright hairline round the bar. The overlay is gone — both ring layers are masked to the ring instead (`padding` + `mask-composite:exclude`), which frees `.bar`'s own background to be the face edge to edge. `.bargrad` is grown 140px first, because a mask ends at its element's box and a pill-sized one would have cut the blur's outer spill away; 140 is what the widest blur, 20 x 2.089, carries to at three sigma. Measured back: the profile steps straight 255 -> 191 with no sliver, the ring still lights at 76-155, the spill survives at up to 82, and toggling the gradient layer off changes the pill's interior by **0.00** at every frame — nothing leaks past the mask. The shadow went with the overlay: on a masked layer it would be clipped, and on `.bar` it could no longer fade, measuring 249 against the page's 255 on every frame. Back: `BAR_SPIN_DPS` 0 stops the sweep where it lands; the overlay was `.barover` at `inset:2.09px` |
| Slower, and turning throughout | Mask angle read per frame across act 1 | **By request**, twice: slower and nonstop. The opening goes 4300ms -> **17200** (four times the length the clip's own sweep measures) and the constant turn 47.6 -> **12 deg/s**, a lap every 30s. The turn is also added from the FIRST frame rather than only after the opening: at 4.3s the opening finished inside act 1 so the constant rate took over, but at 17.2s it does not, and the decelerate curve's own rate approaches zero at its end — the sweep would have crawled to a near-stop before the spin ever arrived. Added throughout, the rate can never fall below `BAR_SPIN_DPS`. Measured across act 1: **peak 25.8 -> 8.3 deg a frame, slowest 1.99 -> 1.23** (29.5 deg/s), so every instant is slower than before, and **0 dark frames** — it is turning on every frame there is. Note total travel falls 320 deg to 256, not to 160: the opening rides cubic-bezier(0,0,0,1), which is violently front-loaded, so most of its travel happens in the first moments however long it is given — stretching time does not slow it proportionally. Two dials: `BAR_SPIN_DPS` takes off the tail, `BAR_BURST_MS` the opening. Back: 4300 and 47.6 is what the film does |
| Glow radius doubled | A/B at one frame with the blur halved live | **By request.** `K_PLATE` carries the source's blur keyframes onto this plate's height — 234/112 = 2.089 — and now carries a `* 2` on top. The x2 is the departure; the 2.089 is still the measurement. The track goes 2.09/41.79/10.45/14.63 to **4.18/83.57/20.89/29.25**. Confirmed rather than assumed: at f45, halving the live blur back down takes the glow's half-width 17px -> 9 and its reach 71px -> 35, ratios of **1.89 and 2.03**. **The bleed had to grow with it.** `.bargrad` is grown past the pill so the mask that cuts the ring out does not also cut the blur's outer spill — a mask ends at its element's box, which is the recurring cause of a visible limit around a glow in this piece. 140 was three sigma of the old widest blur; three sigma of 83.6 is 251, so it is **260** now, with the padding and radius following (260 + the border width, 117 + 260). Checked for the hard edge that would prove a clip: with the wordmark hidden so only the glow is measured, the profile is 0 by the time it reaches the bleed and the largest single step is 10 at the bar's own edge — no cut. Exports unaffected, 4ms a frame. Back: drop the `* 2`, and 140/142.09/257 on `.bargrad` |
| Radius -35%, and the intensity boost taken back out | Blur track; ring saturation sampled along the bar's edges | **Radius, by request:** `K_PLATE` carries the source's blur onto this plate's height (234/112 = 2.089) times a multiplier, which was doubled and then cut 35%, so 2 x 0.65 = **1.3**. A gaussian's reach scales with sigma, so the multiplier IS the radius — the widest blur runs 41.8px at 1x, 83.6 at 2x and **54.3** here, track 2.72/54.32/13.58/19.01. The bleed on `.bargrad` tracks it, 260 -> **170** (three sigma of 54.3 is 163), because a mask ends at its element's box and too small a bleed slices the glow off at a hard edge. Checked: the glow reaches 45px, is 0 well inside the bleed, largest single step 8 at the bar's own edge — no cut. **Intensity: reverted, by request.** For two rounds the glow was lifted over footage and under a matte — `saturate`/`brightness` on `.bargrad`, then a second pass of the gradient dialled to 0.30 for a measured 1.30x gain. Both are gone; the ring measures **one level everywhere**, peak 170/171 and mean 31.9 in all three modes, gain **1.00**. Two findings from that round are kept in the code in case it is ever wanted again: the glow is not actually weaker in those modes (it measured the same in all three then too — what changes is what it sits on), and `saturate` alone cannot lift it, gaining 1.24x at 1.75 and then flattening (1.26 at 2.2, 1.27 at 2.8, 1.28 at 3.5) because the limit where the glow is thin is ALPHA, not saturation. Density is what the blur takes out, so a second pass is what puts it back. Back: multiplier 2 with bleed 260/262.09/377 for the radius; a `.gblur.boost` second pass for the intensity |
| Rotation 10% faster | Angle read per frame, against the previous curve at 1.1x elapsed | **By request.** Applied as a TIME SCALE rather than to one number: `BAR_BURST_MS` divides by 1.1 (17200 -> **15636**) while `BAR_SPIN_DPS` multiplies by it (12 -> **13.2**), which together are exactly `angle(1.1 x t)` — both halves of the turn scale as one. Verified as that rather than assumed: the angle at every frame matches the old curve at 1.1x elapsed to within **0.002 deg**, and every angle now arrives **1.10x sooner** — 60 deg at 1.564s against 1.720, 120 at 2.813 against 3.095, 180 at 4.448 against 4.892. Worth recording because it looks like a shortfall and is not: the rate at a FIXED frame rises only about **5%** (peak 8.32 -> 8.83 deg a frame, travel across act 1 256 -> 269). Compressing time moves you further along a decelerating curve, and the smaller slope there partly cancels the scale. Still turning on every frame — slowest rate 1.28 deg a frame. Back: 17200 and 12 |
| The AI Mode button's glow, on the bar's construction | Angles compared per frame; halo isolated by hiding the bar's layer | **By request** — same look, same rotation. The button still wore the OLD approach: an SVG `.chipring` of four stroked paths with `#ringBloom`, its own blur filter, its own `#ringOuter` mask and its own ramp sweep through `ringSpin`/`RING_SCALE`/`RING_CYCLE`. All of it is gone, replaced by the same layer stack the bar now uses — the source's gradient under the same pair of conic masks, cut to the ring so the chip's face and label stay clean, grown past the pill so the blur's spill survives the cut. **The rotation is shared, not copied.** `--gradient-angle` and `--mask-angle` are worked out once per frame and written to both, so the two can never drift or disagree about phase; measured, the angles are identical on every frame the halo is visible. Only the opacity is the chip's own, still riding the measured envelope that brings it in at the press. **Scaled, not equalled.** The source scales by its plate's height, so this does too: the chip is 158 tall against the plate's 234, giving `K_CHIP` = 158/112 x 1.3 = **1.834** against the bar's 2.716 — a 1.41px ring where the bar's is 2.09, and a bleed of 115 (three sigma of 20 x 1.834 = 36.7 is 110). The smaller control gets the proportionally smaller glow. Measured back: the halo's own peak saturation is **107** with the bar's layer hidden, its face stays clean, and the old `#ringBloom` over-footage rule went with the element it targeted. Back: the `<svg class="chipring">` block, its four gradients, `ringGrads`, and the `paintRamp(ringGrads, ...)` call |
| The button's halo: wider, slower, bottom to bottom | Coverage and phase swept at 180 points round the button; arc tracked per frame | **By request**, across several passes. Its own construction, phase and cycle rather than the bar's wheel. **A wider window, so the turn can be slower.** The source's is `transparent 50, black 68..75, transparent 89` — about 39% of the circle — and on the chip that lit only **32%** of the perimeter. Opened to **28..99** it lights **56-64%**; the steps measured 46% at 42/58/80/95 and 54% at 35/50/85/98, and 20/38/92/100 reaches 62% but leaves so little dark that the travelling gap stops reading. **It also needed its own squash to reach the bottom at all.** The shared `scale: 7 1.5` is fitted to the BAR's 10.9 aspect; the chip's is 2.88, and the same stretch mapped the window onto 27 samples against the 49 the bottom needs — no phase could have covered it. **2.2** is the best that shape reaches. **270deg is fitted** for the wider window (84% of the bottom; the narrow window's best was 285). Increasing the angle moves the arc CLOCKWISE, measured: its centre runs +42 -> +89 samples of 180 as the angle goes 0 -> 100. **The turn runs 117 -> 128**, both ends from the halo's own brightness. 117 is as early as the bottom can be READ — opacity ramps 0.08/0.35/0.50/0.66/0.93 across 115..119, and the narrow window did not clear 60% bottom coverage until 119 where the wider one gets there at 117 (65%), which is what buys the extra frames. 128 is the last frame before the blow-up takes off (0.95 scale there; 4.4 by 133). That is **32.7 deg a frame against 45 — 27% slower**. Below 117 the arc HOLDS on the bottom while it fades up. **And it leaves.** `RING_PRESS_FADE` was FPS, a second, which cannot finish inside act 1 — still 0.13 at the cut, so a faint outline sat through the blow-up. **8 frames** puts it at zero by 135. Measured back: mask **270.0** at f117 with 65% of the bottom lit, **630.0 = 270 + 360** at f128 back on the bottom, mean coverage **56%** across the bright frames, and the halo's contribution to the frame is **0** from f129. Back: the source's window, squash 7, phase 285, 119..127, and RING_PRESS_FADE = FPS |
| Gradient over footage and matte: denser, same radius | Glow profiled off the bar's edge — peak, half-width and reach | **By request**, against a supplied still — and note **this one is by eye**: the reference arrived as an image in conversation rather than a file, so unlike everything else in this table there was no frame to sample. The numbers are what the build measures. Two levers were already known not to work. Opacity: `.bargrad`'s is written per frame from the burst's track and is already 1 once the ring is round, and an inline style beats a rule. Saturation alone: swept live it gains 1.24x at 1.75 and then FLATTENS — 1.26 at 2.2, 1.27 at 2.8, 1.28 at 3.5 — because the colour is at its ceiling where it is dense and the limit where it is thin is **alpha**, which saturate cannot add. A `saturate(1.9) brightness(1.3)` was tried on top and **taken off again by request**; the gradient keeps its own colour in every mode. So density is what changes: **two extra passes** of the same layer over footage or under a matte, compositing to 1-(1-a)^3. **But stacking them at the full blur made the glow READ WIDER, not just denser** — the faint tail that sits under the visibility floor on white clears it once three passes composite, and the half-width went 17px to 28, a 1.65x radius. The extra passes run at **0.6** of the main blur (`BOOST_BLUR_K`), which puts the density back near the edge without extending the tail; 0.35 overshoots to 0.71. Measured back: half-width **15.5 -> 17.5 (1.13)** and reach-to-16 **36 -> 37.5 (1.04)**, so the radius matches, while the peak runs **115 -> 185**, a 1.61x density. Plain mode is one pass and untouched. Back: `BOOST_BLUR_K` 1 for the wider version, or delete the two `.boost` divs and their rule for none of it |
| The AI Mode button, off its design file | `AIM Button.svg` — `getBBox` per subpath, scaled to the build's 158px height; every part scanned back off an exported frame | **By request.** The file draws the pill 260.018 x 94.918 at `rx 47.459` on `#F4F6F7`, which is x1.6646 to this height. Every part of the button now comes from it: width **432.8** (was 455), pad-to-icon **52.9**, icon **69.8**, gap **26.8**, label **60.4px**, fill **#f4f6f7**. The parts sum to 432.8 — exactly the width — so the pill is not padded to fit, it is what its contents make. **The gap is the real find**, 19 -> 26.8, 41% out, and the comment that sat on it admitted it was an eyeball read of a pasted image rather than a measurement off a frame. **The icon reverts an earlier by-request departure:** it had been run 15% over the plate and then 5% back off it, 73.2; the file supersedes that at 69.8, so say the word to have the bigger icon back. **The label is fitted to ink width, not to a font metric** — 226.0 wide at 60px and 229.8 at 61 puts the file's 227.6 on 60.4 — and scanned back off an export it draws 227.5 x 45 against the file's 227.6 x 44.86, matching on both axes. A cap-height metric argues for 62.4 instead, which is 3% wide and runs the text past where the file ends it; that route was tried and dropped. Icon ink lands 52.8 from the pill's left against the file's 52.9, and both parts sit centred to within half a pixel. **The plate and the file disagree**, and this follows the file: the plate's chip measures 455 wide (`x 2375...2830`) at `#f5f6f8`. The width feeds the layout 1:1 — the bar goes 2491.1 -> **2468.9** and the pan 1583.1 -> **1560.9**, both exactly the 22.2 the chip lost, since the bar's right edge hangs off the chip. The G-icon look rescales with it, every dimension 1.0489x the new base. Back: `CHIP_W` 455 in both places, `--chip: #f5f6f8`, gap 19, padding-left 59, spark 73.2, font 63.53 |
| The spark, off its own file | `Search Spark.svg` — `getBBox` on the path, then every part scanned back off an exported frame | **By request.** The lens is now the supplied artwork. Worth knowing what this actually changed: last round the icon's SIZE was fitted to `AIM Button.svg` but the DRAWING underneath was still a different one — a chunky filled search-sparkle where both design files carry a thin outline. So this is the artwork swap the size was already waiting for, and the two files turn out to hold **one drawing**: the spark's path is the button file's translated by (26.4609, 21.2813), exact on every pair. The file draws the ink **41.938 x 41.885 inside a 53 box**, 79% of it, so the `viewBox` is set tight to that ink rather than to the box — the element box is then the ink box, which is what keeps the fitted pad 52.9 / ink 69.8 / gap 26.8 reading off the element. Measured back at 69x69 ink and a 28 gap: the shortfall is antialiasing, not placement, and it converges on the geometry as the cutoff relaxes (66/31 at luminance 110, 68/29 at 180, 69/28 at 225 against a 244,246,247 face). **Two adaptations.** Its fill is `#1F1F1F` and has to be `currentColor` here, or the lens would stay dark when the button fills blue and the ink flips white — verified, the icon tracks the ink 31 -> 255 across 127..130. And it is nudged **up 1.55px**, because the button file rides the icon 0.93 units high of a 94.918 pill and a tight viewBox would otherwise let flex centre it; the spark file agrees on the direction, drawing its ink 1.245 of 53 units high, and disagrees on the amount (2.07px here), so the file that shows the icon in place wins. Back: the previous `<path>` at `viewBox="3 1 20 20"`, and drop the translate |
| The chat page's rule follows the card | The line and the card behind it sampled per frame off exported frames, composited over a mid grey | The divider under the nav read wrong while act 2 arrives over footage or under a matte, and **two separate things** were causing it. **One, it out-ran the card.** The chrome rows all fade in on `f0 5.756 / fd .06` — about a frame and a half, near enough a snap — while the card itself climbs on `F_BODY 5.60 / F_BODY_D 0.40`, so at f140 the line was fully opaque (alpha 255) over a card only 60% there (alpha 152). It is marked `data-on-card` now and its opacity is multiplied by the card's own progress, so the two move together: measured, the rule's opacity is **0.598 / 0.702 / 0.806** on f140/141/142 against an `--a2bg` of exactly the same. **Two, and this is the part matching the timing did not fix, an opaque light-grey bar can only ADD brightness to a card that is not white yet.** `#ebebeb` is a colour whose entire job is to sit a little under white; painted at any opacity over a half-there card it made that strip MORE covered, so the line came out **lighter** than the card it divides — the inverse of what a divider is. It is drawn as a **darkening** now, `rgba(0,0,0,.0784)`, which holds the relationship at every stage: whatever the card has reached, the rule is 7.84% under it. Measured across the arrival, the line is darker than the card on **every frame** where before it was darker on none of them until the card finished. **The settled page is untouched** — 255 x (1 - 0.0784) = 235.0, which is `#ebebeb` exactly, and an exported frame reads **235 at all four columns**, the same as before. Ink is deliberately left alone: the nav, the mark and the sidebar icons carry their own colour, so reading early is them arriving rather than a fault. `--rule` is kept as the record of the measured colour but **nothing consumes it now** — the alpha on `.rule` is the dial, and there is a note on the variable saying so. Back: `background:var(--rule)` and drop the `data-on-card` attribute |
| The wheel's phase | Same, frame by frame | `from` = **43.99 − 1.149·f**, to 1.15° rms across all 47 frames of the act |
| Typing | Caret's right edge, frame to frame | Frames **3→34**; caret 3.4×32 at the text's ascender |
| Prompt type | x-height on the settled line | 23px x-height → **44px**, pure white, starting x=473 |
| Context above the box | Row bands and x-height, then the supplied `Common Confusion….svg` | Two lines of the previous turn, **37px** from x=258, on a pitch the plate measures at 48 and which now runs **1.4** by request — 51.8 at this size, so each row sits 3.8 further from the one below it. Written as the ratio rather than the product, since the ratio is what was asked for and it survives a change of size. **Anchored by its bottom edge** so a longer turn grows up and out of frame rather than down into the box, and that bottom is now **183** — 18 lower than the plate's 165, by request. The action sheet hangs off the same pair of custom properties, `ctx-bot + ctx-gap`, so the **55px** under it is fixed however long the line runs: nothing in act 1 carries an absolute y for either any more. Verified in an export at two lines and at four — bottom 183 and gap 55 in both, with the fourth line at y=−9, out of frame. The ink starts from the design file's fill and blur, but both are now specified **per row**, and per-row values are what its gradient gave way to; what survives is the idea — white type receding upward, dimmer and softer the further into the past. **Colour** is the file's gradient clipped into the type — `#ffffff` at the block's bottom to `#666666` at its top — a gradient rather than a value per row so both ends show *inside* a single line: over our 155.4 of three rows it moves about **35 levels across each line's own height** (248→214 down row 1, 198→162 down row 2, 147→110 down row 3). White is anchored at the bottom rather than where the file puts it: its vector starts white **110.89px below** the block, so the block never samples brighter than 181 — right on the light artboard the file is drawn on, where near-white is near-invisible, and inverted on the black this runs over. The two colours and the direction are the file's; only that offset is not. **Opacity** is flat per row on top of it: **60% / 40% / 20%** (third and above), so a row further up is both greyer and fainter. The element carries the 60, which is also the ceiling asked for and the bottom row is what reaches it, so each band only scales it: 1, .6667, .3333. **Blur** is per row too: **0.5 / 1 / 1.5 / 2px**. A CSS blur is uniform, so the line is drawn once per row and each copy masked to its own band — bands rather than a crossfade, being disjoint they simply sum with no correction for layers compositing as `1−(1−a)(1−b)`. The band edges go where consecutive rows' **blurred reaches** part: the rows ink at 7–42, 58–94, 110–147 and 162–198 up from the bottom and reach 5.5–43.5, 55–97, 105.5–151.5 and 156–204 at three sigma, so the edges sit at 73.25, 125.25 and 177.75 in the box's coordinates, each with clear air both sides. That last one only has air at these amounts — at 2 and 3 the third and fourth reaches met exactly at 153, at 4 and 5 they overlapped, and no edge could avoid clipping one or admitting the other. **The copy is trimmed to three rows before it is set**, not masked: a masked fourth row is still drawn and still blurred, and surfaced as a sliver at y18–24 on a six-row turn. **And the whole thing sits in 24px of padding, which is what the visible limit was** — a mask ends at its element's box and the box was exactly the text, so blur spilling off the first character was chopped at x=258: 0 at 257 and **6.83 at 258**, a straight vertical line down the left of the block. Verified in an export: peaks land at **60.0% / 38.8% / 18.0%** of white (blur costs a stroke's peak a point or two), spreads **1.30 / 2.03 / 2.18** against an unblurred reference's 1.33, and 2 rows draw 2 bands where 3 and 6 both draw 3 |
| Send button | Fill colour sampled on the button | Pure white through f39, then a straight three-frame ramp — **.33, .67, 1.00** on f40, f41, f42 — to the design's `#346BF1`. The press after it shows as the pill's left edge coming in 2, 6, 7, 4px over f43–46, a scale easing to **0.887** on f45 and back |
| Halo | Profile out from the box edge | Reaches **57–60px** on every side: 40 at 2px out, 35 at 10, 22 at 30. Cut off at the box's own edge so none of it washes into the face, which is why the plate reads pure black inside |
| Flash | Frame means, inverted through this build's own opacity-to-mean response | Plate reads 5.3, 25.9, 102.2, 175.5, 250.3 over f48–52, so the card has to sit at .094, .430, .716, .984. A straight ramp over **48.75…51.75** reproduces them to 5.4 rms — a ramp running the full four frames to 52 gives 7.1 |
| The rail glyphs | The supplied `icon.svg` and `edit_square.svg` | Used as-is in both acts, at the boxes the plate measures — 36×32 at (84,292/293) and 39×39 at (84,402/403), which is what they are drawn at. Their own `#56595E` is act 2's measured rail colour to three levels ((86,89,94) against (85,88,91)), so on the answer page the file's fill is what is used; over the dark ground act 1 wears white at 60%, which is what the plate reads there |
| Both glows had a visible edge | Profiles out from the box, and out from the lit phrase | **Both were masks ending where their element did**, which is a cut, not a falloff — and full opacity made them plainer. The box's halo lived in a 70px ring around a `blur(34px)`: out from the edge the level ran 8.7, 5.7, 3.7, 2.0 and then a flat **0 from 71px**, up, left and along the corner diagonal alike. Sigma 34 carries to about 3σ = 102, so the ring is now **140** and the glow reaches nothing on its own — 8.7, 4.3, 1.7, 0.3, 0. Act 3's phrase was cut by its own line box: below the lit rows the halo read 2.29, 2.19, 2.14 and then **0.38, 0, 0** at 17px out. Its widest shadow is `0 0 88px`, and a text-shadow's blur radius is two sigma, so that carries to ~132: **140px of vertical padding**, cancelled by a negative margin so the wall still wraps to identical lines. The largest step anywhere in 130px is now 1.14. Sideways it stays at 70 — nothing was clipping there, and the figure is not free to change, because the hue handover is a `90deg` gradient in *percent*: at 140 each side the far hue began fading in 15px into the phrase instead of 74 |
| The + button, the mic, the query and the action sheet | `Add.svg`, and the design's own grouping | **By request.** The + is `Add.svg` as drawn — a 94.2012×70.6509 pill on a 35.3254 radius in `#F0F2F5` with the file's own path over it in `#0A0A0A`, kept in the file's coordinates with the `viewBox` set to the pill's rect, the same way the mic and rail glyphs are carried. Its 50% now sits on the **whole button** rather than on the pill's fill, which is how `box_dark.svg` groups it — `<g opacity="0.5">` around both — so the + dims with its pill. This also **fixed a real bug**: the morph writes an inline opacity onto the +, the mic and the send every frame, and it wrote a flat `1`, so the mic had been rendering opaque against a stylesheet that said `.5` since it was written. It multiplies the resting value now. The query sits **7px lower** (top 39, not the file's 32) and the action sheet 7px lower with it (238 / 240 / 243 / 247); those icons were already the 60% white asked for |
| Act-2 page | Edge/run detection on f70 | Mark **72px** at (66,65); nav ink band y 87–121 with items at 242, 483, 585, 761, 933, 1150 and carets at 401, 1253; rule at **207**; chip **711×99** at (969,291), text inset 45; body from x=241 on a **51px** pitch; rail glyphs at y 293–324 and 403–441 |
| Both shapes follow the prompt's length | The bubble's right edge across two sources; every inset on the box | **By request.** The bubble hugs its text and is pinned by its **right** edge, the same rule the search piece's uses: `AIM Chat_White.svg` draws it 861…1680 for its own string and the plate 969…1680 for this one — two lengths, one edge, 240 in from the frame's. It grows leftward to at most **1439**, where it meets the answer column at 241, and a row is 99: the plate's height, and 24 of padding either side of the body's own 51px line. Extra rows push the answer down by 51 each. Its corners are the design file's path — **49.5 / 10 / 60 / 49.5**, squaring the one nearest the sender — where a plain 45 pill had been assumed. The prompt box keeps every inset it is drawn with (text 32 down, controls ~30 up, 114 of air between) so a second row makes it one line taller, growing about the frame's centre because that is where it sits to within a third of a pixel. And the bubble takes the **box's** line breaks, not its own width: the box is this piece's field, so its two rows become the bubble's two rows instead of the text reflowing partway through the morph. The panel's prompt field is then sized to agree with both — same typeface, so matching the width in **ems** matches the break positions, and 960/44 is 21.818em, an **11.05px** field at the panel's 241px. Field, box and bubble break identically on all 50 prefixes of a 48-word prompt |
| The chat page fades out at its foot | `AIM Chat_White.svg` | **By request, and in both pieces.** The file draws one rect over everything it has already painted — `0..1920` by **713..1080**, filled `x1 960 y1 713 → x2 960 y2 1080` from white at zero alpha to white at full — the affordance that says the answer carries on below the frame. Frame-fixed rather than part of the copy, so it neither rises in with the answer nor scales out with it; in the prompt piece that matters, since the body there scales and smears away at f80 and the fade must not go with it. The search piece's carries `--a2bg`, so it tops out wherever that card does — over footage or a matte the card is only partly there through the join, and a fade to solid white would have been the one opaque thing in a frame otherwise still letting the plate through. Verified in an export: the rect lands at exactly `0,713,1920,367` in both, and black ink at y=760 renders **33**, which is 12.8% into the ramp × 255. **Neither plate has it**, so it is paid for: the prompt piece goes 2.76 → **2.85** rms with f86 becoming a fifth outlier at 248.1 against 245.2, and the search piece's act 2 goes 0.02 → **0.43**, its f161 246.65 against 245.8 |
| Act-2 weights | Stem widths on the x-height | 3px through the first paragraph's opening, **4px** from the claim to the end of that paragraph, and 4px on the two quoted names — so the emphasis is a real weight change, not a colour one |
| Act-2 trailing line | Darkest pixels per paragraph | The last line is `(154,154,154)` on the plate where the paragraphs above it read `0` — greyed, because there it is still arriving. **It is `#000` now, by request**, so the answer is one colour throughout: measured on the computed style, every part of both pieces' answers is `rgb(0,0,0)` — two paragraphs and the trailing line here, two paragraphs and the heading in the search piece, and the revealed words with them. It still *reads* lighter on screen, and that is the page fade rather than the ink: the line sits at y 944–995, which is **70% into** the 713→1080 ramp, so black renders about 179 there and measures 169. The plate is unmoved either way — 2.85 rms with the same five outliers — the line being small and deep enough in the fade that 154 → 0 barely reaches the frame mean |
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

## The MOV's alpha is straight, not premultiplied

ProRes 4444 carries an alpha channel and does not say anywhere in the file which
convention its colour is in. Straight and premultiplied are the same bytes meaning
two different pictures, and the two readers this piece has met disagree.

`prPlanes` had been premultiplying **unconditionally**, and that is what put a dark
edge on everything semi-transparent. Measured on the glow at act 1's f20: a canvas
pixel of `(45,130,255)` at alpha 57 was stored as `(10,29,57)` at the same alpha,
so an editor — which assumes straight, because that is what 4444 means — scaled it
by that alpha a *second* time and drew `(2,6,13)`. Four to five times too dark.
The box's 35% face and the context line's 60/40/20 rows went the same way, which is
the other half of it: the colour and opacity of the type not matching the preview.

Straight now, and it reproduces the preview exactly. Same frame, same points, what
a straight reader composites over black against what the preview shows there:

| | stored | α | reader over black | preview |
|---|---|---|---|---|
| glow, left | (45,130,255) | 57 | **(10,29,57)** | (10,29,57) |
| glow, top | (64,131,230) | 72 | **(18,37,65)** | (18,37,65) |
| box face | (9,9,9) | 89 | **(3,3,3)** | (3,3,3) |
| send pill | (255,255,255) | 255 | **(255,255,255)** | (255,255,255) |

**Opaque exports were never affected and are not now** — at alpha 255 the two
conventions are the same arithmetic, and a frame round-trips `(10,29,57)` →
`(10,29,57)` either way. Only *Transparent: on* ever had the question.

The other convention is real too, and this file no longer offers it. A reader that
expects premultiplied and is handed straight data *adds* the stored colour instead
of scaling it, so semi-transparent ink blooms — that is what "the gradient is too
thick" looked like in Google AI Studio, and premultiplying is what fixed it there.
One file cannot satisfy both readers, and straight is the format's own convention
and the one that matches the preview, so straight is what this writes. To go the
other way, multiply `r`, `g` and `b` by `alpha/255` in `prPlanes`.

Two things worth knowing. The noise argument for premultiplying does not need
premultiplied *storage*: a canvas keeps premultiplied bytes and divides on the way
out, so at low alpha it returns the division's rounding error, but a straight reader
multiplies by that same small alpha when it composites and scales the error back
down itself. It only shows in something that reads colour without alpha, like a
thumbnail. And that noise does not compress, so a straight alpha frame runs about
**63% larger** — 893KB against 549KB on frame 20 at 1920×1080.

The other exports never had the question. PNG is straight by definition and the
browser's own encoder writes it; the MP4 and GIF have no real alpha channel to
disagree about.

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

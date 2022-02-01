# fire_behaviour_app
Fire behavior application

[https://sybrand.github.io/](https://sybrand.github.io/)

## Build for web

```
flutter build web --base-href /MyBaseFolder/
```

## Code Conventions

- Dart naming convention rules are often broken in order to conform with the CFFDRS R library. The R code has been
manually translated, and in order to debug and stay up to date with changes, it's just easier if the code looks
similar.

## Todo

- Localization - implement en-CA and fr-CA.
- Coordinates - provide user feedback on location button. (e.g. fetching and failed state).
- Add FMC option in advanced.
- Advanced: Change PDF and PC to sliders.
- Advanced: Problem: pre-set can conflict with entered values. The moment. anything is changed, the pre-set should become un-set OR You need a "load preset" button - maybe that's better?
- Advanced: Result columns - there are some "two line" columns. Would be nice if the result columns could size better.
- FFMC scale at the bottom.
  - Possible, but nothing out of the box - so leaving it alone for now.
- Finalise disclaimer.
- Finalise popup.
- Diurnal FFMC screen.
  - Add a screen where you can input yesterday's FFMC the RH and the Wind, to get the daily FFMC - see: ffmcCalc.
  - Add a screen where you you can see the impact of the diurnal FFMC (maybe sliding time?) - see: hffmc.
  - Work towards a screen where you can see the impact of changing FFMC on fire.
- Do lots of re-factoring (code was written as p.o.c. in a big rush).
- Persist last settings? (Except for lat/long - since that's a log of the persons location and we don't want to persist anything personal)

NOTES FROM B:
Hey again Sy!

Been playing around with the App for a little bit now, and I’ve gotta say it’s pretty awesome!  I haven’t actually compared any of the calculations from the App to the RedBook, cause I’m fairly confident that the coding was done correctly.

One of the only things that stood out for me was the slider for % curing.  As you explained in the Sprint review a while back, this will only have an impact on the grass fuel types.

I was curious if there was a way to have this slider be “greyed out” when any non-grass fuel type was selected?  It’s a small thing, I know, but I think doing so would make it very clear to the user that it’s not a relevant/necessary input to the overall calculation, and may prevent some newer people from scratching their head and asking “wait, why am I being asked this when I selected C-2?”
 
Partially related, I would personally put the “curing” row at the very bottom instead of second-to-last (i.e below FFMC) just based on how seldom it will be used.

And lastly, I noticed that the FFMC bottom limit is 80.  While I understand that it would be very unlikely for anything crazy to go on with an FFMC below this value, I feel like I would still prefer to have the option to check this as a user.  Maybe something like a bottom limit of 60?  Or, actually, I’m not sure if you even need a bottom limit, now that I think about it … the BUI on there starts at 0 …. Hmmm.
 
Anyway, these were the only thoughts I had.  I was glad to see your note about the location button not working – I went in to change the permissions manually and it works well, so woo!

Will continue to play around with it when I get the chance.  But I can tell this will be a hit with many people!

Cheers,

## Log of changes & decisions.

- [x] Added crown fraction burned to basic screen.
- [x] More space on left hand side.
  - Added padding on the left and the right.
- [x] FFMC scale from 80+
  - Made the scale start at 80.
- [x] Fuel type picture.
  - Added fuel type pictures, but request for licensed images resulted in pictures being removed for now.
- [x] Coordinate affects FMC (it may not seem to for some part of the year), so we are keeping coordinates instead of using some default.
- [x] App name: decided to call it FBP Go.
- [x] Changed default flutter icon to fire emoji: 🔥
- [x] Colour of output text and background changes to match severity.
- [x] Reduced length of preset fire type names.
- [x] Added disclaimer popup with placeholder text.
- [x] Added about placeholder text.

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
- [x] Added crown fraction burned to basic screen.
- [x] More space on left hand side.
  - I added padding on the left and the right.
- [x] FFMC scale from 80+
  - I've made the scale start at 80.
- FFMC scale at the bottom.
  - Possible, but nothing out of the box - so leaving it alone for now.
- Consider dropping lat/lon/elevation on basic - only has slight effect. (could be time of year as well!)
- [x] Fuel type picture.
  - I've added picture placeholders. Need actual images to put in.
- With less space, the fuel type presets need to have shorter names.
- Disclaimer.
- App name.

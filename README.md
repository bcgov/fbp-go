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
- FFMC scale at the bottom.
  - Possible, but nothing out of the box - so leaving it alone for now.
- With less space, the fuel type presets need to have shorter names.
- Disclaimer.

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

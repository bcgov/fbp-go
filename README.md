# FBP Go (Fire Behaviour Prediction on the Go)

Fire behavior prediction application

Preview latest PWA build on: [https://sybrand.github.io/](https://sybrand.github.io/)

## Build for web

```
flutter build web --base-href /MyBaseFolder/
```

## Build for Android
Maybe you want to update first?

I have my android studio install in `~/.local/android-studio` - with a symlink in `~/.local/bin/studio.sh`
```bash
studio.sh
```

then System Settings -> Updates -> Check now
If it fails because it can't update java - exit - check for java processes and kill them

```bash
ps -A |grep jav
kill -9 PID
```

```
flutter upgrade
```

Update the build in:
android/local.properties
e.g.:
```
sdk.dir=/home/[username]]/Android/Sdk
flutter.sdk=/home/[username]/snap/flutter/common/flutter
flutter.buildMode=release
flutter.versionName=1.0.1
flutter.versionCode=2
```

Up the version in pubspec.yaml, then run
```
flutter pub get
```
NOTE: also had to up flutterVersionCode  in android\app\build.gradle

Make sure you have a way to sign it!
You need to have your upload-keystore.jks configured in android/key.properties

```
flutter build appbundle --release
```

internal testing -> create new release -> upload
relesases overview -> review it


## Build for iOS - on M1 silicon

If you use the default ruby+gem setup that comes out of the box, you'll get errors about
ffi not being x86_64 - you COULD fix that by running:

```
# don't do this
sudo arch -x86_64 gem install ffi
```

Who wants to run rosetta? That's nuts. Rather get the latest version of ruby and go from there.
(It's no use trying to run gem update --system with the system ruby, it's just going to break things for you)
This also solves having to run sudo with gem, everything neatly goes into .rbenv

```
rbenv install 3.1.0
rbenv global 3.1.0
gem update --system
gem install cocoapods
```

## App store issues

You may receive an email warning: "ITMS-90078: Missing Push Notification Entitlement" from the app store. FBP Go doesn't use push notifications,
it seems to be a side efffect of some flutter stuff. See: https://github.com/flutter/flutter/issues/9984 ; this issue is unresolved at this point in time.

## iOS development notes

```
open -a Simulator
open ios/Runner.xcworkspace
```

## Deploy to app store

Product -> Archive (make sure you've seleted the correct target)

## Code Conventions

- Dart naming convention rules are often broken in order to conform with the CFFDRS R library. The R code has been
manually translated, and in order to debug and stay up to date with changes, it's just easier if the code looks
similar.

## Todo

- Invalid App Store Icon. The App Store Icon in the asset catalog in 'Runner.app' can't be transparent nor contain an alpha channel. With error code STATE_ERROR.VALIDATION_ERROR.90717 for id 1c0da6c4-80df-4e3d-935a-103da3192694
- Coordinates - permission handler - implemeted and tested for Android, need to test on iOS
- Add FWI.
- Consider: reducing the lower range of FFMC to 60.
- Grey out the curing slider for fuel types it doesn't apply to.
- Add screenshots for iOS.
- Localization - implement en-CA and fr-CA.
- Coordinates - provide user feedback on location button. (e.g. fetching and failed state).
- Add FMC option in advanced.
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
- %curing slider should be disabled/greyed out for non-grass fuel types.
- move curing row to the very bottom.
- (pending p.o.) set the FFMC lower limit to 60?

## Log of changes & decisions.

- [x] Increased slider width, reduced label width and put line break between label and value.
- [x] Added check for invalid latitude and longitude (was causing exception)
- [x] Advanced+Basic: Moved curing from 2nd to last, to last.
- [x] Advanced: Change PDF and PC to sliders.
- [x] Advanced+Basic: Prompting for location permissions if not already granted. (Implemented and test for Android, iOS testing outstanding.)
- [x] Changed icon for iOS.
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

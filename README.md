# 🔥 FBP Go (Fire Behaviour Prediction on the Go)

Fire behaviour prediction application

Preview latest PWA build on: [https://sybrand.github.io/](https://sybrand.github.io/)

[![Lifecycle:Maturing](https://img.shields.io/badge/Lifecycle-Maturing-007EC6)](<https://github.com/bcgov/fbp-go>)

## Build for web

```
flutter build web --base-href /MyBaseFolder/
```

## Build

Update `pubspec.yaml` with the the correct version number.

### Build for Android

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

```bash
flutter upgrade
```

Update the build in:
android/local.properties
e.g.:

```bash
sdk.dir=/home/[username]]/Android/Sdk
flutter.sdk=/home/[username]/snap/flutter/common/flutter
flutter.buildMode=release
flutter.versionName=1.0.1
flutter.versionCode=3
```

Up the version in pubspec.yaml, then run

```bash
flutter pub get
```

NOTE: also had to up flutterVersionCode  in android\app\build.gradle

Make sure you have a way to sign it!
You need to have your upload-keystore.jks configured in android/key.properties

```bash
flutter build appbundle --release
```

Head over to the play store - <https://play.google.com/console/developers>

select app
internal testing -> create new release -> upload
relesases overview -> review it

### Build for iOS - on M1 silicon

If you use the default ruby+gem setup that comes out of the box, you'll get errors about
ffi not being x86_64 - you COULD fix that by running:

```zsh
# don't do this
sudo arch -x86_64 gem install ffi
```

Who wants to run rosetta? That's nuts. Rather get the latest version of ruby and go from there.
(It's no use trying to run gem update --system with the system ruby, it's just going to break things for you)
This also solves having to run sudo with gem, everything neatly goes into .rbenv

```zsh
rbenv install 3.1.0
rbenv global 3.1.0
gem update --system
gem install cocoapods
```

### https://github.com/rbenv/rbenv

For rbenv you need to have the shim in your path.

PATH="/{home}/.rbenv/shims:$PATH

## App store issues

You may receive an email warning: "ITMS-90078: Missing Push Notification Entitlement" from the app store. FBP Go doesn't use push notifications,
it seems to be a side efffect of some flutter stuff. See: https://github.com/flutter/flutter/issues/9984 ; this issue is unresolved at this point in time.

## iOS development notes

```zsh
open -a Simulator
open ios/Runner.xcworkspace
```

## Deploy to app store

Make sure you've got the build number correct! Build number must be unique!

Product -> Archive (make sure you've selected the correct target)

## Code Conventions

- Dart naming convention rules are often broken in order to conform with the CFFDRS R library. The R code has been
manually translated, and in order to debug and stay up to date with changes, it's just easier if the code looks
similar.

## Todo

- Add FWI.
- Grey out the curing slider for fuel types it doesn't apply to. (non-grass fuel types)
- Add screenshots for iOS.
- Localization - implement en-CA and fr-CA.
- Coordinates - provide user feedback on location button. (e.g. fetching and failed state).
- Add FMC option in advanced.
- Advanced: Result columns - there are some "two line" columns. Would be nice if the result columns could size better.
- FFMC scale at the bottom.
  - Possible, but nothing out of the box - so leaving it alone for now.
- Finalise disclaimer popup.
- Diurnal FFMC screen.
  - Add a screen where you can input yesterday's FFMC the RH and the Wind, to get the daily FFMC - see: ffmcCalc.
  - Add a screen where you you can see the impact of the diurnal FFMC (maybe sliding time?) - see: hffmc.
  - Work towards a screen where you can see the impact of changing FFMC on fire.
- Do lots of re-factoring (code was written as p.o.c. in a big rush).
- Persist last settings? (Except for lat/long - since that's a log of the persons location and we don't want to persist anything personal)
- (pending p.o.) set the FFMC lower limit to 60?
- Add reference content to the Nav - e.g. pictures of the fuel types (trees) a la red book - would be great for newer folks; Easy to do, but needs images that we have licences for.
- Request: group the data differently, especially in the advanced tab Work with EK to refine, general idea is to group info by: Head of Fire - Flank of Fire - ROS - CFB - … Back of Fire - ROS - CFB - … So folks can isolate and easily scan the info. They also find it too jumbled and tight and are worried they’ll grab the wrong numbers - Tess can help with that part (layout, sizing, spacing)
- User feedback/request: can we have pre-sets based on task? (Future idea) You open the app, say what you’re doing (prescribed burn, small fire, big fire/incident action plan, no fire just out and about - this is not the actual list) Prescribed burning: I don’t need all this info, reduce the list of data (maybe I can still personalize?) I wouldn’t care about the consumption of the flank in this case, and I better not be causing a crown fire
- From testing session: users report difficulty with the sliders in terms of precision - hard to get the exact number they want. Sometimes this is ok, sometimes it’s very bad. Either way, it’s frustrating. Users pointed out that in the field their hands will be sweaty and dirty. Some folks realized they could turn their phone to landscape mode and it was a bit better. User-feature request: in addition to the sliders, can we have + and - buttons There may be other ways, UX can collaborate
- Dev task tech dept: passing font size around sucks. Apply themes.
- Let's talk about dead balsam fir and conifer and grass fuel load being affected by fuel type. (fuel load parameters)
- Grass fuel should be a slider.
- " It would also be nice if the values I enter in the basic tab would transfer over to the advanced tab, right now it seems to default to C2 for fuel type."
- " Would be nice to decrease the sensitivity of some of the sliders. Hot dog fingers make it hard to hone in"
- "If it’s possible to connect the “my location” button to the wildfire one portal to automatically input the local indicies from the closest weather station/stations that would be a cool feature"
- "It would be sweet is you could input numbers manually"
- "And if there was a map so you could click on the location and it would input the coordinates instead of having to do that yourself."

## Log of changes & decisions

### v1.0.5 (future)
- [ ] Automated build (apk + appbundle) in github workflow.
- [ ] Consider swapping out ExpansionPanel (it uses up a lot of space).?

### v1.0.4 (current)

- [x] Basic+Advanced: Left align headings.
- [x] Basic+Advanced: Added flame length.
- [x] Basic+Advanced: White text over red.
- [x] Basic+Advanced: Switched to new proposed colour scheme.
- [x] Basic: "Fire Behaviour Outputs" in Basic heading.
- [x] Basic: Style sliders to match color of results.
- [x] Basic: Adjust font size, shorten description & styling of result.
- [x] Advanced: Match styling applied to basic.
- [x] Advanced: Remove fuel type dropdown (was problematic when combined with preset selection), remove Crown fuel load as input (show as output), remove crown base height (show as output).
- [x] About: Add a link to our repository, switch license to small monospace font, fix version mentioned.
- [x] Basic+Advanced: Change "Crowning" to "Continuous Crowning".
- [x] Basic+Advanced: Changed fire intensity colour palette.
- [x] Tech: Automated testing in github workflow.
- [x] Tech: Automated build (web + iOS) in github workflow.
- [x] Basic+Advanced: 60 minute fire size change from 0 to 1 decimal places.
- [x] Basic+Advanced: Modified elevation input keyboard type to match Lat/Long (except no decimal, no sign).
- [x] Basic+Advanced: Rounding more inputs to 2 decimal places (or 0) for more consistent results.
- [x] Basic+Advanced: Fix bug where negative elevation value could be entered and cause a crash.
- [x] Disclaimer: Fixed spelling.

### v1.0.3

- [x] Basic: Changed order, styling & layout.
- [x] Crowning was incorrectly reported in grass/slash. (Code was passing crown fuel load of 1.0 for grass and slash into CFFDRS, changed to 0)
- [x] Rounding values from sliders. (e.g. in the background, wind speed would be 29.999999999, but display as 30. Comparing different devices, side by side, it appears as if the results for the same inputs differ.)

### v1.0.2

- [x] Change keyboard type to all for negative numbers.
- [x] Prompting for location permissions if not already granted on iOS. (Android should already be working)
- [x] Wind + BUI sliders modified - users find it difficult to make small adjustments, resulting in inconsistent results.
- [x] Changed wind slider to increment in 1's. (was in 1/2's!)
- [x] Changed the BUI slider to increment in 5's. (was in 1's)
- [x] Added line break to Beaufort scale 1-5 description (text was going off screen on small phones).

### v1.0.1

- [x] Beaufort Scale now showing when selecting wind speed.
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

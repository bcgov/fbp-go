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
releases overview -> review it

#### Github Workflow

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
rbenv install 3.2.2
rbenv global 3.2.2
rbenv init
gem update --system
gem install cocoapods
```

Sometimes you'll get a build error saying your pods aren't up to date
```
gem update --system
gem update cocoapods
cd ios
flutter precache --ios
pod install
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

Make sure you've got the build number correct! Build number must be unique! This can be validated in the below step:

1. Product -> Archive 
2. Open the "Organizer" window, Window -> Organizer
3. Select your archived build and click "Validate App" and follow the steps.
4. If it successfully validates, you can then click "Distribute App" in organize, otherwise fix the validation errors and re-archive.

## Updating signing cert and profile
1. When you receive the new cert/profile and credentials, follow the steps here to install: https://github.com/bcgov/mobile-signing-service/wiki/Apple-App-Signing#for-teams---steps-to-setup-your-xcode-for-local-application-signing
2. You may see an error after the Signing Certificate label, to fix this edit the `CODE_SIGN_IDENTITY` and `PROVISIONING_PROFILE_SPECIFIER` in `project.pbxproj` to be set to the new cert and profile names.

## Code Conventions

- Dart naming convention rules are often broken in order to conform with the CFFDRS R library. The R code has been
manually translated, and in order to debug and stay up to date with changes, it's just easier if the code looks
similar.
- Variable names throughout conform to conventions in [ST-X-3](https://cfs.nrcan.gc.ca/publications/download-pdf/10068) Appendix II and [GLC-X-10](https://cfs.nrcan.gc.ca/publications/download-pdf/31414) Appendix I. E.g. `GFL` instead of `grassFuelLoad` or `minGS` instead of `minGroundSlope`. Validating formulae an math in code can get very confusing if one does not conform to the acronyms used in the related scientific literature.

## Todo
- Localization - implement en-CA and fr-CA.
- Coordinates - provide user feedback on location button. (e.g. fetching and failed state).
- Add FMC option in advanced. (Probably won't happen? But maybe setting the date?)
- FFMC scale at the bottom.
  - Possible, but nothing out of the box - so leaving it alone for now.
- Diurnal FFMC screen.
  - Add a screen where you can input yesterday's FFMC the RH and the Wind, to get the daily FFMC - see: ffmcCalc.
  - Add a screen where you you can see the impact of the diurnal FFMC (maybe sliding time?) - see: hffmc.
  - Work towards a screen where you can see the impact of changing FFMC on fire.
- Do lots of re-factoring (code was written as p.o.c. in a big rush).
- Add reference content to the Nav - e.g. pictures of the fuel types (trees) a la red book - would be great for newer folks; Easy to do, but needs images that we have licences for.
- User feedback/request: can we have pre-sets based on task? (Future idea) You open the app, say what you’re doing (prescribed burn, small fire, big fire/incident action plan, no fire just out and about - this is not the actual list) Prescribed burning: I don’t need all this info, reduce the list of data (maybe I can still personalize?) I wouldn’t care about the consumption of the flank in this case, and I better not be causing a crown fire
- From testing session: users report difficulty with the sliders in terms of precision - hard to get the exact number they want. Sometimes this is ok, sometimes it’s very bad. Either way, it’s frustrating. Users pointed out that in the field their hands will be sweaty and dirty. Some folks realized they could turn their phone to landscape mode and it was a bit better. User-feature request: in addition to the sliders, can we have + and - buttons There may be other ways, UX can collaborate
- Dev task tech dept: passing font size around sucks. Apply themes.
- Let's talk about dead balsam fir and conifer and grass fuel load being affected by fuel type. (fuel load parameters)
- "If it’s possible to connect the “my location” button to the wildfire one portal to automatically input the local indices from the closest weather station/stations that would be a cool feature"
- "It would be sweet is you could input numbers manually"
- "And if there was a map so you could click on the location and it would input the coordinates instead of having to do that yourself."
- "Would be nice to tag a location on a map instead of entering coordinates for another weather station"
- "Produce a graphic of the modelled fire shape with wind and slope direction, it allows crews to visualize fire behaviour visually. Disclaimer: not realistic fire anatomy, but gives opportunity to see wind driven versus fuel finding incidents."
- Create an "Assumptions tab", that explains the input values and formulae being used in the background:
- "Assumptions – FBP Go
- Reset defaults feature.

Care should be exercised not to apply the system beyond its useful range. FBP Go/ FBP System can be used to make predictions for a fire spreading during one burning period from a point or line source of fire with the following assumptions:
•	Fuel conditions are representative one of the 18 benchmark fuel types.
•	The Fire Weather Index (FWI) values used are representative of the site conditions.
•	Fuels are uniform and continuous; topography is homogenous. and the wind is constant and one direction during the prediction period.
•	The fire is wind or wind/slope driven, and spread is not affected by a convection column. 
•	Wind is measured in the open and is corrected to 10 m.
•	The rate of fire spread levels off at high wind speed and initial spread index (ISI) values.
•	The fire is unaffected by suppression activities (free burning).
•	The effect of short-range spotting of firebrands on spread is considered.
•	A fire starting from a point source will have an elliptical shape under the above conditions.

The FBP System is based on observations of experimental fires and wildfires. There are very few records of sustained fire spread with wind speeds above 60 km and/or ISI > 70. Thus, the largest ROS values in this App roughly correspond to the upper limit of observed spread rates in each fuel type. Higher ROS values may occur with higher wind speeds and during gusts.
"
- [ ] Consider adding date dialog (important for FMC)
- [ ] FBP: Incorporate card sort feedback.


## Log of changes & decisions

### v1.1.0 (next phase)
- [ ] Add FWI.
- [ ] FBP: Consider input option without sliders.

### v1.0.11 (future)
- [ ] Tech: Automated build (apk + appbundle) in github workflow.
- [ ] FBP: In B.C. the standard is to use degrees, minutes and seconds for coordinates.
- [ ] FBP: Consider : decimal places on wind direction and aspect aren't useful, e.g. SSE can be 157 degrees, we don't need 157.5

### v1.0.10 (current)
- [x] New cert and profile for signing and distributing app
### v1.0.9
- [x] FBP: M3 + M4 should only have dead fir, no conifer slider.

### v1.0.8

#### Summary:

Improved validation on coordinate input, and resolved some crashes related to invalid values. Direction of spread was incorrectly showing the net effective wind direction.
#### Detail:

- [x] Web: About was crashing in web version.
- [x] FBP: Direction of spread was incorrect (was showing net effective wind direction).
- [x] FBP: Limit altitude : 0 to 3000 (negative values are possible in WGS84, but not valid for calculations)
- [x] FBP: Altitude should specify that it's meters.
- [x] FBP: Coordinate latitude was accidentally being saved as altitude. Could cause crash on app if latitude was negative.
- [x] FBP: Latitude, Longitude & Elevation validation implemented.
- [x] FBP: Handling conditions where prediction could not be calculated. Instead of user getting a gray screen, user should now be able to adjust input conditions to resolve the issue.
- [x] Added some semantics for accessibility.

### v1.0.7

#### Summary:

BUI no longer changing when fuel type changes. PDF slider no longer showing for M1/M2. 2 decimal places for fuel consumption. Slope limited to 60%. GFL changed to slider (resolves various bugs relating to text input), and no longer storing user value.

#### Detail:

- [x] Re-factor - removing "basic" screen code from app (just commented out for now, in case we want to bring it back in).
- [x] FBP: Switch grass fuel load to slider. (0.1 minimum, 1.00 maximum).
- [x] FBP: Reset grass to default on fuel type change, no longer storing GFL.
- [x] FBP: FFMC lower limit kept at 80 (values lower than 80 not deemed relevant).
- [x] FBP: Hide CFB and CFC when using grass fuel type.
- [x] FBP: The percent dead fir slider showing in M1/2, it should only be showing in M3/4.
- [x] FBP: When switching between fuel types it remembers all settings, but resets BUI to a baseline value
- [x] FBP: Change fuel consumption to show 2 decimal places (otherwise shows as 0 for grass).
- [x] FBP: Limit slope to 60%

### v1.0.6 Release Candidate

- [x] FBP: Grass Fuel Load - crashes app when set to negative.

### v1.0.5 Release Candidate

#### Summary:

- Single FBP window. (No longer differentiating between Basic/Advanced.)
- Various input, styling & formatting changes.
- Added +/- buttons for fine value adjustment.
- Remember settings.

#### Detail:

- [x] FBP: Removed basic screen.
- [x] FBP: Change "Basic Fire Behaviour Outputs" to match values from Basic, moving all other values to the Advanced group.
- [x] FBP: Changed headings to "Basic Fire Behaviour Outputs" and "Advanced Fire Behaviour Outputs".
- [x] FBP: Only showing GFL and curing for OA1 and O1B.
- [x] FBP: Persist last settings. (excluding PC and PDF)
- [x] FBP: No longer automatically loading your location on start.
- [x] FBP: More spacing between each result, and space between heading and 1st result.
- [x] FBP: A bit more space between the last input item and the results. (e.g. space between curing and primary heading is different.)
- [x] FBP: Only showing PDF and PC sliders for M1, M2, M3 and M4.
- [x] FBP: Added unit of measure (m) to fire spread distance.
- [x] FBP: Drop acronyms, except where there is limited space.
- [x] FBP: Plus/minus buttons for sliders.
- [x] FBP: Tried out FontWeight.normal on unit of measure, but it didn't look good. Reverted back to using same font weight as the value.
- [x] Disclaimer: Changed text from "No warrant or guarantee..." to "No warranty or guarantee...".
- [x] Disclaimer: Fix bug where user could click away disclaimer without clicking on "OK".
- [x] Tech: Upgrade to flutter 3.0.0.

### v1.0.4

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
- [x] Basic+Advanced: Modified elevation input keyboard type to match Lat/Long (we don't need decimal or sign, but that's the only way to get the apple keyboard to behave).
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

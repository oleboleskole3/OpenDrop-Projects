# Bad apple

Bad apple on an OpenDrop device! Use a cartridge with a glass top, all 4 reservoirs are used for drawing the animation. Realistically, this won't work completely as intended on a physical device, seeing as the liquid and air have to come from somewhere.

### Configuration

A couple of globals can be found at the top of the main file, here's what they do:

`captureEnabled` Set to true to take a picture after every frame has been drawn, useful if screen wipe is enabled. Saves into `frames/*.jpg`

`wipeBeforeDraw` Enables screen wipe, screen wipe turns on all electrodes, and then gradualy turns off the unused ones to draw a frame. Though air will then likely become an issue

`timeTilWipe` How much time to keep the display on before beginning a screen wipe. No impact if `wipeBeforeDraw == false`

`timePerFrame` Change how much time to wait between transmits

`myMovie.speed(playbackSpeed)` Found in `setup()`, change video playback rate if too many or too few frames are being skipped

## Running

Just open up "Opendrop_bad_apple.pde" and press run, optionally configure project using above settings

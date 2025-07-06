# Tetris game

My attempt to make tetris playable on the OpenDrop, since Steve Mould proposed this challenge in his video about the device

This game of tetris is to be played on the cartridge with a glass top, with the whole device rotated 90 degrees clockwise.

The bottom left reservoir is the disposal reservoir, this is where liquid will go when a line clears

The top reservoirs are input reservoirs, they provide the liquid the blocks will be made of. For optimal performance, provide two different colored liquids, as blocks will be sourced from the two reservoirs in alternating order.

Yes, by not recycling blocks, this game of tetris is essentially a pump. Think of this as a feature, as the final score corrosponds to the amount of mL of liquid pumped from the top reservoirs to the bottom

## Intended functionality

The device is to be rotated 90 degrees clockwise, so the left side becomes the top side and the right side the bottom. The line at the bottom will always be enabled along with the bottom left reservoir, to (hopefully) ensure the liquid always has somewhere to go in case of line clear.

## Configuration

In `Device.pde` change `minTimeBetweenMovement`to speed up or slow down game

## Running

Just open up "Opendrop_tetris.pde" and press run

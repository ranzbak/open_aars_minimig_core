# Minimig core for the Open AARS board

## Introduction

This Project contains the ported Minimig core originally written by Dennis van Weeren.
The core has been altered to work on the [QMTech](http://www.chinaqmtech.com/)
XC7100T FPGA core board and the Open AARS (Adaptive Amiga retro system) IO board.
The design for the IO board can be found here :
[https://github.com/ranzbak/qmtech_minimig](The V4.0 Light version).

## Core

At this moment most of the Minimig core is stock.
The changes are mostly related to interface the core with the HDMI and I2S interfaces.
Planned additions:

- Possibility to use the native native floppy interface
- Volume control via the OSD menu
- AGA chipset support
- Addition of an ESP32 providing a WIFI interface
- Adding the DDR3 ram as fast ram to the emulator

## Board

The Hardware provides:

- HDMI video output ADV7511 (max 720p).
- SDCARD slot.
- High quality audio output via the MAX9850.
- 2 Joystick ports running on 5V so joysticks with autofire work.
- 2 PS/2 ports, to connect a keyboard and mouse.
- 32 Mb SDRAM on the Open AARS board.
- Interface for an original Amiga floppy drive.

## Issues to be fixed

- Stabelize the image as it's flickering from the interlaced source signal
- The PS/2 mouse interface does not work (Add pull ups??)
- machine crashes when the audio plug is inserted or removed

## Issues fixed

- Joystick interface is unstable (fixed)
- Sometimes using the fire button results in the OSD menu appearing (fixed)
- The original Amiga mouse does not work on joystick port (fixed)
- Image appears too low on display implement vertical tranlation
- Image is too narrow, fix video scaler

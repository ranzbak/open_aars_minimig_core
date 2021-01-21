# Minimig core for the Open AARS board

## Introduction

This Project contains the ported Minimig core originally written by Dennis van Weeren.
The core has been altered to work on the [QMTech](http://www.chinaqmtech.com/)
XC7100T FPGA core board and the Open AARS (Adaptive Amiga Retro System) IO board.
The design for the IO board can be found here :
[https://github.com/ranzbak/qmtech_minimig](The V4.0 Light version).

## Core

At this moment most of the Minimig core is stock.
The changes are mostly related to interface the core with the HDMI, I2S and joystick over I2C interfaces.

## Board

The Hardware provides:

- 24-bit HDMI video output ADV7511 (max 720p)
- micro-SDCARD slot
- High quality audio output via the MAX9850
- 2 Joystick ports running on 5V so joysticks with auto fire work correctly
- 2 PS/2 ports, to connect a keyboard and mouse
- 32 Mb SDRAM on the Open AARS board
- Interface for an physical Amiga floppy drive, including 12V voltage pump
- Serial over usb communication port
- PMOD connector to add custom peripherals

## TODO

- Use the host CPU to control the I2C interface
- Use 24bit video from the Minimig core
- Change Minimig logo to OpenAARS
- Connect floppy controller pins to internal signals
- Adjust audio volume via OSD
- Adjust screen positioning and scaling via OSD
- Enable OSD via the button on the PCB
- Possibility to use the native native floppy interface
- Volume control via the OSD menu
- AGA chip set support
- Addition of an ESP32 providing a WIFI interface
- Adding the DDR3 ram as fast ram to the emulator

## Issues to be fixed

- Stabilize the image as it's flickering from the interlaced source signal
- The PS/2 mouse interface does not work (Add pull ups??)
- Hard disk LED remains lit, and does not show activity

## Issues fixed

- Joystick interface is unstable
- Sometimes using the fire button results in the OSD menu appearing
- The original Amiga mouse does not work on joystick port
- Image appears too low on display implement vertical translation
- Image is too narrow, fix video scaler
- Timing in video upscaler is not being met
- machine crashes when the audio plug is inserted or removed (Won't fix)

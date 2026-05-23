# instrumentation-amplifier

#### Implementation of an instrumentation Amplififer with PWM-generated differential and common-mode noise source

![Figure what](https://github.com/PhilippeGRLX/instrumentation-amplifier/blob/main/docs/images/Hero_image.png "Figure")

## Introduction

The aim of this repo is to help the hobbyist or student build a strong understanding of instrumentation amplifiers. It also presents a practical method to generate clean sinusoidal signals using a microcontroller and analog filtering techniques.


## Table of Contents


## System overview
### Basics of PWM

### Generating sinusoidal signals from filtered PWM carriers
The Arduino generates two high-frequency PWM carrier signals.

Instead of directly producing analog voltages, the PWM duty cycle is dynamically modulated using sinusoidal lookup tables.

After analog filtering, the low-frequency sinusoidal envelopes are recovered while the high-frequency PWM carriers are attenuated.

-Add Figure: 60Hz and 1kHz envelopes, their BP filters and visible attenuation of PWM frequency.

### Analog Filter Stages
#### First-order active high-pass filter

<p align="center">
  <img src="docs/images/HP_60Hz.png" width="49%" />
  <img src="docs/images/HP_1kHz.png" width="49%" />
</p>

#### First-order active low-pass filter
![Figure what](https://github.com/PhilippeGRLX/instrumentation-amplifier/blob/main/docs/images/LP_60Hz.png "Figure")

#### Second-order Sallen-Key low-pass filter
![Figure what](https://github.com/PhilippeGRLX/instrumentation-amplifier/blob/main/docs/images/LP_1kHz.png "Figure")

### Differential signal generator
![Figure what](https://github.com/PhilippeGRLX/instrumentation-amplifier/blob/main/docs/images/Differential_signal_Generator.png "Figure")

### Instrumentation Amplifier

## CMRR and Measured Performance

## Testing the Signal
### Viewing PWM carrier signals
### Viewing filtered sinusoidal signals
### Viewing noisy differential signals
### Viewing common-mode attenuation

## Hardware Implementation
### Breadboard Prototype
### PCB Design
#### Signal Generator
![Figure what](https://github.com/PhilippeGRLX/instrumentation-amplifier/blob/main/docs/images/Common_Mode_Differential_Signal_Generator.png "Figure")
#### Instrumentation Amplifier
![Figure what](https://github.com/PhilippeGRLX/instrumentation-amplifier/blob/main/docs/images/Instrumentation_Amplifier.png "Figure")
#### Performance

## Compatibility
## Safety
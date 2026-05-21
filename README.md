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
#### First-order active low-pass filter
#### Second-order Sallen-Key low-pass filter

### Differential signal generator

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
#### Performance

## Compatibility
## Safety
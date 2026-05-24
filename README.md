# Instrumentation Amplifier Test Bench with Microcontroller-Based Differential Signal Generator

#### Implementation of an instrumentation amplififer with PWM-generated differential and common-mode noise source

![Figure what](https://github.com/PhilippeGRLX/instrumentation-amplifier/blob/main/docs/images/Hero_image.png "Figure")

## Introduction

The aim of this repository is to help students, hobbyists and engineers build
a practical understanding of instrumentation amplifiers, differential signal
generation and common-mode rejection.

This project combines:
- microcontroller-based PWM signal generation,
- analog filtering techniques,
- differential and common-mode signal synthesis,
- and experimental instrumentation amplifier validation.

The generated signals are specifically designed to bench-test a 3-op-amp
instrumentation amplifier architecture under controlled noisy conditions.

Two sinusoidal envelopes (~60 Hz and ~1 kHz) are reconstructed from PWM
carrier signals using analog filter stages. These signals are then combined
into differential and common-mode components in order to experimentally
evaluate common-mode rejection and signal recovery performance.

The repository also documents the complete hardware implementation,
including:
- breadboard prototyping,
- PCB design,
- firmware generation,
- analog filtering,
- and experimental validation.

## Table of Contents

- [Introduction](#introduction)

- [System Overview](#system-overview)
  - [Basics of PWM](#basics-of-pwm)
  - [Generating Sinusoidal Signals from Filtered PWM Carriers](#generating-sinusoidal-signals-from-filtered-pwm-carriers)
  - [Analog Filter Stages](#analog-filter-stages)
    - [First-Order Active High-Pass Filter](#first-order-active-high-pass-filter)
    - [First-Order Active Low-Pass Filter](#first-order-active-low-pass-filter)
    - [Second-Order Sallen-Key Low-Pass Filter](#second-order-sallen-key-low-pass-filter)

- [Differential Signal Generator](#differential-signal-generator)

- [Instrumentation Amplifier](#instrumentation-amplifier)

- [CMRR and Measured Performance](#cmrr-and-measured-performance)

- [Testing the Signal](#testing-the-signal)
  - [Viewing PWM Carrier Signals](#viewing-pwm-carrier-signals)
  - [Viewing Filtered Sinusoidal Signals](#viewing-filtered-sinusoidal-signals)
  - [Viewing Noisy Differential Signals](#viewing-noisy-differential-signals)
  - [Viewing Common-Mode Attenuation](#viewing-common-mode-attenuation)

- [Hardware Implementation](#hardware-implementation)
  - [Breadboard Prototype](#breadboard-prototype)
  - [PCB Design](#pcb-design)
    - [Signal Generator](#signal-generator)
    - [Instrumentation Amplifier](#instrumentation-amplifier-1)
    - [Performance](#performance)

- [Compatibility](#compatibility)

- [Safety](#safety)

- [Acknowledgements](#acknowledgements)


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

The first-order active high-pass filters are used to attenuate low-frequency components and remove DC offsets before the low-pass reconstruction stages.

Transfer function:

$$
H(s)=\frac{-R_f C_1 s}{1+R_1 C_1 s}
$$

Cutoff frequency:

$$
f_c=\frac{1}{2\pi R_1 C_1}
$$


| Filter | Design cutoff frequency |
|---|---|
| 60 Hz path | 19 Hz |
| 1 kHz path | 19 Hz |


#### First-order active low-pass filter
![Figure what](https://github.com/PhilippeGRLX/instrumentation-amplifier/blob/main/docs/images/LP_60Hz.png "Figure")

The first-order active low-pass filter is used to attenuate the high-frequency PWM carrier while preserving the reconstructed sinusoidal envelope.

Transfer function:

$$
H(s)=\frac{-R_f}{R_2}\frac{1}{1+R_f C_f s}
$$

Cutoff frequency:

$$
f_c=\frac{1}{2\pi R_f C_f}
$$

| Filter | Design cutoff frequency |
|---|---|
| 60 Hz path | 164 Hz |



#### Second-order Sallen-Key low-pass filter
![Figure what](https://github.com/PhilippeGRLX/instrumentation-amplifier/blob/main/docs/images/LP_1kHz.png "Figure")

The second-order Sallen-Key low-pass filter is used to provide stronger attenuation of the high-frequency PWM carrier while preserving the 1 kHz sinusoidal envelope.

Transfer function:

$$
T(s)=\frac{K G_1 G_2 / C^2}{s^2+s\frac{G_1+G_2(2-K)}{C}+\frac{G_1G_2}{C^2}}
$$

where:

$$
G_1=\frac{1}{R_1}, \qquad G_2=\frac{1}{R_2}
$$

Cutoff frequency:

$$
f_c=\frac{1}{2\pi\sqrt{R_1 R_2 C_1 C_2}}
$$

| Filter | Design cutoff frequency |
|---|---|
| 1 kHz path | 2 kHz |


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
## Acknowledgements

Parts of this project were inspired by laboratory material and concepts
developed for the course:

**GEL-3000 - Électronique des composants intégrés (Univeristé Laval)**

Special thanks to:
- Prof. Benoit Gosselin
- Sébastien Rigaut
- Michelle Janusz
- Antoine Lefloïc

for their contributions to the original laboratory framework and educational material.

This repository extends and adapts those concepts into a standalone experimental
instrumentation amplifier and signal-generation test bench.


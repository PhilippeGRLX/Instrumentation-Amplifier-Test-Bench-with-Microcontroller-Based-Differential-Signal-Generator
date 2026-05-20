# instrumentation-amplifier
3-op-amp instrumentation amplifier with PWM-generated differential and common-mode noise source.


#### Implementation of an instrumentation Amplififer with PWM-generated differential and common-mode noise source

![Figure what](https://github.com/Terbytes/Arduino-Atmel-sPWM/blob/master/im/pulses_1.JPG?raw=true "Figure")

## Introduction

The aim of this repo is to help the hobbyist or student make rapid progress in implementing an sPWM signal on a arduino or atmel micro, while making sure that the theory behind the sPWM and the code itself is understood. 

Please also note that:

 * It's assumed the reader has a basic understanding of C programming
 * If you plan on making an inverter please read the safety section
 * Feel free to collaborate on improving this repo


## Table of Contents
<!-- toc -->
* [Brief Theory](#brief-theory)
    - [Basic PWM](#basic-pwm)
    - [Typical micro implementation](#typical-microcontroller-pwm-implementation)
    - [Sinusoidal PWM](#sinusoidal-pwm)
* [Code & Explanation](#code-and-explanation)
    - [sPWM_Basic](#spwm_basic)
    - [sPWM_Generate_Lookup_Table](#spwm_generate_lookup_table)
* [Testing the Signal](#testing-the-signal)
    - [Viewing Pulse Widths with an Osilloscope](#viewing-pulse-widths-with-an-osilloscope)
    - [Viewing the Filtered Signal with an Oscilloscope](#viewing-the-filtered-signal-with-an-oscilloscope)
    - [Listening to the Signal](#listening-to-the-signal)
* [Compatibility](#compatibility)
* [Safety](#safety)

<!-- tocstop -->
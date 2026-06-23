/*
------------------------------------------------------------------------------
Project:
Instrumentation Amplifier Test Bench with Microcontroller-Based Differential
Signal Generator

File:
pwm_signal_generator.ino

Description:
This firmware generates two PWM-modulated sinusoidal signals using Timer1
on the Arduino Uno.

The PWM duty cycles are updated from lookup tables (LUTs) in order to
reconstruct low-frequency sinusoidal envelopes after analog filtering.

Generated signals:
- ~60 Hz sinusoidal envelope on pin 9 (OC1A)
- ~1 kHz sinusoidal envelope on pin 10 (OC1B)

The generated PWM signals are intended to drive analog filter stages used
for differential and common-mode signal generation.

Hardware:
- Arduino Uno
- Timer1 Fast PWM mode
- PWM outputs:
    Pin 9  -> 60 Hz path
    Pin 10 -> 1 kHz path

Author:
Philippe Groulx-Letourneau

Repository:
github.com/PhilippeGRLX/Instrumentation-Amplifier-Test-Bench-with-Microcontroller-Based-Differential-Signal-Generator

------------------------------------------------------------------------------
Acknowledgements

Parts of the PWM generation framework used in this project was adapted
from laboratory material developed for the course:

"GEL-3000 - Électronique des composants intégrés (Université Laval)"

Contributors to the original laboratory material:
- Prof. Benoit Gosselin
- Sébastien Rigaut
- Michelle Janusz
- Antoine Lefloïc

The firmware has since been modified and extended for this project.
------------------------------------------------------------------------------
*/




// -----------------------------------------------------------------------------
// Setup
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// Lookup Tables
// -----------------------------------------------------------------------------

#include "lookup_tables/f60Hz.h"
#include "lookup_tables/f1kHz.h"

// -----------------------------------------------------------------------------
// PWM Output Pins
// -----------------------------------------------------------------------------

#define PWM_60HZ_PIN 9   // OC1A
#define PWM_1KHZ_PIN 10  // OC1B

void setup() {
  pinMode(PWM_60HZ_PIN, OUTPUT);
  pinMode(PWM_1KHZ_PIN, OUTPUT);
  pinMode(LED_BUILTIN, OUTPUT);

  noInterrupts();

// -----------------------------------------------------------------------------
// Timer1 Configuration
// Fast PWM 10-bit mode
// PWM frequency ≈ 15.625 kHz
// -----------------------------------------------------------------------------

  // Fast PWM 10-bit, Timer1, prescaler = 1
  TCCR1A =
    (1 << COM1A1) |  // Enable PWM on pin 9
    (1 << COM1B1) |  // Enable PWM on pin 10
    (1 << WGM11)  |
    (1 << WGM10);

  TCCR1B =
    (1 << WGM12) |
    (1 << CS10);     // Prescaler = 1

  TIMSK1 =
    (1 << TOIE1);    // Overflow interrupt ON



  interrupts();
}

// -----------------------------------------------------------------------------
// Main Loop
// -----------------------------------------------------------------------------

void loop() {}

// -----------------------------------------------------------------------------
// Timer1 Overflow Interrupt
// Updates PWM duty cycles from LUTs
// -----------------------------------------------------------------------------

ISR(TIMER1_OVF_vect) {
  static uint16_t i60 = 0;
  static uint16_t i1k = 0;

  OCR1A = LUT_f60Hz[i60];   // Pin 9
  OCR1B = LUT_f1kHz[i1k];   // Pin 10

  i60++;
  if (i60 >= N_SINE_60HZ) i60 = 0;

  i1k++;
  if (i1k >= N_SINE_1KHZ) i1k = 0;

  digitalWrite(LED_BUILTIN, i60 % 2);
}
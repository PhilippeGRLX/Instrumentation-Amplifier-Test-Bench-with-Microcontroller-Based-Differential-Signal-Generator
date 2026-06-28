/*
------------------------------------------------------------------------------
Project:
Instrumentation Amplifier Test Bench with Microcontroller-Based Differential
Signal Generator

File:
pwm_signal_generator.ino

Description:
This firmware generates two PWM-modulated sinusoidal signals using hardware
timers on the Arduino Uno.

The 60 Hz signal path uses Timer1 in 10-bit Fast PWM mode. This preserves the
original higher duty-cycle resolution used for the common-mode signal.

The 1 kHz signal path uses Timer2 in 8-bit Fast PWM mode. This increases the
PWM carrier frequency to approximately 62.5 kHz, providing more lookup-table
updates per sine period and improving analog reconstruction of the 1 kHz signal.

The PWM duty cycles are updated from lookup tables (LUTs). After analog
filtering, the average value of each PWM waveform is reconstructed as a
low-frequency sinusoidal envelope.

Generated signals:
- ~60 Hz sinusoidal envelope on pin 9  (OC1A / Timer1)
- ~1 kHz sinusoidal envelope on pin 3  (OC2B / Timer2)

Hardware:
- Arduino Uno
- Timer1 Fast PWM 10-bit mode for the 60 Hz path
- Timer2 Fast PWM 8-bit mode for the 1 kHz path
- PWM outputs:
    Pin 9 -> 60 Hz path
    Pin 3 -> 1 kHz path

Author:
Philippe Groulx-Letourneau

Repository:
github.com/PhilippeGRLX/Instrumentation-Amplifier-Test-Bench-with-Microcontroller-Based-Differential-Signal-Generator

------------------------------------------------------------------------------
Acknowledgements

Parts of the PWM generation framework used in this project were adapted
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

#define PWM_60HZ_PIN 9   // OC1A - Timer1
#define PWM_1KHZ_PIN 3   // OC2B - Timer2

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
    (1 << WGM11)  |
    (1 << WGM10);

  TCCR1B =
    (1 << WGM12) |
    (1 << CS10);     // Prescaler = 1

  TIMSK1 =
    (1 << TOIE1);    // Overflow interrupt ON
// -----------------------------------------------------------------------------
// Timer2 Configuration
// Fast PWM 8-bit mode
// PWM frequency = 16 MHz / 256 = 62.5 kHz
// Pin 3 = OC2B
// -----------------------------------------------------------------------------
TCCR2A =
  (1 << COM2B1) |  // Enable PWM on pin 3
  (1 << WGM21)  |
  (1 << WGM20);

TCCR2B =
  (1 << CS20);     // Prescaler = 1

TIMSK2 =
  (1 << TOIE2);    // Timer2 overflow interrupt ON



  interrupts();
}

// -----------------------------------------------------------------------------
// Main Loop
// -----------------------------------------------------------------------------

void loop() {}

// -----------------------------------------------------------------------------
// Timer1 Overflow Interrupt
// Updates the 60 Hz PWM duty cycle
// -----------------------------------------------------------------------------

ISR(TIMER1_OVF_vect) {
  static uint16_t i60 = 0;

  OCR1A = LUT_f60Hz[i60];   // Pin 9

  i60++;
  if (i60 >= N_SINE_60HZ) i60 = 0;
}

// -----------------------------------------------------------------------------
// Timer2 Overflow Interrupt
// Updates the 1 kHz PWM duty cycle
// -----------------------------------------------------------------------------

ISR(TIMER2_OVF_vect) {
  static uint16_t i1k = 0;

  OCR2B = LUT_f1kHz[i1k];   // Pin 3

  i1k++;
  if (i1k >= N_SINE_1KHZ) i1k = 0;
}

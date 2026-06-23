#ifndef F1KHZ_H
#define F1KHZ_H

#include <stdint.h>

#define N_SINE_1KHZ 16

uint16_t LUT_f1kHz[N_SINE_1KHZ] = {
  512, 698, 850, 950,
  985, 950, 850, 698,
  512, 326, 174, 74,
  39, 74, 174, 326
};

#endif // F1KHZ_H
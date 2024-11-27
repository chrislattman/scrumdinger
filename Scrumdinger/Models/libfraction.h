//
//  libfraction.h
//  Scrumdinger
//
//  Created by Chris Lattman on 11/26/24.
//

#ifndef libfraction_h
#define libfraction_h

#include <stdio.h>

typedef struct fraction {
    int numerator, denominator;
    const char *str;
    void (*print_func)(const char *);
} Fraction;

int fraction_multiply(Fraction *frac1, Fraction *frac2);

#endif /* libfraction_h */

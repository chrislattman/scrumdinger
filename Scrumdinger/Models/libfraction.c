//
//  libfraction.c
//  Scrumdinger
//
//  Created by Chris Lattman on 11/26/24.
//

#include "libfraction.h"

int fraction_multiply(Fraction *frac1, Fraction *frac2) {
    if (frac1 != NULL && frac2 != NULL) {
        int numerator = frac1->numerator * frac2->numerator;
        int denominator = frac1->denominator * frac2->denominator;
        frac1->numerator = numerator;
        frac1->denominator = denominator;
        frac1->print_func(frac1->str);
        frac2->print_func(frac2->str);
        printf("Finished with calculation!\n");
        return 0;
    }
    return -1;
}

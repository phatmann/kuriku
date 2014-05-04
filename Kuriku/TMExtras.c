//
//  TMExtras.c
//  Kuriku
//
//  Created by Tony Mann on 4/29/14.
//  Copyright (c) 2014 7Actions. All rights reserved.
//

#include "TMExtras.h"
#include <math.h>

float fclampf(float x, float min, float max)
{
    return fmaxf(min, fminf(max, x));
}

float fratiof(float x)
{
    return fclampf(x, 0.0, 1.0);
}

float fstretchf(float x, float y)
{
    return x + copysignf(y, x);
}

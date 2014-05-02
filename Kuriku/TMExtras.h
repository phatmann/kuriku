//
//  TMExtras.h
//  Kuriku
//
//  Created by Tony Mann on 4/29/14.
//  Copyright (c) 2014 7Actions. All rights reserved.
//

#ifndef Kuriku_TMExtras_h
#define Kuriku_TMExtras_h

extern float fclampf(float, float, float);
extern float fratiof(float);

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle)   ((angle) / 180.0 * M_PI)

#endif

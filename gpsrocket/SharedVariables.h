//
//  Utility.h
//  BTT
//
//  Created by Wen Shane on 12-12-10.
//  Copyright (c) 2012年 Wen Shane. All rights reserved.
//

#ifndef SHARED_VARIABLES_H
#define SHARED_VARIABLES_H

#define RGB_DIV_255(x)      ((CGFloat)(x/255.0))

#define RGBA_COLOR(r, g, b, a)   ([UIColor colorWithRed:RGB_DIV_255(r) green:RGB_DIV_255(g) blue:RGB_DIV_255(b) alpha:a])



#define COLOR_FLOAT_BUTTON_ON_MAP        RGBA_COLOR(0, 0, 0, 0.6)

#define COLOR_GRADIENT_START_INFO_BOARD     RGBA_COLOR(0, 0, 0, 0.7)

#define COLOR_GRADIENT_END_INFO_BOARD       RGBA_COLOR(0, 0, 0, 0.0)


#endif

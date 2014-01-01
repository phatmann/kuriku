//
//  main.m
//  Kuriku
//
//  Created by Tony Mann on 12/11/13.
//  Copyright (c) 2013 7Actions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Pixate/Pixate.h>
#import "KurikuAppDelegate.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {
        [Pixate licenseKey:@"ACIHO-UM2H7-508SK-4AU5M-1UD47-PJSAE-LRQV0-FNBB3-KABQ9-5HJBM-3OEDO-50CIM-2IE1U-HMA4T-ISO7O-P0" forUser:@"thephatmann@gmail.com"];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([KurikuAppDelegate class]));
    }
}

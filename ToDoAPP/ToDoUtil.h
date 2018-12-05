//
//  ToDoUtil.h
//  ToDoAPP
//
//  Created by apple on 05/12/18.
//  Copyright © 2018 Kaushal Kumar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ToDoUtil : NSObject

- (void) showAlertMsg:(UIViewController *)viewController title:(NSString *)title message:(NSString *)message;
-(NSString *)timeStampDate :(double)timestamp;
@end

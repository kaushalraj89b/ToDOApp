//
//  ToDoUtil.m
//  ToDoAPP
//
//  Created by apple on 05/12/18.
//  Copyright © 2018 Kaushal Kumar. All rights reserved.
//

#import "ToDoUtil.h"

@implementation ToDoUtil

//Alert function

- (void) showAlertMsg:(UIViewController *)viewController title:(NSString *)title message:(NSString *)message {
    
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:title
                                 message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* cancelButton = [UIAlertAction
                               actionWithTitle:@"Ok"
                               style:UIAlertActionStyleCancel
                               handler:^(UIAlertAction * action) {
                                   //Handle no, thanks button
                               }];
    
    //Add your buttons to alert controller
    [alert addAction:cancelButton];
    [viewController presentViewController:alert animated:YES completion:nil];
}

-(NSString *)timeStampDate :(double)timestamp{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:(timestamp / 1000)];
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc]init];
    [dateformatter setTimeZone:[NSTimeZone timeZoneWithName:@"IST"]];
    [dateformatter setLocale:[NSLocale currentLocale]];
    [dateformatter setDateFormat:@"HH:mm dd-MMM-yyyy"];
    NSString *dateString=[dateformatter stringFromDate:date];
    return dateString;
}

@end

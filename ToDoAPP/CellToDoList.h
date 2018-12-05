//
//  CellToDoList.h
//  ToDoAPP
//
//  Created by apple on 30/11/18.
//  Copyright © 2018 Kaushal Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CellToDoList : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblToDoItem;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UIButton *btnEdit;
@property (weak, nonatomic) IBOutlet UIButton *btnDelete;

@end

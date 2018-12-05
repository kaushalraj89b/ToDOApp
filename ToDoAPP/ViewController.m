//
//  ViewController.m
//  ToDoAPP
//
//  Created by apple on 30/11/18.
//  Copyright © 2018 Kaushal Kumar. All rights reserved.
//

#import "ViewController.h"
#import "CellToDoList.h"
#import "ToDoUtil.h"
@import Firebase;


@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>{
    int _msglength;
    FIRDatabaseHandle _refHandle;
    NSString *updateString;
    ToDoUtil *util;
}
@property (weak, nonatomic) IBOutlet UITextField *txtFldToDo;
@property (weak, nonatomic) IBOutlet UITableView *tableVwToDo;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) NSMutableArray<FIRDataSnapshot *>  *ToDoLists;
@property (strong, nonatomic) FIRStorageReference *storageRef;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"ToDoList";
    util = [ToDoUtil new];
    _ToDoLists = [NSMutableArray new];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureDatabase];
    self.txtFldToDo.delegate = (id)self;
    _tableVwToDo.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureDatabase {
    [FIRDatabase database].persistenceEnabled = YES;
    _ref = [[FIRDatabase database] referenceWithPath:@"ToDoList"];
    [_ref keepSynced:YES];
    [self getToDoList];
}


- (void)addToDoList:(NSDictionary *)data {
    [[_ref child:[data valueForKey:@"key"] ] setValue:data];
    self.txtFldToDo.text = nil;
    [self getToDoList];
}


-(void)getToDoList{
    [[[_ref queryOrderedByValue] queryLimitedToLast:10]  observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        // Get user value
        if (snapshot.value != [NSNull null]){
            NSMutableDictionary *ToDoDict = snapshot.value;
            NSArray *tempArray = [ToDoDict.allValues mutableCopy];
            _ToDoLists  = [tempArray mutableCopy];
        }else{
            _ToDoLists = nil;
        }
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:TRUE];
        [_ToDoLists sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        self.tableVwToDo.delegate = self;
        self.tableVwToDo.dataSource = self;
        [self.tableVwToDo reloadData];
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
    
}


#pragma mark - ButtonAction -
-(IBAction)addToDoListAction:(id)sender{
    
    if (_txtFldToDo.text && (_txtFldToDo.text.length > 0)) {
        NSString *keyVal = _ref.childByAutoId.key;
        NSString *toDoString = self.txtFldToDo.text;
        long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
        NSMutableDictionary *dataDict = [[NSMutableDictionary alloc]initWithCapacity:3];
        [dataDict setObject:keyVal forKey:@"key"];
        [dataDict setObject:toDoString forKey:@"text"];
        [dataDict setObject:[NSString stringWithFormat:@"%lld",milliseconds] forKey:@"timestamp"];
        [self addToDoList:dataDict];
    }else{
        [util showAlertMsg:self title:@"Alert!" message:@"Add new item Field must not have empty"];
        self.txtFldToDo.text = nil;
    }
}

-(IBAction)updateToDoList:(id)sender{
    UIButton *btn = (UIButton *)sender;
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Update"
                                 message:@"Are You Sure Want to Update!"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Add New Item";
        NSString *text = [_ToDoLists[btn.tag] valueForKey:@"text"];
        textField.text = text;
        textField.delegate = (id) self;
        textField.textColor = [UIColor blackColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleRoundedRect;
    }];
    UIAlertAction* updateButton = [UIAlertAction
                                   actionWithTitle:@"Update"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       
                                       NSString *key = [_ToDoLists[btn.tag] valueForKey:@"key"];
                                       NSString  *timeStamp = [_ToDoLists[btn.tag] valueForKey:@"timestamp"];
                                       NSDictionary *post = @{@"text": updateString,@"key":key,@"timestamp":timeStamp};
                                       NSDictionary *childUpdates = @{ key: post };
                                       if(updateString && updateString.length > 0){
                                           [_ref updateChildValues:childUpdates];
                                           [self getToDoList];
                                       }else{
                                           [util showAlertMsg:self title:@"Alert!" message:@"Update item Field must not have empty"];
                                       }
                                   }];
    
    UIAlertAction* cancelButton = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       
                                   }];
    
    //Add your buttons to alert controller
    [alert addAction:updateButton];
    [alert addAction:cancelButton];
    [self presentViewController:alert animated:YES completion:nil];
    
}


-(IBAction)deleteElementOfToDoList:(id)sender{
    UIButton *btn = (UIButton *)sender;
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Delete"
                                 message:@"Are You Sure Want to Delete!"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    
    
    UIAlertAction* DeleteButton = [UIAlertAction
                                   actionWithTitle:@"Delete"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       NSString *key = [_ToDoLists[btn.tag] valueForKey:@"key"];
                                       [[_ref child:key] removeValue];
                                       [self getToDoList];
                                       
                                   }];
    
    UIAlertAction* cancelButton = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       
                                   }];
    
    //Add your buttons to alert controller
    
    [alert addAction:DeleteButton];
    [alert addAction:cancelButton];
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - UITableviewDelegates and DataSource -

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CellToDoList *cell = [tableView dequeueReusableCellWithIdentifier:@"CellToDoList"];
    if(cell == nil) {
        cell = [[CellToDoList alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellToDoList"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.lblToDoItem.text = [_ToDoLists[indexPath.row] valueForKey:@"text"];
    cell.lblDate.text = [util timeStampDate:[[_ToDoLists[indexPath.row] valueForKey:@"timestamp"] doubleValue]];
    
    [cell.btnEdit addTarget:self action:@selector(updateToDoList:) forControlEvents:UIControlEventTouchUpInside];
    cell.btnEdit.tag = indexPath.row;
    
        [cell.btnDelete addTarget:self action:@selector(deleteElementOfToDoList:) forControlEvents:UIControlEventTouchUpInside];
    cell.btnDelete.tag = indexPath.row;
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _ToDoLists.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70.0;
}

#pragma mark - UITextFieldDelegates -

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    updateString = textField.text;
    
}
@end

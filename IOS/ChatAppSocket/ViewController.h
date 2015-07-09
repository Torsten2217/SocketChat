//
//  ViewController.h
//  ChatAppSocket
//
//  Created by Juseman on 10/03/15.
//  Copyright (c) 2015 azizdev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <NSStreamDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UIView *joinView;
@property (strong, nonatomic) IBOutlet UIView *listView;
@property (strong, nonatomic) IBOutlet UIView *chatView;

@property (strong, nonatomic) IBOutlet UITextField *chatRoomName;
@property (strong, nonatomic) IBOutlet UITextField *shareName;
@property (strong, nonatomic) IBOutlet UITextField *secretName;
@property (strong, nonatomic) IBOutlet UITextField *userName;
@property (strong, nonatomic) IBOutlet UIButton *joinButton;

@property (strong, nonatomic) IBOutlet UITableView *memberTable;
@property (strong, nonatomic) IBOutlet UILabel *roomLabel;

@property (strong, nonatomic) IBOutlet UILabel *destName;
@property (strong, nonatomic) IBOutlet UITableView *chatTable;
@property (strong, nonatomic) IBOutlet UIButton *returnButton;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) IBOutlet UITextField *inputMessageField;

@property (nonatomic, retain) NSInputStream *inputStream;
@property (nonatomic, retain) NSOutputStream *outputStream;

@property (nonatomic, retain) NSMutableArray *msgsUsers;
@property (nonatomic, retain) NSMutableArray *msgsChats;
@property (nonatomic) UITapGestureRecognizer *tapRecognizer;

- (IBAction) joinChat;
- (void) initNetworkCommunication;
- (IBAction) sendMessage;
- (void) messageReceived:(NSString *)message;
- (IBAction) returnClicked;
- (IBAction)returnFront:(id)sender;
- (IBAction)exit:(id)sender;

@end


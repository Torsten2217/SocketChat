//
//  ViewController.m
//  ChatAppSocket
//
//  Created by Juseman on 10/03/15.
//  Copyright (c) 2015 azizdev. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
-(void)moveViewWithGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer;
@end

@implementation ViewController

@synthesize joinView, listView, chatView;
@synthesize chatRoomName, shareName, secretName, userName, destName;
@synthesize memberTable, roomLabel, chatTable, inputMessageField;
@synthesize inputStream, outputStream;
@synthesize msgsChats, msgsUsers;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNetworkCommunication];
    msgsChats = [[NSMutableArray alloc] init];
    msgsUsers = [[NSMutableArray alloc] init];
    self.memberTable.delegate = self;
    self.memberTable.dataSource = self;
    self.chatTable.delegate = self;
    self.chatTable.dataSource = self;
    _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAnywhere:)];
    _tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:_tapRecognizer];
    //you can change constant string here.
    
    chatRoomName.text = @"friends";
    shareName.text = @"study";
    secretName.text = @"maria";
    userName.text = @"Juseman";
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveViewWithGestureRecognizer:)];
    [self.view addGestureRecognizer:panGestureRecognizer];
}

- (BOOL) prefersStatusBarHidden{
    return YES;
}

- (void) didTapAnywhere:(UITapGestureRecognizer*)sender{
    [self.view endEditing:YES];
}

-(void)moveViewWithGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGRect rect = self.view.frame;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.1];
    CGPoint velocity = [panGestureRecognizer velocityInView:self.view];
    rect.origin.y += velocity.y/30;
    self.view.frame = rect;
    [UIView commitAnimations];
}

- (void) initNetworkCommunication {
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    //please change address and port.
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"192.185.41.235", 50000, &readStream, &writeStream);
    //CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"127.0.0.1", 50000, &readStream, &writeStream);
    inputStream = (__bridge NSInputStream *)readStream;
    outputStream = (__bridge NSOutputStream *)(writeStream);
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream open];
    [outputStream open];
 }

- (IBAction) joinChat{
    if ([self checkBlank]) {
        [self.view bringSubviewToFront:listView];
        [self.memberTable reloadData];
        roomLabel.text = chatRoomName.text;
        NSString *response = [NSString stringWithFormat:@"iam::%@::%@::%@::%@", chatRoomName.text, shareName.text, secretName.text, userName.text];
        NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
        [outputStream write:[data bytes] maxLength:[data length]];
    }
    else{
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please fill all fields." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
}

- (void) upOrDownY:(NSInteger) yoff{
    CGRect rect = self.view.frame;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.1];
    rect.origin.y += yoff;
    self.view.frame = rect;
    [UIView commitAnimations];
}

- (BOOL) checkBlank{
    if ([chatRoomName.text isEqualToString:@""] || [shareName.text isEqualToString:@""] ||[secretName.text isEqualToString:@""] || [userName.text isEqualToString:@""] ) {
        return FALSE;
    }
    return TRUE;
}

- (IBAction) sendMessage{
    if ( ![inputMessageField.text isEqualToString:@""] ) {
        NSString *response  = [NSString stringWithFormat:@"msg::%@::%@::%@::%@", chatRoomName.text, userName.text, destName.text, inputMessageField.text];
        NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
        [outputStream write:[data bytes] maxLength:[data length]];
        [self.msgsChats addObject:[@"send:" stringByAppendingString:inputMessageField.text]];
        [self.chatTable reloadData];
        inputMessageField.text = @"";
    }
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    
    NSLog(@"stream event %u", streamEvent);
    switch (streamEvent) {
            
        case NSStreamEventOpenCompleted:
            NSLog(@"Stream opened");
            break;
        case NSStreamEventHasBytesAvailable:
            if (theStream == inputStream) {
                uint8_t buffer[1024];
                int len;
                while ([inputStream hasBytesAvailable]) {
                    len = [inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        if (nil != output) {
                            NSLog(@"server said: %@", output);
                            [self messageReceived:output];                            
                        }
                    }
                }
            }
            break;
        case NSStreamEventErrorOccurred:
            NSLog(@"Can not connect to the host!");
            break;            
        case NSStreamEventEndEncountered:
            [theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            theStream = nil;
            break;
        default:
            NSLog(@"Unknown event");
    }    
}

- (void) messageReceived:(NSString *)message{
    NSArray *prefixes =[message componentsSeparatedByString:@"::"];
    NSString *prefix = [prefixes objectAtIndex:0];
    if ([prefix isEqualToString:@"ok"]) {//users in chatroom
        [self.msgsUsers addObjectsFromArray:[prefixes subarrayWithRange:NSMakeRange(1, prefixes.count-1)]];
        //[self.msgsUsers removeObject:0];//perfix remove
        [self.memberTable reloadData];
        NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:msgsUsers.count-1 inSection:0];
        [self.memberTable scrollToRowAtIndexPath:topIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
    else if([prefix isEqualToString:@"msg"]){//chat messages
        if ([[prefixes objectAtIndex:1] isEqualToString:roomLabel.text] && [[prefixes objectAtIndex:2] isEqualToString:userName.text]) {
            [self.msgsChats addObject:[@"recv:" stringByAppendingString:[prefixes objectAtIndex:4]]];
            [self.chatTable reloadData];
            NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:msgsChats.count-1 inSection:0];
            [self.chatTable scrollToRowAtIndexPath:topIndexPath atScrollPosition:UITableViewScrollPositionMiddle
                                          animated:YES];
        }
    }
    else if([prefix isEqualToString:@"no"]){//no
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Register Alert!" message:@"Sorry, login failure.\nPlease try again after." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [self.view bringSubviewToFront:joinView];
    }
    else{//"err"
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Register Alert!" message:@"Sorry, enter correct login info." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [self.view bringSubviewToFront:joinView];
    }
}

- (IBAction) returnClicked{
    [self.msgsChats removeAllObjects];
    [self.chatTable reloadData];
    inputMessageField.text = @"";
    [self.view bringSubviewToFront:listView];
}

- (IBAction)returnFront:(id)sender {
    [self.msgsUsers removeAllObjects];
    [self.memberTable reloadData];
    [self.msgsChats removeAllObjects];
    [self.chatTable reloadData];
    roomLabel.text = @"";
    [self.view bringSubviewToFront:joinView];
}

- (IBAction)exit:(id)sender {
    NSString *response = @"exit";
    NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
    [outputStream write:[data bytes] maxLength:[data length]];
    exit(0);
}

#pragma mark -
#pragma mark Table delegates

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *str;
    if (tableView.tag == 1) {//memberTable
        str = [msgsUsers objectAtIndex:indexPath.row];
        static NSString *memberCellIdentifier = @"memberCellIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:memberCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:memberCellIdentifier];
        }
        [cell.textLabel setText:str];
        return cell;
    }
    else{//chattable tag = 2
        str = [msgsChats objectAtIndex:indexPath.row];
        NSString *prefix,*suffix;
        prefix = [str substringToIndex:3];
        suffix = [str substringFromIndex:5];
        static NSString *chatCellIdentifier = @"chatCellIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:chatCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:chatCellIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if ([prefix isEqualToString:@"send"]) {
            cell.textLabel.textAlignment = NSTextAlignmentRight;
            cell.textLabel.textColor = [UIColor brownColor];
        }
        else{//recv
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
            cell.textLabel.textColor = [UIColor greenColor];
        }
        cell.textLabel.text = suffix;
        return cell;
    }    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == 1) {//memberTable
        return msgsUsers.count;
    }
    else {//chatTable
        return msgsChats.count;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView.tag == 1) {//membersTable
        [msgsChats removeAllObjects];
        [self.view bringSubviewToFront:chatView];
        destName.text = [msgsUsers objectAtIndex:indexPath.row];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //all 30
    return 30;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

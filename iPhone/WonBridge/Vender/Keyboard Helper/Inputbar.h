//
//  Inputbar.h
//  Whatsapp
//
//  Created by Rafael Castro on 7/11/15.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//

#import <UIKit/UIKit.h>


//
// Thanks for HansPinckaers for creating an amazing
// Growing UITextView. This class just add design and
// notifications to uitoobar be similar to whatsapp
// inputbar.
//
// https://github.com/HansPinckaers/GrowingTextView
//

//@protocol InputbarDelegate;

@class Inputbar;

@protocol InputbarDelegate <NSObject>
- (void) inputbarDidPressSendButton:(Inputbar *) inputbar;
- (void) inputbarDidPressEmojiButton:(Inputbar *) inputbar;
- (void) inputbarDidPressLeftButton:(Inputbar *) inputbar;
- (void) inputbarDidPressFileSendButton:(Inputbar *) inputbar;
@optional
-(void)inputbarDidChangeHeight:(CGFloat)new_height;
-(void)inputbarDidBecomeFirstResponder:(Inputbar *)inputbar;
@end

@interface Inputbar : UIToolbar {

    int inputType;
    
    __unsafe_unretained NSObject <InputbarDelegate> *delegate;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic) NSString *placeholder;

@property (nonatomic) UIImage *leftButtonImage;

@property (nonatomic) UIImage *rightEmojiButtonImage;

@property (nonatomic) UIImage *rightSendButtonImage;
@property (nonatomic) UIImage *rightSendButtonSelectedImage;

@property (nonatomic) NSString *rightButtonText;
@property (nonatomic) UIColor *rightButtonTextColor;

@property (nonatomic) BOOL sendStatus;

- (void) becomeFirstResponder;
- (void) resignFirstResponder;


-(NSString *)text;

//- (void) setSendState:(BOOL) state;

- (void) beginEditting;

- (void) changeInputType:(int) inputType;

@end






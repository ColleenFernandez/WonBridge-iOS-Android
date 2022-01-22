//
//  Inputbar.h
//  Whatsapp
//
//  Created by Rafael Castro on 7/11/15.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//

#import "Inputbar.h"
#import "HPGrowingTextView.h"

@interface Inputbar() <HPGrowingTextViewDelegate>

@property (nonatomic, strong) HPGrowingTextView *textView;

@property (nonatomic, strong) UIView *backgroundView;       // background view

@property (nonatomic, strong) UIButton *imageButton;        // button for sending image or video

@property (nonatomic, strong) UIButton *rightSendButton;    // button for sending text message

@property (nonatomic, strong) UIButton *rightEmojiButton;   // button for switching keyboard

@property (nonatomic, strong) UIButton *leftButton;         // plus button

@property (nonatomic, strong) UIButton *rightButton;        // image or video send button

@end

#define RIGHT_BUTTON_SIZE 30
#define LEFT_BUTTON_SIZE 44   // 16 - left margin, 14 - button size, 14 - right margin

#define RIGHT_GALLERY_BUTTON_SIZE 68

@implementation Inputbar

@synthesize delegate;

-(id)init
{
    self = [super init];
    if (self)
    {
        
        [self addContent];
        
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    {
        [self addContent];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self addContent];
    }
    return self;
}

//- (void) setSendState:(BOOL) state {
//    
////    [self.textView setEditable:state];
//    
//    // disable button to send text message
////    [self.rightSendButton setEnabled:state];
//    
//    // disable button to send file (image or video)
////    [self.rightButton setEnabled:state];
//    
////    [self.leftButton setEnabled:state];
//}

-(void)addContent {
    
    self.sendStatus = NO;
    
    [self addRightButton];
    [self addbackgroudView];
    [self addTextView];
    [self addRightSendButton];
    [self addRightEmojiButton];
    [self addLeftButton];
    
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
}

- (void) addRightButton {
    
    CGSize size = self.frame.size;
    
    self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rightButton.frame = CGRectMake(size.width - RIGHT_GALLERY_BUTTON_SIZE - 12, 5, RIGHT_GALLERY_BUTTON_SIZE, size.height - 10);
    self.rightButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    
    self.rightButton.backgroundColor = [UIColor whiteColor];
    self.rightButton.layer.cornerRadius = 5;
    self.rightButton.layer.masksToBounds = YES;
    
    [self.rightButton setTitle:self.rightButtonText forState:UIControlStateNormal];
    
    [self.rightButton addTarget:self action:@selector(didPressRightFileSendButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.rightButton];
    
    self.rightButton.hidden = YES;
}

// add white round background view
-(void)addbackgroudView {
    
    CGSize size = self.frame.size;
    _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(LEFT_BUTTON_SIZE, 5, size.width - LEFT_BUTTON_SIZE - 12 , size.height - 10)];
    _backgroundView.backgroundColor = [UIColor whiteColor];
    _backgroundView.layer.cornerRadius = 5;
    _backgroundView.layer.masksToBounds = YES;
    
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self addSubview:_backgroundView];
}

// add left button ( + )
-(void)addLeftButton {
    
    CGSize size = self.frame.size;
    
    self.leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.leftButton.frame = CGRectMake(2, 0, LEFT_BUTTON_SIZE - 2, size.height);
    self.leftButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.leftButton setImage:self.leftButtonImage forState:UIControlStateNormal];
    
    [self.leftButton addTarget:self action:@selector(didPressLeftButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.leftButton];
}

// add right button for sending text message
// left margin - 8
// right margin - 10
-(void)addRightSendButton
{
    CGSize size = self.frame.size;
    
    self.rightSendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rightSendButton.frame = CGRectMake(size.width - RIGHT_BUTTON_SIZE - 16, 0, RIGHT_BUTTON_SIZE, size.height);
    self.rightSendButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    
//    self.rightSendButton.backgroundColor = [UIColor blueColor];
    
    [self.rightSendButton setImage:self.rightSendButtonImage forState:UIControlStateNormal];
    
    [self.rightSendButton addTarget:self action:@selector(didPressRightSendButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.rightSendButton setSelected:YES];
    
    [self addSubview:self.rightSendButton];
}

// add emoji button
-(void)addRightEmojiButton {

    CGSize size = self.frame.size;
    
    self.rightEmojiButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rightEmojiButton.frame = CGRectMake(size.width - (RIGHT_BUTTON_SIZE + 8) * 2, 0, RIGHT_BUTTON_SIZE, size.height);
    self.rightEmojiButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
//    self.rightEmojiButton.backgroundColor = [UIColor greenColor];
    
    [self.rightEmojiButton setImage:self.rightEmojiButtonImage forState:UIControlStateNormal];
    
    [self addSubview:self.rightEmojiButton];
}

-(void)addTextView
{
    CGSize size = self.backgroundView.frame.size;
    _textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(0, 4, size.width - (RIGHT_BUTTON_SIZE + 6) * 2, size.height)];
    _textView.isScrollable = NO;
    _textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);

    _textView.minNumberOfLines = 1;
    _textView.maxNumberOfLines = 3;
    _textView.font = [UIFont systemFontOfSize:15.0f];
    
    _textView.delegate = self;
    _textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    _textView.placeholder = _placeholder;
    
    //textView.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    _textView.keyboardType = UIKeyboardTypeDefault;
    _textView.returnKeyType = UIReturnKeyDefault;
    _textView.enablesReturnKeyAutomatically = YES;
    
//    _textView.layer.cornerRadius = 5.0;
//    _textView.layer.borderWidth = 0.5;
//    _textView.layer.borderColor =  [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:205.0/255.0 alpha:1.0].CGColor;
    
    _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // view hierachy
    [self.backgroundView addSubview:_textView];
}

- (void) becomeFirstResponder {
    
    [_textView becomeFirstResponder];
}

- (void) resignFirstResponder {
    
    [_textView resignFirstResponder];
}

-(NSString *)text
{
    return _textView.text;
}

#pragma mark - Delegate

-(void)didPressRightSendButton:(UIButton *)sender
{
//    if (self.rightButton.isSelected) return;
    
    if (!_sendStatus || self.rightSendButton.isSelected) {
        
        return;
    }
    
    [self.delegate inputbarDidPressSendButton:self];
    self.textView.text = @"";
}

-(void)didPressRightEmojiButton:(UIButton *)sender
{
   
    if (!_sendStatus) {
        
        return;
    }
    
    [self.delegate inputbarDidPressEmojiButton:self];
}

-(void)didPressLeftButton:(UIButton *)sender
{
    [self.delegate inputbarDidPressLeftButton:self];
}

- (void) didPressRightFileSendButton:(UIButton *) sender {
    
}

#pragma mark - Set Methods

-(void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder;
    _textView.placeholder = placeholder;
}

-(void)setLeftButtonImage:(UIImage *)leftButtonImage
{
    [self.leftButton setImage:leftButtonImage forState:UIControlStateNormal];
}

- (void) setRightSendButtonImage:(UIImage *)rightSendButtonImage {
    
    [self.rightSendButton setImage:rightSendButtonImage forState:UIControlStateNormal];
}

- (void) setRightEmojiButtonImage:(UIImage *)rightEmojiButtonImage {
    
    [self.rightEmojiButton setImage:rightEmojiButtonImage forState:UIControlStateNormal];
}

- (void) setRightButtonText:(NSString *)rightButtonText {
    
    [self.rightButton setTitle:rightButtonText forState:UIControlStateNormal];
}

- (void) setRightButtonTextColor:(UIColor *)rightButtonTextColor {
    
    [self.rightButton setTitleColor:rightButtonTextColor forState:UIControlStateNormal];
}

#pragma mark - TextViewDelegate
-(void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
    CGRect r = self.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    self.frame = r;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputbarDidChangeHeight:)])
    {
        [self.delegate inputbarDidChangeHeight:self.frame.size.height];
    }
}

-(void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputbarDidBecomeFirstResponder:)])
    {
        [self.delegate inputbarDidBecomeFirstResponder:self];
    }
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView {
    
    NSString *text = [growingTextView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if ([text isEqualToString:@""]) {
      
        [self.rightSendButton setImage:[UIImage imageNamed:@"button_send_chat"] forState:UIControlStateNormal];
        
        [self.rightSendButton setSelected:YES];
        
    } else {
        
        [self.rightSendButton setImage:self.rightSendButtonSelectedImage forState:UIControlStateNormal];
        
        [self.rightSendButton setSelected:NO];
    }
}

- (void) beginEditting
{
    [self.textView becomeFirstResponder];
}

// change input type
- (void) changeInputType:(int) _inputType {
    
    inputType = _inputType;
    
    // text
    if (inputType == 0) {
        
        self.backgroundView.hidden = NO;
        self.rightSendButton.hidden = NO;
        self.rightEmojiButton.hidden = NO;
        
        // file send button
        self.rightButton.hidden = YES;
        
    } else {
        
        // image or vidoe
        self.backgroundView.hidden = YES;
        self.rightSendButton.hidden = YES;
        self.rightEmojiButton.hidden = YES;
        
        // file send button
        self.rightButton.hidden = NO;
    }
}

@end

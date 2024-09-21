#import "FPSDisplay.h"
#import <Foundation/Foundation.h>

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

@interface FPSDisplay ()

@property (strong, nonatomic) UILabel *displayLabel;
@property (strong, nonatomic) CADisplayLink *link;
@property (assign, nonatomic) NSInteger count;
@property (assign, nonatomic) NSTimeInterval lastTime;
@property (strong, nonatomic) UIFont *font;

@end

@implementation FPSDisplay

+ (instancetype)shareFPSDisplay {
    static FPSDisplay *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (void)load {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self shareFPSDisplay];
    });
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initDisplayLabel];
    }
    return self;
}

- (void)initDisplayLabel {
    self.displayLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 150, -5, 300, 33)];
    self.displayLabel.layer.cornerRadius = 5;
    self.displayLabel.clipsToBounds = YES;
    self.displayLabel.textAlignment = NSTextAlignmentCenter;
    self.displayLabel.font = [UIFont fontWithName:@"Menlo" size:60] ?: [UIFont systemFontOfSize:30];
    
    [self initCADisplayLink];
    [[UIApplication sharedApplication].windows.firstObject addSubview:self.displayLabel];
}

- (void)initCADisplayLink {
    self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
    [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)tick:(CADisplayLink *)link {
    if (self.lastTime == 0) {
        self.lastTime = link.timestamp;
        return;
    }
    self.count++;
    NSTimeInterval delta = link.timestamp - self.lastTime;
    if (delta >= 1.0) {
        self.lastTime = link.timestamp;
        [self updateDisplayLabelText:(self.count / delta)];
        self.count = 0;
    }
}

- (void)updateDisplayLabelText:(float)fps {
    NSString *timestamp = [self getSystemDate];
    self.displayLabel.font = [UIFont systemFontOfSize:13];
    
    NSString *text = [NSString stringWithFormat:@"%@ ♡ (%d FPS) | KhoaIOS", timestamp, (int)round(fps)];
    self.displayLabel.textColor = [UIColor colorWithHue:arc4random_uniform(256) / 255.0
                                                 saturation:1.0
                                                 brightness:1.0
                                                      alpha:1.0];
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text];
    for (NSUInteger i = 0; i < text.length; i++) {
        UIColor *color = [UIColor colorWithHue:((arc4random_uniform(256) / 255.0) + (i * 0.02)) 
                                             saturation:1.0 
                                             brightness:1.0 
                                             alpha:1.0];
        [attributedText addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(i, 1)];
    }
    
    self.displayLabel.attributedText = attributedText;
}

- (NSString *)getSystemDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    return [dateFormatter stringFromDate:[NSDate date]];
}

@end


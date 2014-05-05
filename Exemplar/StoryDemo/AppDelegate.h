//
//  AppDelegate.h
//  StoryDemo
//
//  Created by Mac on 22/06/13.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
@protocol MyProgressBarDelegate

- (void) onUpdateProgress:(Float32)progress;

@end

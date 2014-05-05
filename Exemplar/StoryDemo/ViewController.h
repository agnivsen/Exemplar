//
//  ViewController.h
//  StoryDemo
//
//  Created by Mac on 22/06/13.
//

#import <UIKit/UIKit.h>
#import "FixedRadViewController.h"

@interface ViewController : UIViewController  <UIGestureRecognizerDelegate>
{
    UIImagePickerController *picker;
}

@property (retain, nonatomic) IBOutlet UIImageView *baghaView;
@property (retain, nonatomic) IBOutlet UIImageView *thumbnailView;
@property (retain, nonatomic) IBOutlet UIImageView *hiddenView;
- (IBAction)LoadImage:(id)sender;
@property (retain, nonatomic) IBOutlet UIImageView *overlayView;
- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer;
- (IBAction)handlePinch:(UIPinchGestureRecognizer *)recognizer;
- (IBAction)handleRotate:(UIRotationGestureRecognizer *)recognizer;
- (IBAction)processImage:(id)sender;


@end

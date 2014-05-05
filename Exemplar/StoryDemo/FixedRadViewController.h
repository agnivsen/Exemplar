//
//  FixedRadViewController.h
//  StoryDemo
//
//  Created by agniva on 09/07/13.
//

#import <UIKit/UIKit.h>
#import "CV_Utils.h"
#import "Exemplar.h"


@interface FixedRadViewController : UIViewController
@property (retain, nonatomic) IBOutlet UISlider *sliderFeatherVal;
@property (retain, nonatomic) IBOutlet UIImageView *overlayView;
@property (retain, nonatomic) IBOutlet UISwitch *dragState;
@property (retain, nonatomic) IBOutlet UISegmentedControl *modeVal;
@property (retain, nonatomic) IBOutlet UILabel *textVal;
@property (retain, nonatomic) IBOutlet UISwitch *continiousMode;
@property (retain, nonatomic) IBOutlet UILabel *featherTextVal;
@property (retain, nonatomic) IBOutlet UISlider *sliderVal;
@property (retain, nonatomic) IBOutlet UIImageView *displayImage;
@property (retain, nonatomic) IBOutlet UILabel *markerNotice;
@property (retain, nonatomic) IBOutlet UILabel *progressExemplar;
@property (retain, nonatomic) IBOutlet UIProgressView *progressBarExemplar;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *overlayMask;

@property (nonatomic, assign) BOOL loop;
@property (retain, nonatomic) IBOutlet UILabel *savedImageLabel;

- (IBAction)dismissView:(id)sender;
- (IBAction)slider:(id)sender;
- (IBAction)sliderFeather:(id)sender;
- (IBAction)modeSwitch:(id)sender;
- (IBAction)dragSwitch:(id)sender;
-(void) exemplarCallBack : (UIImage *) imageExe;
- (IBAction)captureSnapshot:(id)sender;

-(void)setProgressVal : (float) value;
-(void)setProgressWithVal : (float) val;



@end

//@protocol MyProgressBarDelegate
//
//- (void) onUpdateProgress:(Float32)progress;
//
//@end

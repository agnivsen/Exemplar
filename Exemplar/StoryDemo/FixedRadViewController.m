//
//  FixedRadViewController.m
//  StoryDemo
//
//  Created by agniva on 09/07/13.
//

#import "FixedRadViewController.h"

@interface FixedRadViewController ()

@end

@implementation FixedRadViewController
@synthesize image,overlayMask;
@synthesize loop = _loop;

int inpaintRad, featherRad, mode;
BOOL dragState, isExemplarPrepared;
int _x, _y, orgX, orgY, centroidX, centroidY;
int totalPoints = 0;
CGFloat overlayImageScale, baseImageScale;
UIImage *overlayImg;
float progress;

CGContextRef contextMarker;

#pragma mark LifeCycle Methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
     [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
    _displayImage.hidden = NO;
    _displayImage.clipsToBounds = YES;
    [_displayImage setImage:[self imageWithImage:image scaledToSize:_displayImage.frame.size]];
    baseImageScale = _displayImage.image.scale;
    
    //NSLog(@"set image: %f, %f", _displayImage.frame.size.height, _displayImage.frame.size.width);
    
    _overlayView.hidden = YES;
    [self setOverlayImage];
    overlayImageScale = _overlayView.image.scale;
    
    _dragState.transform = CGAffineTransformMakeScale(0.6, 0.6);
    
    [self.view addSubview:_displayImage];
    [self.view insertSubview:_overlayView aboveSubview:_displayImage];
    
    UIFont *font = [UIFont boldSystemFontOfSize:8.0f];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:UITextAttributeFont];
    [_modeVal setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    _markerNotice.hidden = YES;
    isExemplarPrepared = FALSE;
    
    [self.view insertSubview:_progressBarExemplar atIndex:5];
    _progressBarExemplar.hidden = YES;
    
    _savedImageLabel.alpha = 0.0;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_displayImage release];
    [_sliderVal release];
    [_textVal release];
    [_sliderFeatherVal release];
    [_featherTextVal release];
    [_modeVal release];
    [_continiousMode release];
    [_dragState release];
    [_markerNotice release];
    [_overlayView release];
    [_progressExemplar release];
    [_progressBarExemplar release];
    [_savedImageLabel release];
    [super dealloc];
}

-(void)setOverlayImage
{
    _overlayView.clipsToBounds = YES;
    [_overlayView setImage:[self imageWithImage:overlayMask scaledToSize:_displayImage.frame.size]];
    
    
}

#pragma mark UI Control Functions


- (IBAction)captureSnapshot:(id)sender
{
    UIImageWriteToSavedPhotosAlbum(_displayImage.image, Nil, Nil, Nil);
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         _savedImageLabel.alpha = 1.0;
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.5
                                               delay:0.0
                                             options: UIViewAnimationCurveEaseOut
                                          animations:^{
                                              _savedImageLabel.alpha = 0.0;
                                          }
                                          completion:^(BOOL finished){
                                              
                                          }];
                     }];
}


- (IBAction)dismissView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)slider:(id)sender
{
    inpaintRad = (_sliderVal.value*40);
    _textVal.text = [[NSString alloc] initWithFormat:@"%d ", inpaintRad];
}

- (IBAction)sliderFeather:(id)sender
{
    featherRad = (_sliderFeatherVal.value*10);
    _featherTextVal.text = [[NSString alloc] initWithFormat:@"%d ", featherRad];
}

- (IBAction)modeSwitch:(id)sender
{
    mode = _modeVal.selectedSegmentIndex;
    if(mode==2)
    {
        _markerNotice.hidden = NO;
        _overlayView.hidden = NO;
    }
    else
    {
        _markerNotice.hidden = YES;
        _overlayView.hidden = YES;
    }
}

- (IBAction)dragSwitch:(id)sender
{
    dragState = _dragState.isOn;
}

-(void)setProgressVal : (float) value
{
    //NSLog(@"setting progress val at: %f",value);
    progress = value;
    [self performSelectorOnMainThread:@selector(setProgress) withObject:nil waitUntilDone:NO];
 
}

-(void)setProgress
{
    _progressBarExemplar.hidden = NO;
    [_progressBarExemplar setProgress:progress animated:YES];
    
    if(progress == 1.0f)
    {
        [UIView animateWithDuration:0.6f animations:^{
            _progressBarExemplar.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
        }completion:^(BOOL finished) {
            _progressBarExemplar.hidden = YES;
        }];
    }

}

-(void)setProgressWithVal : (float) val
{
    [_progressBarExemplar setProgress:val animated:YES];
}



# pragma mark Touch Events

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    _overlayView.hidden = NO;
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:_displayImage];
    [self setOverlayImage];
    if((location.x<_displayImage.frame.size.width)&&(location.y<_displayImage.frame.size.height))
    {
        [self inpaintImage:location.x :location.y];
        orgX = _x = location.x;
        orgY = _y = location.y;
        //centroidX+=orgX;
        //centroidY+=orgY;
        
        contextMarker = UIGraphicsGetCurrentContext();
        CGContextSetRGBStrokeColor(contextMarker, 255.0, 255.0, 255.0, 1.0);
        CGContextSetRGBFillColor(contextMarker, 255.0, 255.0, 0.0, 1.0);
        CGContextSetLineJoin(contextMarker, kCGLineJoinRound);
        CGContextSetLineWidth(contextMarker, 8.0);
    }
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:_displayImage];
    CGPoint locationOverlay = [touch locationInView:_overlayView];
    if((location.x<_displayImage.frame.size.width)&&(location.y<_displayImage.frame.size.height)&&dragState)
    {
        [self inpaintImage:location.x :location.y];
    }
    else if (mode == 2)
    {
        overlayImg = [self paintMarker :locationOverlay.x :locationOverlay.y :FALSE];
        [_overlayView setImage:overlayImg];
        
        _x = locationOverlay.x;
        _y = locationOverlay.y;
        
        centroidX+=_x;
        centroidY+=_y;
    }
}

-(void) touchesEnded :(NSSet *)touches withEvent:(UIEvent *)event
{
    //UITouch *touch = [touches anyObject];
   // CGPoint location = [touch locationInView:_overlayView];
     if(mode==2)
    {
        if(isExemplarPrepared)
            [self prepareExemplarInpaint];
    }
    centroidX = 0;
    centroidY = 0;
    totalPoints = 0;
}

#pragma mark Exemplar Methods

-(void)prepareExemplarInpaint
{
    _progressBarExemplar.hidden = NO;
    [self setProgressVal:0.0];
    
    NSLog(@"Exemplar");
    
    [_overlayView setUserInteractionEnabled:NO];
    [_displayImage setUserInteractionEnabled:NO];
    Exemplar *exe = [[Exemplar alloc] init];
    _loop = true;
    [exe setCallbackImageView:_displayImage];
    
    dispatch_async(dispatch_queue_create("com.object.removal", DISPATCH_QUEUE_CONCURRENT), ^{
    
        UIImage *imgExemplar = [self imageWithImage:[exe exemplarWithMask:image :overlayImg] scaledToSize:_displayImage.frame.size];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
        [_displayImage setImage:imgExemplar];
            [_overlayView setUserInteractionEnabled:YES];
            [_displayImage setUserInteractionEnabled:YES];
            });
        _loop = FALSE;
        });
    
    _overlayView.hidden = YES;
    [_overlayView setUserInteractionEnabled:NO];
    [_displayImage setUserInteractionEnabled:NO];
    
    //NSLog(@"out of Exemplar");

     dispatch_async(dispatch_queue_create("com.object.removal.progress", DISPATCH_QUEUE_CONCURRENT), ^{
         
         while (_loop)
         {
             [self setProgressVal:[exe getProgress]];
         }
         
         [self setProgressVal:1.0];
         [exe release];
     });
    
    //NSLog(@"done");
}

-(void) exemplarCallBack : (UIImage *) imageExe
{
    NSLog(@"call back received %f",imageExe.size.height);
    dispatch_sync(dispatch_get_main_queue(),
    ^{
        [_displayImage setImage:[self imageWithImage :imageExe scaledToSize :_displayImage.frame.size]];
    });
}



-(void) inpaintImage:(int) x :(int) y
{
    CV_Utils *openCV = [[CV_Utils alloc] init];
    UIImage *result = [openCV presetInpainting:_displayImage.image :inpaintRad :featherRad :mode :x :y];
    [openCV release];
    [_displayImage setImage:result];
}



-(UIImage *)paintMarker: (int) x : (int) y :(BOOL) isFinish
{
    totalPoints++;
    CGImageRef imageBuff = [_overlayView.image CGImage];
    CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(imageBuff));
    
     //CGImageRef imageTarget = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageBuff);
    NSUInteger height = CGImageGetHeight(imageBuff);
    
//    NSUInteger bytesPerPixel = 4;
//    NSUInteger bytesPerRow = bytesPerPixel * width;
    
    unsigned char *input_image = (unsigned char *)CFDataGetBytePtr(pixelData);
    unsigned char *output_image = (unsigned char *)malloc(height*4*width);
    
    
//    int byteIndexMarker = (bytesPerRow * y * overlayImageScale) + x * overlayImageScale * bytesPerPixel;
    int currIndex = 0;
    
    for (int i=0; i<height;i++)
    {
        for (int j=0; j<(width); j++)
        {
            
                output_image[currIndex] = input_image[currIndex];
                output_image[currIndex+1] = input_image[currIndex+1];
                output_image[currIndex+2] = input_image[currIndex+2];
                output_image[currIndex+3] = input_image[currIndex+3];
            currIndex+=4;
        }
    }
    
    CFRelease(pixelData);
    
    CGColorSpaceRef colorSpaceRef1 = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo1 = kCGBitmapByteOrderDefault |  kCGImageAlphaPremultipliedLast;
    CGContextRef context = CGBitmapContextCreate(output_image, width, height, 8, 4*width, colorSpaceRef1, bitmapInfo1);
    
    CGContextSetLineWidth(context, 1.0);
    
    if(!isFinish)
    {
        
        CGContextBeginPath(context);
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextMoveToPoint(context, _x*overlayImageScale, (height - (_y*overlayImageScale)));
        CGContextSetRGBStrokeColor(context, 255.0, 255.0, 255.0, 255.0);
        CGContextAddLineToPoint(context, x*overlayImageScale,(height - (y*overlayImageScale)));
        CGContextAddLineToPoint(context, orgX*overlayImageScale,(height - (orgY*overlayImageScale)));
        CGPathDrawingMode mode = kCGPathFillStroke;
        CGContextClosePath(context);
        CGContextDrawPath( context, mode );
    }    
    
    CGImageRef imageRef2 = CGBitmapContextCreateImage (context);
    UIImage *newimage = [UIImage imageWithCGImage:imageRef2];
    CGColorSpaceRelease(colorSpaceRef1);
    CGContextRelease(context);
    CFRelease(imageRef2);
    free(output_image);
    isExemplarPrepared = TRUE;
    
    
    return newimage;
}

-(unsigned char*)getArray:(UIImage *)imageTemp
{
    CGImageRef imageBuff = [imageTemp CGImage];
    CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(imageBuff));
    
    int width = CGImageGetWidth(imageBuff);
    int height = CGImageGetHeight(imageBuff);
    
    unsigned char *input_image = (unsigned char *)CFDataGetBytePtr(pixelData);
    unsigned char *output_image = (unsigned char *)malloc(height*4*width);
    
    for (int i=0; i<height;i++)
    {
        for (int j=0; j<4*width; j+=4)
        {
            output_image[i*4*width+4*(j/4)+0] = input_image[i*4*width+4*(j/4)];
            output_image[i*4*width+4*(j/4)+1] = input_image[i*4*width+4*(j/4)+1];
            output_image[i*4*width+4*(j/4)+2] = input_image[i*4*width+4*(j/4)+2];
            output_image[i*4*width+4*(j/4)+3] = 255;
        }
    }
    CFRelease(pixelData);
    
    return output_image;
}

-(UIImage *)imageWithImage:(UIImage *)imageResizable scaledToSize:(CGSize)newSize {
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [imageResizable drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end

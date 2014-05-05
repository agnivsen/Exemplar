//
//  ViewController.m
//  StoryDemo
//
//  Created by Mac on 22/06/13.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

bool isLoaded = FALSE;

UIImage *bckUp;
UIImage *overlayImage;

- (void)viewDidLoad
{
    [super viewDidLoad];
    _baghaView.hidden = NO;
    _baghaView.clipsToBounds = YES;
    
    _overlayView.hidden = YES;
    _overlayView.clipsToBounds = NO;
    
    _thumbnailView.hidden = YES;
    _thumbnailView.clipsToBounds = YES;
    
    _hiddenView.hidden = YES;
    _hiddenView.clipsToBounds = YES;
//
//    self.view.backgroundColor = [UIColor Color];
//
    [self.view addSubview:_baghaView];
    [self.view addSubview:_overlayView];
    [self.view addSubview:_thumbnailView];
    [self.view addSubview:_hiddenView];
	// Do any additional setup after loading the view, typically from a nib.
    
    overlayImage =[UIImage imageNamed:@"crosshair.png"];
    bckUp =[UIImage imageNamed:@"crosshair.png"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_baghaView release];
    [_overlayView release];
    [_thumbnailView release];
    [_hiddenView release];
    [super dealloc];
}

- (IBAction)LoadImage:(id)sender
{
    picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    
    /*if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
    else*/
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentModalViewController:picker animated:YES];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *) Picker
{
    [Picker dismissModalViewControllerAnimated:YES];
    [Picker release];
    
}
 -(void)imagePickerController:(UIImagePickerController *)picker1 didFinishPickingMediaWithInfo:(NSDictionary *)editingInfo
{
    UIImage * pickedImage = [self fixOrientation:[editingInfo valueForKey:UIImagePickerControllerOriginalImage]];
    
    [_baghaView setImage:pickedImage];
    _baghaView.contentMode = UIViewContentModeScaleAspectFit;
    _baghaView.backgroundColor = [UIColor clearColor];

    [picker1 dismissModalViewControllerAnimated:YES ] ;
    [picker1 release];
    
    _overlayView.hidden = NO;
    _overlayView.contentMode = UIViewContentModeScaleAspectFit;
    
    isLoaded = TRUE;
}

- (void)viewDidUnload
{
    self.baghaView = nil;
}

- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {
    
   // NSLog(@"pan gesture");
    CGPoint translation = [recognizer translationInView:_baghaView];
    _overlayView.center = CGPointMake(_overlayView.center.x + translation.x,
                                         _overlayView.center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:_baghaView];
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        CGPoint velocity = [recognizer velocityInView:_baghaView];
        CGFloat magnitude = sqrtf((velocity.x * velocity.x) + (velocity.y * velocity.y));
        CGFloat slideMult = magnitude / 800;
       // NSLog(@"magnitude: %f, slideMult: %f", magnitude, slideMult);
        
        float slideFactor = 0.1 * slideMult; // Increase for more of a slide
        CGPoint finalPoint = CGPointMake(_overlayView.center.x + (velocity.x * slideFactor),
                                         _overlayView.center.y + (velocity.y * slideFactor));
        finalPoint.x = MIN(MAX(finalPoint.x, 0), _baghaView.bounds.size.width);
        finalPoint.y = MIN(MAX(finalPoint.y, 0), _baghaView.bounds.size.height);
        
        [UIView animateWithDuration:slideFactor*2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            _overlayView.center = finalPoint;
        } completion:nil];
        
    }
    [self clipImage];
    
}

- (IBAction)handlePinch:(UIPinchGestureRecognizer *)recognizer {
    _overlayView.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
    [self clipImage];
}

- (IBAction)handleRotate:(UIRotationGestureRecognizer *)recognizer {
    _overlayView.transform = CGAffineTransformRotate(recognizer.view.transform, recognizer.rotation);
    recognizer.rotation = 0;
    [self clipImage];
}

- (IBAction)processImage:(id)sender
{
    //NSLog(@"processing image");
   // [self clipImage];

}

-(void)clipImage
{
    if(CGRectIntersectsRect([_overlayView frame], [_baghaView frame]))
    {
       // NSLog(@"thwaaaaa");
        
        CGFloat scaledHght, scaledWdth;
        CGFloat aspect, aspectW;
        CGRect frameRect;
        
//        NSLog(@"height = %f, width = %f", _baghaView.image.size.height, _baghaView.image.size.width);

        if (_baghaView.image.size.height <= _baghaView.image.size.width)
        {
            aspectW = _baghaView.image.size.width/_baghaView.frame.size.width;
            aspect =_baghaView.image.size.height/_baghaView.frame.size.height;
            
            scaledHght = _baghaView.image.size.height/aspect;
            scaledWdth = _baghaView.image.size.width/aspectW;
            frameRect = CGRectMake(_baghaView.frame.origin.x, (_baghaView.frame.origin.y + (_baghaView.frame.size.height/2 - scaledHght/2)), scaledWdth, scaledHght);
        }
        else
        {
            aspect = _baghaView.image.size.height/_baghaView.frame.size.height;
            aspectW = _baghaView.image.size.width/_baghaView.frame.size.width;
            scaledHght = _baghaView.image.size.height/aspect;
            scaledWdth = _baghaView.image.size.width/aspectW;
            frameRect = CGRectMake((_baghaView.frame.origin.x + (_baghaView.frame.size.width/2 - scaledWdth/2)), _baghaView.frame.origin.y, scaledWdth, scaledHght);
        }
//        NSLog(@"frame height = %f, width = %f", frameRect.size.height, frameRect.size.width);
//        NSLog(@"scaling = %f", aspect);
        
        CGRect r = CGRectIntersection([_overlayView frame], frameRect);
        
//        NSLog(@"Original Height of r: %f, width of r = %f",r.size.height,r.size.width);
//        NSLog(@"Original: (%f,%f)",r.origin.x,r.origin.y);
        
        CGFloat xratio = (r.origin.x - frameRect.origin.x)*aspectW;
        CGFloat yratio = (r.origin.y - frameRect.origin.y)*aspect;
        
        r.size.height = (aspect) * r.size.height;
        r.size.width = (aspectW) * r.size.width;
        
        r.origin.y = yratio;//(aspect) * r.origin.y;
        r.origin.x = xratio;//(aspect) * r.origin.x;
        
        UIImage *img = [self croppedImage:r :_baghaView.image];
        
        [_hiddenView setImage:img];
        
        [_thumbnailView setImage:[self mergeCrossHair:img]];
        _thumbnailView.contentMode = UIViewContentModeScaleAspectFit;
        _thumbnailView.hidden = NO;
        
//        NSLog(@"Scaled: (%f,%f)",r.origin.x,r.origin.y);
//        NSLog(@"Scaled Height of r: %f, width of r = %f",r.size.height,r.size.width);
        
    }
}

- (UIImage *)croppedImage:(CGRect)bounds:(UIImage *)image
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], bounds);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
}

-(CGRect) cropRectForFrame:(CGRect)frame
{
    NSAssert(_baghaView.contentMode == UIViewContentModeScaleAspectFit, @"content mode must be aspect fit");
    
    CGFloat widthScale = _baghaView.bounds.size.width / _baghaView.image.size.width;
    CGFloat heightScale = _baghaView.bounds.size.height / _baghaView.image.size.height;
    
    float x, y, w, h, offset;
    if (widthScale<heightScale) {
        offset = (_baghaView.bounds.size.height - (_baghaView.image.size.height*widthScale))/2;
        x = frame.origin.x / widthScale;
        y = (frame.origin.y-offset) / widthScale;
        w = frame.size.width / widthScale;
        h = frame.size.height / widthScale;
    } else {
        offset = (_baghaView.bounds.size.width - (_baghaView.image.size.width*heightScale))/2;
        x = (frame.origin.x-offset) / heightScale;
        y = frame.origin.y / heightScale;
        w = frame.size.width / heightScale;
        h = frame.size.height / heightScale;
    }
    return CGRectMake(x, y, w, h);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (UIImage *)fixOrientation:(UIImage *) img {
    
    // No-op if the orientation is already correct
    if (img.imageOrientation == UIImageOrientationUp) return img;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (img.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, img.size.width, img.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, img.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, img.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (img.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, img.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, img.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, img.size.width, img.size.height,
                                             CGImageGetBitsPerComponent(img.CGImage), 0,
                                             CGImageGetColorSpace(img.CGImage),
                                             CGImageGetBitmapInfo(img.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (img.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,img.size.height,img.size.width), img.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,img.size.width,img.size.height), img.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *result = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return result;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    //NSLog(@"segue triggered %@",segue.destinationViewController);
    /*if ([segue.identifier isEqualToString:@"showTargetImage"]) {
        //NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ORView *destViewController = segue.destinationViewController;
        //destViewController.recipeName = [recipes objectAtIndex:indexPath.row];
        destViewController.image =  _hiddenView.image;
    }
    else */if ([segue.identifier isEqualToString:@"FixedRadView"]) {
        //NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        FixedRadViewController *destViewController = segue.destinationViewController;
        //destViewController.recipeName = [recipes objectAtIndex:indexPath.row];
        destViewController.image = _baghaView.image;
        
        UIImage *overlay =[UIImage imageNamed:@"white.png"];
        destViewController.overlayMask = overlay;
        
    }
    
    
}

-(UIImage *) mergeCrossHair :(UIImage *) image
{
    CGSize newSize = CGSizeMake(image.size.width, image.size.height);
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    [overlayImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height) blendMode:kCGBlendModeMultiply alpha:1.0];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
   
    return newImage;
}

@end

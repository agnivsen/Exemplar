//
//  CV_Utils.m
//  StoryDemo
//
//  Created by agniva on 28/06/13.
//

#import "CV_Utils.h"
#include <opencv2/opencv.hpp>

#define _8Bit4Channel CV_8UC4
#define _8Bit1Channel CV_8UC1




@interface CV_Utils ()

@end

@implementation CV_Utils

cv::RNG rng(12345);
cv::vector <cv::vector <cv::Point>> contour1;
cv::vector <cv::vector <cv::Point>> contour2;

#pragma life-cycle

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma algorithms

- (UIImage*)decolor:(UIImage *)input_image
{
    
    IplImage *im_rgb = [self CreateIplImageFromUIImage:input_image];
    IplImage *im_gray = cvCreateImage(cvGetSize(im_rgb),IPL_DEPTH_8U,1);
    cvCvtColor(im_rgb,im_gray,CV_RGB2GRAY);

    
    return [self UIImageGrayFromIplImage:im_gray];
}

-(UIImage*)smoothMedian:(UIImage *)input_image:(int) size
{
    IplImage *im_rgb = [self CreateIplImageFromUIImage:input_image];
    cvSmooth(im_rgb, im_rgb, CV_MEDIAN, size, 0);
    
    return [self UIImageGrayFromIplImage:im_rgb];
}
    
-(UIImage*)erosion:(UIImage *)input_image
    {
        IplImage *im_rgb = [self CreateIplImageFromUIImage:input_image];
        //cvSmooth(im_rgb, im_rgb, CV_MEDIAN, size, 0);
        
        cvErode(im_rgb, im_rgb);
        
        return [self UIImageGrayFromIplImage:im_rgb];
    }

    -(UIImage*)dilation:(UIImage *)input_image
    {
        IplImage *im_rgb = [self CreateIplImageFromUIImage:input_image];
        //cvSmooth(im_rgb, im_rgb, CV_MEDIAN, size, 0);
        
        cvDilate(im_rgb, im_rgb);
        
        return [self UIImageGrayFromIplImage:im_rgb];
    }


-(UIImage*)morphologicalGradient:(UIImage *)input_image:(int) size
{
    cv::Mat im_rgb = [self cvMatGrayFromUIImage:input_image];
   // IplConvKernel *element = cvCreateStructuringElementEx(3,3,1,1,CV_SHAPE_RECT);
    
    
    cv::morphologyEx(im_rgb,im_rgb,4,cv::getStructuringElement(cv::MORPH_RECT,cv::Size(size,size)));
    
    return [self UIImageFromCVMat:im_rgb];
}

-(void)findContour : (UIImage*)input_image
{
    cv::Mat im_rgb = [self cvMatGrayFromUIImage:input_image];
    cv::cvtColor(im_rgb, im_rgb, CV_BGR2GRAY);
    Canny(im_rgb, im_rgb, 0, 3, 5);
    cv::vector <cv::vector <cv::Point>> contours;
    findContours (im_rgb, contours, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_NONE);
    
    cv::vector<cv::vector<cv::Point> >::iterator contour = contours.begin(); // const_iterator if you do not plan on modifying the contour
    for(; contour != contours.end(); ++contour) {
        // use *contour for current contour
        cv::vector<cv::Point>::iterator point = contour->begin(); // again, use const_iterator if you do not plan on modifying the contour
        for(; point != contour->end(); ++point) {
            // use *point for current point
            //printf("*%d,%d*\n",point->x,point->y);
        }
        //printf("\n******Done Contour*****\n");
    }
    
    //return contours;
}

-(struct fillFront *)fillFrontFromContour : (unsigned char *) data : (int) tex : (int) height : (int) width
{
    //NSLog(@"contour finding block");
    cv::Mat im_rgb =        [self cvMatFromDataArray:data :height :width];  //obtain Mat from byte array
    cv::cvtColor(im_rgb, im_rgb, CV_RGBA2GRAY);                             //convert color scale to gray
    cv::vector <cv::vector <cv::Point>> contours;                           //'vector-of-vector-of-points' for holding the contour
    
    findContours (im_rgb, contours, CV_RETR_CCOMP, CV_CHAIN_APPROX_NONE, cv::Point(0, 0));
    
    BOOL isFirst = TRUE;
    struct fillFront *fill = (fillFront*)malloc(sizeof(fillFront));
    struct fillFront *temp = (fillFront*)malloc(sizeof(fillFront));
    int count = 0;
    
    cv::vector<cv::vector<cv::Point> >::iterator contour = contours.begin(); 
    for(; contour != contours.end(); ++contour)
    {
        cv::vector<cv::Point>::iterator point = contour->begin(); 
        for(; point != contour->end(); ++point,++count)
        {
            //printf("(%d,%d)\n",point->x,point->y);
            if(isFirst)
            {   //the first element of the linked list is initialized sperately.
                fill->x =           point->y;//the x and y positions for openCV and iOS - UIImage seems to be different.
                fill->y =           point->x*4;//swapping the x and y coordinates seems to produce the correct result 
                fill->texelSize =   tex;
                fill->next =        NULL;
                isFirst =           FALSE;
                temp =              fill;
            }
            else //if(([self getDistance:temp->x :temp->y/4 :point->y :point->x])>=2/*(tex-1)*/)
            {
                struct fillFront *front =   (fillFront*)malloc(sizeof(fillFront));
                front->x =          point->y;
                front->y =          point->x*4;
                front->texelSize =  tex;
                front->next =       NULL;
                temp->next =        front;
                temp =              front;
            }
        }
        --point;
        
        //the following block adds the last texel, irrespective of its mutual distance with the last-but-one texel ...
        //... thereby creating an overlapping texel. 
        struct fillFront *front = (fillFront*)malloc(sizeof(fillFront));
        front->x =          point->y;
        front->y =          point->x*4;
        front->texelSize =  tex;
        front->next =       NULL;
        temp->next =        front;
        temp =              front;
    }
   // NSLog(@"total points returned from find contour : %d",count);
    
    if(count<tex)
    {
        return NULL;
    }
    else
    {
        return fill;
    }
    
}

-(double) getDistance : (int) x : (int) y : (int) x1 : (int) y1
{   //returns the Eucledian distance between the points
    double dist = sqrt(pow((x1-x), 2) + pow((y1-y), 2));
    return dist;
}

-(UIImage*)canny : (UIImage*)input_image
{
    cv::Mat im_rgb = [self cvMatGrayFromUIImage:input_image];
    Canny(im_rgb, im_rgb, 0, 50, 5);
    
    return [self UIImageFromCVMat:im_rgb];
}

-(void) compareContour
{
    cv::vector<cv::vector<cv::Point> >::iterator contour = contour1.begin();
    for(; contour != contour1.end(); ++contour) {
        cv::vector<cv::Point>::iterator point = contour->begin();
        for(; point != contour->end(); ++point) {
            int x = point->x;
            int y = point->y;
            cv::vector<cv::vector<cv::Point> >::iterator _contour = contour2.begin();
            for(; _contour != contour2.end(); ++_contour) {
                cv::vector<cv::Point>::iterator _point = _contour->begin();
                for(; _point != _contour->end(); ++_point) {
                    int x1 = _point->x;
                    int y1 = _point->y;
//                    if((x1 == x)   &&  (y1 == y))
//                    {
//                        NSLog(@"found common point : (%d,%d)",x,y);
//                    }
                    
                }
            }
            
        }
    }
}

-(struct gradListDouble *) cannyGradient : (unsigned char *)img : (int) height : (int) width : (int) status
{
    //unsigned char *output_image = (unsigned char *)malloc(height*(width+1));
    //NSLog(@"incoming height width : %d, %d",height,width);
    cv::Mat im_rgb =        [self cvMatFromDataArray :img :height :width];  //obtain Mat from byte array
    cv::cvtColor(im_rgb, im_rgb, CV_RGBA2GRAY);
    //NSLog(@"outgoing height and width for the matrix : %d, %d",im_rgb.rows,im_rgb.cols);
    
    double *gradData = (double *)malloc(height * (width+1)*sizeof(double));
    double *magData = (double *)malloc(height * (width+1)*sizeof(double));
    
    struct gradListDouble *gradientList = (struct gradListDouble *)malloc(sizeof(gradientList));
    if(status == 1)
    {
       
        Canny(im_rgb, im_rgb, 5, 15, 3,TRUE);
    }
    else if (status == 2)
    {
        Canny(im_rgb, im_rgb, 3, 9, 3);
    }
    else
    {
        NSLog(@"You mad bro????");
    }
    
    cv::vector <cv::vector <cv::Point>> contours;
    findContours (im_rgb, contours, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_TC89_KCOS);
    
    for (int i = 0; i< height; i++)
    {
        for(int j = 0; j< width; j++)
        {
            int index = (i*width)+j;
            gradData[index] = ExclusionIndex;//0.0;
            magData[index] = ExclusionIndex;//0.0;
        }
    }
    
    int p = 0;
    
    cv::vector<cv::vector<cv::Point> >::iterator contour = contours.begin(); // const_iterator if you do not plan on modifying the contour
    for(; contour != contours.end(); ++contour) {
        // use *contour for current contour
        cv::vector<cv::Point>::iterator point = contour->begin(); // again, use const_iterator if you do not plan on modifying the contour
        double prevX = point->x, prevY = point->y;
        for(; point != contour->end(); ++point) {
            // use *point for current point
            //printf("*%d,%d*",point->x,point->y);
            double angle = PointPairToBearingDegrees(CGPointMake(prevX, prevY),CGPointMake(point->x, point->y)) ;
//            if(prevX!=point->x)
//            {
//                angle = (point->y - prevY)/(point->x - prevX) * 180/PI;
//            }
//            else
//            {
//                angle =  (point->y)>prevY?90:(point->y)==prevY?0.00:-90;
//            }
            double magnitude =   sqrt((pow((point->y - prevY), 2)) + (pow((point->x - prevX), 2)));
            int index = (point->x*height) + (point->y);
            magData[index] = magnitude;
            gradData[index] = angle;
            prevY = point->y, prevX = point->x;
//            printf("(%d, %d) :: ",point->x, point->y);
//            printf("\tangle = %f && magnitude = %f\n",angle,magnitude);
//            if(status == 1)
//            {
//                printf("index = %d\n", index);
//            }
        }
//        printf("%d contour",p++);
//        printf("\n******Done Contour*****\n");
    }
    
    if(status==1)
    {
        contour1 = contours;
    }
    else if (status == 2)
    {
        contour2 = contours;
    }
    
//    for (int i = 0; i< width; i++)
//    {
//        for(int j = 0; j< height; j++)
//        {
//            printf("*%04f*",gradData[(i*width)+j]);
//        }
//        printf("\n");
//    }
//    
    gradientList->magnitudeData = magData;
    gradientList->gradientData = gradData;
    
//    if(true/*status == 2*/)
//    {
//    cv::Mat drawing = cv::Mat::zeros( im_rgb.size(), CV_8UC3 );
//    for( int i = 0; i< contours.size(); i++ )
//    {
//        cv::Scalar color = cvScalar( rng.uniform(0, 255), rng.uniform(0,255), rng.uniform(0,255) );
//        cv::drawContours( drawing, contours, i, color, 2, 8, CV_RETR_EXTERNAL, 0, cv::Point() );
//    }
//    
//    UIImage *imgDebug = [self UIImageFromCVMat:drawing];
//    //testImage = imgDebug;
//     UIImageWriteToSavedPhotosAlbum(imgDebug, nil, nil, nil);
//    }
    return gradientList;
    
}

double PointPairToBearingDegrees(CGPoint startingPoint, CGPoint endingPoint)
{
    CGPoint originPoint = CGPointMake(endingPoint.x - startingPoint.x, endingPoint.y - startingPoint.y); // get origin point to origin by subtracting end from start
    double bearingRadians = atan2f(originPoint.y, originPoint.x); // get bearing in radians
    double bearingDegrees = bearingRadians * (180.0 / M_PI); // convert to degrees
    bearingDegrees = (bearingDegrees > 0.0 ? bearingDegrees : (360.0 + bearingDegrees)); // correct discontinuity
    ((bearingDegrees>180)  && (bearingDegrees<=360))?bearingDegrees-=180:TRUE;
    return bearingDegrees;
}

-(struct gradList *) sobelGradient : (UIImage *) img
{
   // NSLog(@"incoming height, width : %f, %f",img.size.height, img.size.width);
    
    unsigned char *gradData = (unsigned char *)malloc(img.size.height * img.size.width);
    unsigned char *magData = (unsigned char *)malloc(img.size.height * img.size.width);
    
    struct gradList *gradientList = (struct gradList *)malloc(sizeof(gradientList));
    
    cv::Mat im_rgb = [self cvMatFromUIImageNew:img];
    cv::Mat im_gray;
    
    cv::Mat grad_x, grad_y;
    cv::Mat abs_grad_x, abs_grad_y;
    
    cv::Mat grad, mag;
    
    int depth = CV_16S;
    int scale = 1;
    int delta = 0;
    
    cvtColor(im_rgb, im_gray, CV_RGBA2GRAY);
    
    Sobel( im_gray, grad_x, depth, 1, 0, 3, scale, delta, cv::BORDER_DEFAULT );
    convertScaleAbs( grad_x, abs_grad_x );
    
    Sobel( im_gray, grad_y, depth, 0, 1, 3, scale, delta, cv::BORDER_DEFAULT );
    convertScaleAbs( grad_y, abs_grad_y );
    
    addWeighted( abs_grad_x, 0.5, abs_grad_y, 0.5, 0, mag, -1 );
    
    divide(abs_grad_y, abs_grad_x, grad,1,-1);
    
    cv::resize(mag,mag,cv::Size(),3,1,cv::INTER_CUBIC);
    cv::resize(grad,grad,cv::Size(),3,1,cv::INTER_CUBIC);
    
    for(int i=0; i<mag.rows; i++)
    {
        for(int j=0; j<mag.cols/3; j++)     //potential issue with the column size here. Why on earth is it thrice the width of the original image?
        {
            magData[i + j] = GRADIENT(mag,i,j);
            double result = atan2(RESULTANT(grad_y,i,j), RESULTANT(grad_x,i,j))*180/PI;
            gradData[i + j] = atan2(RESULTANT(grad_y,i,j), RESULTANT(grad_x,i,j));//atan(GRADIENT(grad))*180/2*PI;
           // printf("%04f*",result);
        }
        printf("\n");
    }
//    printf("\n\n\n\n");
//    printf("******************");
//    printf("\n\n\n\n");
    gradientList->gradientData = gradData;
    gradientList->magnitudeData = magData;
    
    //NSLog(@"%d, %d, %d, %d", mag.rows, mag.cols, grad.rows, grad.cols);
    
    
    return gradientList;
}

-(UIImage*)threshold:(UIImage *)input_image:(int) low:(int) high
{
    cv::Mat im_rgb = [self cvMatGrayFromUIImage:input_image];
    // IplConvKernel *element = cvCreateStructuringElementEx(3,3,1,1,CV_SHAPE_RECT);
    
    cv::threshold(im_rgb, im_rgb, low, high, cv::THRESH_OTSU);
    
   // cv::floodFill(im_rgb, cv::Point(im_rgb.cols/2,im_rgb.rows/2), cv::Scalar(255.0,255.0,255.0));
    
    //cv::adaptiveThreshold(im_rgb,im_rgb,high,cv::ADAPTIVE_THRESH_MEAN_C,cv::THRESH_BINARY,9,0);
    //cv::morphologyEx(im_rgb,im_rgb,4,cv::getStructuringElement(cv::MORPH_RECT,cv::Size(3,3)));
    
//    cv::vector<cv::Vec3f> circles;
//    cv::HoughCircles(im_rgb, circles, CV_HOUGH_GRADIENT, 2, im_rgb.rows/4);
//    NSLog(@"Found %ld cirlces", circles.size());
    
    
    return [self UIImageFromCVMat:im_rgb];
}

-(UIImage *)floodFill:(UIImage *) image : (int) x : (int) y
{
    cv::Mat im_rgb = [self cvMatFromUIImage:image];
     cv::floodFill(im_rgb, cv::Point(x,y), cv::Scalar(255.0,255.0,255.0));
    return [self UIImageRGBFromCVMat:im_rgb];
}

-(UIImage*)watershedSegmentation:(UIImage *)input_image:(UIImage *) threshold
{
    cv::Mat im_gray = [self cvMatGrayFromUIImage:input_image];
    cv::Mat im_thresh = [self cvMatGrayFromUIImage:threshold];
    
    cv::Mat original = [self cvMatWSFromUIImage:threshold];

    cv::Mat markers(im_thresh.size(),CV_8U,cv::Scalar(200));
    
    //cv::Mat markers(im_thresh.size(),IPL_DEPTH_8U, 3);
    //markers = im_thresh;
    cv::vector<cv::Vec4i> hierarchy;
    //std::vector<std::vector<Point> > contours;
    
    typedef cv::vector<cv::vector<cv::Point> > TContours;
    TContours contours;
    
    
    cv::findContours(im_thresh, contours, hierarchy, CV_RETR_CCOMP, CV_CHAIN_APPROX_NONE);
    
    NSLog(@"size of contours : %ld",contours.size());
    
    cv::Vec4f line;
    
    //findContours( im_thresh, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, cv::Point(0, 0) );
    
    
//    cv::Mat drawing = cv::Mat::zeros( original.size(), CV_8UC3 );
//    for( int i = 0; i< contours.size(); i++ )
//    {
//        cv::Scalar color = cvScalar( rng.uniform(0, 255), rng.uniform(0,255), rng.uniform(0,255) );
//        cv::drawContours( drawing, contours, i, color, 2, 8, 0, 0, cv::Point() );
//    }
    
    markers.convertTo(markers, CV_32S);
    cv::watershed(original, markers);
    markers.convertTo(markers,CV_8U);
    
    return [self UIImageFromCVMat:markers];//[self UIImageFromCVMat:markers];
}

-(UIImage*)inpainting:(UIImage *)input_image:(UIImage *)maskImage: (CGRect) boundary: (CGPoint) boundaryOrigin
{
    cv::Mat im_rgb = [self cvMatWSFromUIImage:input_image];
    cv::Mat maskImageMat = [self cvMatGrayFromUIImage:maskImage];
    
    cv::cvtColor(im_rgb, im_rgb, CV_BGRA2BGR);
    //cv::cvtColor(maskImageMat, maskImageMat, CV_BGRA2BGR);

    cv::Mat mask(im_rgb.size(), _8Bit1Channel, cvScalar(0));
    
   // mask = maskImageMat;
    
    //cv::cvtColor(mask, mask, CV_BGR2GRAY);
    cv::threshold(maskImageMat,mask,3,255,cv::THRESH_BINARY);
    
    cv::floodFill(mask, cv::Point(im_rgb.cols/2,im_rgb.rows/2), cv::Scalar(255));
   
    /*
    cv::circle(mask, cv::Point(im_rgb.cols/2,im_rgb.rows/2), (im_rgb.cols>im_rgb.rows?im_rgb.rows:im_rgb.cols)/3, cvScalar(255), -1, 8, 0);
    */
    cv::inpaint(im_rgb, mask, im_rgb, 4, cv::INPAINT_TELEA);
    
    
    //cv::cvtColor(mask, mask, CV_GRAY2BGRA);
    
    return /*[self UIImageFromCVMat:mask];*/[self UIImageFromCVMat:im_rgb];
}

-(UIImage*)presetInpainting : (UIImage *) input_image : (int) radius : (int) feather : (int) mode : (int) x :(int) y
{
   
    cv::Mat im_rgb = [self cvMatWSFromUIImage:input_image];
    //cv::Mat maskImageMat = [self cvMatGrayFromUIImage:maskImage];
    
    cv::cvtColor(im_rgb, im_rgb, CV_BGRA2BGR);
    //cv::cvtColor(maskImageMat, maskImageMat, CV_BGRA2BGR);
    
    cv::Mat mask(im_rgb.size(), _8Bit1Channel, cvScalar(0));
    
    // mask = maskImageMat;
    
    //cv::cvtColor(mask, mask, CV_BGR2GRAY);
    //cv::threshold(maskImageMat,mask,3,255,cv::THRESH_BINARY);
    
    //cv::floodFill(mask, cv::Point(im_rgb.cols/2,im_rgb.rows/2), cv::Scalar(255));
    
    
     cv::circle(mask, cv::Point(x,y), radius, cvScalar(255), -1, 8, 0);
    
    if(mode==0)
    {
        
        
        cv::inpaint(im_rgb, mask, im_rgb, 7, cv::INPAINT_NS);
    }
    else
    {
        cv::inpaint(im_rgb, mask, im_rgb, 4, cv::INPAINT_TELEA);
    }
    
    
    
    //cv::cvtColor(mask, mask, CV_GRAY2BGRA);
    
    return /*[self UIImageFromCVMat:mask];*/[self UIImageFromCVMat:im_rgb];
}

-(UIImage *)line :(UIImage *) image : (int) x1 : (int) y1 : (int) x2 : (int) y2
{
    cv::Mat im_rgb = [self cvMatWSFromUIImage:image];
   // cv::cvtColor(&im_rgb, im_rgb, CV_BGRA2BGR);
    
    cv::cvtColor(im_rgb, im_rgb, CV_BGRA2BGR);
    
    cv::Mat matrix1 (im_rgb.size(), _8Bit1Channel, cvScalar(0));
    
    cv::cvtColor(im_rgb, im_rgb, CV_BGR2GRAY);
    
    cv::threshold(im_rgb,matrix1,3,255,cv::THRESH_BINARY_INV);
    
    cv::line(matrix1, cv::Point(x1,y1), cv::Point(x2,y2), cvScalar(255),2,8,0);
    //cv::circle(matrix1, cv::Point(x2,y2), 3, cvScalar(255), -1, 8, 0);
    
    return [self UIImageFromCVMat:matrix1];
}


#pragma utils

- (IplImage *)CreateIplImageFromUIImage:(UIImage *)image {
    // Getting CGImage from UIImage
    CGImageRef imageRef = image.CGImage;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Creating temporal IplImage for drawing
    IplImage *iplimage = cvCreateImage(cvSize(image.size.width,image.size.height), IPL_DEPTH_8U, 4);
    // Creating CGContext for temporal IplImage
    CGContextRef contextRef = CGBitmapContextCreate(
                                                    iplimage->imageData, iplimage->width, iplimage->height,
                                                    iplimage->depth, iplimage->widthStep,
                                                    colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault
                                                    );
    // Drawing CGImage to CGContext
    CGContextDrawImage(
                       contextRef,
                       CGRectMake(0, 0, image.size.width, image.size.height),
                       imageRef
                       );
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    // Creating result IplImage
    IplImage *ret = cvCreateImage(cvGetSize(iplimage), IPL_DEPTH_8U, 3);
    cvCvtColor(iplimage, ret, CV_RGBA2BGR);
    cvReleaseImage(&iplimage);
    
    return ret;
}

- (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();//CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, _8Bit1Channel); // 8 bits per component, 1 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNone |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    return cvMat;
}
- (cv::Mat)cvMatGrayDefaultFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC1); // 8 bits per component, 1 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    return cvMat;
}

- (cv::Mat)cvMatWSFromUIImage:(UIImage *)image
{
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGFloat cols = image.size.width;
//    CGFloat rows = image.size.height;
//    
//    cv::Mat cvMat(rows, cols, CV_8UC3); // 8 bits per component, 1 channels
//    
//    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to data
//                                                    cols,                       // Width of bitmap
//                                                    rows,                       // Height of bitmap
//                                                    8,                          // Bits per component
//                                                    cvMat.step[0],              // Bytes per row
//                                                    colorSpace,                 // Colorspace
//                                                    kCGImageAlphaNone |
//                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
//    
//    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
//    CGContextRelease(contextRef);
//    CGColorSpaceRelease(colorSpace);
    
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, _8Bit4Channel); // 8 bits per component, 4 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaPremultipliedLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    // CGColorSpaceRelease(colorSpace);
    
    
    return cvMat;
}


- (UIImage *)UIImageGrayFromIplImage:(IplImage *)image {
    //CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); //this is for RGB image
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    // Allocating the buffer for CGImage
    NSData *data =
    [NSData dataWithBytes:image->imageData length:image->imageSize];
    CGDataProviderRef provider =
    CGDataProviderCreateWithCFData((CFDataRef)data);
    // Creating CGImage from chunk of IplImage
    CGImageRef imageRef = CGImageCreate(
                                        image->width, image->height,
                                        image->depth, image->depth * image->nChannels, image->widthStep,
                                        colorSpace, kCGImageAlphaNone|kCGBitmapByteOrderDefault,
                                        provider, NULL, false, kCGRenderingIntentDefault
                                        );
    // Getting UIImage from CGImage
    UIImage *ret = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    return ret;
}

- (UIImage *)UIImageRGBFromIplImage:(IplImage *)image {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); 
    // Allocating the buffer for CGImage
    NSData *data =
    [NSData dataWithBytes:image->imageData length:image->imageSize];
    CGDataProviderRef provider =
    CGDataProviderCreateWithCFData((CFDataRef)data);
    // Creating CGImage from chunk of IplImage
    CGImageRef imageRef = CGImageCreate(
                                        image->width, image->height,
                                        image->depth, image->depth * image->nChannels, image->widthStep,
                                        colorSpace, kCGImageAlphaNone|kCGBitmapByteOrderDefault,
                                        provider, NULL, false, kCGRenderingIntentDefault
                                        );
    // Getting UIImage from CGImage
    UIImage *ret = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    return ret;
}

-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(( CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

-(UIImage *)UIImageRGBFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
//    if (cvMat.elemSize() == 1) {
//        colorSpace = CGColorSpaceCreateDeviceGray();
//    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
//    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC3); // 8 bits per component, 4 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNone |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    return cvMat;
}

- (cv::Mat) cvMatFromDataArray : (unsigned char *) data : (int) rows : (int) cols
{
    cv::Mat cvMat(rows, cols, _8Bit4Channel, data);
    return cvMat;
}

- (cv::Mat)cvMatDefaultFromUIImage:(UIImage *)image : (int) height : (int) width
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = width;//image.size.width;
    CGFloat rows = height;//image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    return cvMat;
}

- (cv::Mat)cvMatFromUIImageNew:(UIImage *)image {
    
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    return cvMat;
}

@end

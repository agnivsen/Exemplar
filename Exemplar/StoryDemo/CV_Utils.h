//
//  CV_Utils.h
//  StoryDemo
//
//  Created by agniva on 28/06/13.
//

#import <UIKit/UIKit.h>

#define GRADIENT(grad,i,j) (grad.at<cv::Vec3b>(i,j)[0] + grad.at<cv::Vec3b>(i,j)[1] + grad.at<cv::Vec3b>(i,j)[2])/3
#define RESULTANT(grad,i,j) sqrt(  pow( grad.at<cv::Vec3b>(i,j)[0],2) +  pow( grad.at<cv::Vec3b>(i,j)[1],2) +  pow( grad.at<cv::Vec3b>(i,j)[2],2) )
#define PI  3.1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679
#define ExclusionIndex  361.0000


@interface CV_Utils : UIViewController


struct fillFront
{
    int x;
    int y;
    int texelSize;
    double _nP;
    double _cP;
    double _dP;
    double _iP;
    struct fillFront *next;
};

struct gradient
{
    //again, may not be in final structure
    float magnitude;
    float angle;
    struct gradient *next;
};

struct gradList
{
    unsigned char *gradientData;
    unsigned char *magnitudeData;
};

struct gradListDouble
{
    double *gradientData;
    double *magnitudeData;
};




-(UIImage*)decolor:(UIImage *)input_image;
-(UIImage*)smoothMedian:(UIImage *) input_image : (int) size;
-(UIImage*)morphologicalGradient:(UIImage *) input_image : (int) size;
-(void)findContour : (UIImage*)input_image;
-(UIImage*)canny : (UIImage*)input_image;
-(struct fillFront *)fillFrontFromContour : (unsigned char *) data : (int) tex : (int) height : (int) width;
-(UIImage*)threshold:(UIImage *) input_image : (int) low : (int) high;
-(UIImage*)watershedSegmentation:(UIImage *) input_image : (UIImage *) threshold;
-(UIImage*)inpainting:(UIImage *) input_image : (UIImage *) maskImage : (CGRect) boundary : (CGPoint) boundaryOrigin;
-(UIImage *)floodFill:(UIImage *) image : (int) x : (int) y;
-(UIImage*)presetInpainting : (UIImage *) input_image : (int) radius : (int) feather : (int) mode : (int) x :(int) y;
-(UIImage *)line :(UIImage *) image : (int) x1 : (int) y1 : (int) x2 : (int) y2;
-(struct gradList *) sobelGradient : (UIImage *) img;
-(struct gradListDouble *) cannyGradient : (unsigned char *)img : (int) height : (int) width : (int) status;
-(void) compareContour;
    -(UIImage*)erosion:(UIImage *)input_image;
    -(UIImage*)dilation:(UIImage *)input_image;
@end

UIImage *testImage;


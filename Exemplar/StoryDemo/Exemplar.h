//
//  Exemplar.h
//  StoryDemo
//
//  Created by agniva on 15/07/13.
//

#import <UIKit/UIKit.h>
#import "CV_Utils.h"

/*Debug related code*/
#import "FixedRadViewController.h"
/*Debug related code*/


#define EUCLEDIAN_DISTANCE(x,y,x1,y1) sqrt(pow((x1-x), 2) + pow((y1-y), 2))

@interface Exemplar : UIViewController

struct texel
{
    //not the final structure. to be modified...
    int     x;
    int     y;
    int     size;
    struct texel *next;
};



struct gradientData
{
    unsigned char *image;
    unsigned char *mask;
};

struct pixel
{
    int x;
    int y;
};

/*Debug Structure*/
struct sobel
{
    float magnitude;
    float angle;
    float x;
    float y;
    struct sobel *next;
};


/*Debug Structure*/

-(UIImage*) exemplarWithMask : (UIImage *) image : (UIImage *) mask;
-(Float32)getProgress;

@property (nonatomic, assign) Float32 progress;

-(void)setCallbackImageView : (UIImageView *) imgView;

@end

unsigned char *debugImage;

struct gradListDouble *gradOfImage, *gradOfMask;

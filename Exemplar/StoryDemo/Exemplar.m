//
//  Exemplar.m
//  StoryDemo
//
//  Created by agniva on 15/07/13.
//

#import "Exemplar.h"

@interface Exemplar ()

@end

@implementation Exemplar
@synthesize progress;

int texel;

UIImageView *imageView;

#pragma mark UI Methods
-(Float32)getProgress       //this method returns the value of 'progress' which updates the progress bar in the UI. nothing to do with the algorithm.
{
    return progress;
}

-(void)setCallbackImageView : (UIImageView *) imgView
{
    imageView = imgView;
}

-(void) setImage : (UIImage *) img
{
    [imageView setImage:img];
}

-(double) getIntensityDiff : (double) val1 : (double) val2
{
    //return the minimum intensity difference
    if(val1<val2)
        return val1;
    else
        return val2;
}

#pragma mark Pre-Processing

-(UIImage *)resizeImage:(UIImage *)image width:(int)width height:(int)height
{
    /*Resizes the input image : 'image' to the input height and width.*/
	
	CGImageRef imageRef = [image CGImage];
	CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
	alphaInfo = kCGImageAlphaPremultipliedLast;
	CGContextRef bitmap = CGBitmapContextCreate(NULL, width, height, CGImageGetBitsPerComponent(imageRef), 4 * width, CGImageGetColorSpace(imageRef), alphaInfo);
	CGContextDrawImage(bitmap, CGRectMake(0, 0, width, height), imageRef);
	CGImageRef ref = CGBitmapContextCreateImage(bitmap);
	UIImage *result = [UIImage imageWithCGImage:ref];
	CGContextRelease(bitmap);
	CGImageRelease(ref);
	return result;
}

#pragma mark Cost Function and Fill-front

-(struct gradient *) sobelFilterWithOpenCV : (int) mode : (int) x : (int) y : (int) height : (int) width : (int) texel
{
    //mode = 1 :: for image
    //mode = 2 :: for mask
    
    switch (mode) {
        case 1:
        {
            struct gradient *grad = (struct gradient *)malloc(sizeof(grad));
            grad->angle  = 0;
            grad->magnitude  = 0;

            for(int i = x - (texel/2); i<x+(texel/2); i++)
            {
                for(int j = y - (texel/2); j<y+(texel/2); j++)
                {
                    int index = (j*height)+(i);
                    if((gradOfImage->magnitudeData[index]>grad->magnitude)   && (gradOfImage->magnitudeData[index]!=ExclusionIndex))
                    {
                        grad->angle = gradOfImage->gradientData[index];
                        grad->magnitude = gradOfImage->magnitudeData[index];
                    }
                    
                }
            }
            return grad;
        }
            break;
        case 2:
        {
            struct gradient *grad = (struct gradient *)malloc(sizeof(grad));
            grad->angle  = 0;
            grad->magnitude  = 0;
            
            for(int i = x - (texel/2); i<x+(texel/2); i++)
            {
                for(int j = y - (texel/2); j<y+(texel/2); j++)
                {
                    int index = (j*height)+(i);
                    if((gradOfMask->magnitudeData[index]>grad->magnitude)   && (gradOfMask->magnitudeData[index]!=ExclusionIndex))
                    {
                        grad->angle = gradOfMask->gradientData[index];
                        grad->magnitude = gradOfMask->magnitudeData[index];
                    }
                }
            }
            return grad;
        }
            break;
            
        default:
            return Nil;
    }
    
    return Nil;
}

-(struct gradient *) sobelFilter : (unsigned char *) inputBuffer : (int) height : (int) width : (size_t) bytesPerRow : (int) x : (int) y :(int) rad
{
    
    
    unsigned char *greyData = malloc(height * width);
    
    struct gradient *grad = malloc(sizeof(grad));
    rad =5;
    
    y/=4;
    
    long step = 4 * width;
    for(int i=0; i<height; i++)
    {
        int is = i * step;
        int os = i * width;
        for(int j=0; j<4*width; j+=4)
        {
            greyData[os + j/4] = (inputBuffer[is + j] + inputBuffer[is + j+1] + inputBuffer[is + j+2]) / 3;

        }
    }

    if ((x > rad) && (y < ((width)-(rad))) && (y > rad) && (x < height-rad))
    {
    int sThis =     y * width;
    int sPrev =     (y - 1) * width;
    int sNext =     (y + 1) * width;
    int sPrev2 =    (y - 2) * width;
    int sNext2 =    (y + 2) * width;
    
    
     /*Scharr operator*/

        
   double vComp =   greyData[sPrev2 + x - 2] + 2*greyData[sPrev2 + x - 1] + 3*greyData[sPrev2 + x] + 2*greyData[sPrev2 + x + 1] + greyData[sPrev2 + x + 2] +
                    greyData[sPrev + x - 2]  + 2*greyData[sPrev + x - 1]  + 6*greyData[sPrev + x]  + 2*greyData[sPrev + x + 1]  + greyData[sPrev + x + 2] -
                    greyData[sNext + x - 2]  - 2*greyData[sNext + x - 1]  - 6*greyData[sNext + x]  - 2*greyData[sNext + x + 1]  - greyData[sNext + x + 2] -
                    greyData[sNext2 + x - 2] - 2*greyData[sNext2 + x - 1] - 3*greyData[sNext2 + x] - 2*greyData[sNext2 + x + 1] - greyData[sNext2 + x + 2] ;
        
        
    double hComp =  greyData[sPrev2 + x - 2] + 2*greyData[sPrev + x - 2] + 3*greyData[sThis + x - 2] + 2*greyData[sNext + x - 2] + greyData[sNext2 + x - 2] +
                    greyData[sPrev2 + x - 1] + 2*greyData[sPrev + x - 1] + 6*greyData[sThis + x - 1] + 2*greyData[sNext + x - 1] + greyData[sNext2 + x - 1] -
                    greyData[sPrev2 + x + 1] - 2*greyData[sPrev + x + 1] - 6*greyData[sThis + x + 1] - 2*greyData[sNext + x + 1] - greyData[sNext2 + x + 1] -
                    greyData[sPrev2 + x + 2] - 2*greyData[sPrev + x + 2] - 3*greyData[sThis + x + 2] - 2*greyData[sNext + x + 2] - greyData[sNext2 + x + 2] ;
        
    
    double magnitude = sqrt(vComp * vComp + hComp * hComp);

        double direction =atan2(vComp, hComp);
    
    grad->magnitude = magnitude;
    grad->angle = direction ;
    grad->next = NULL;

        
        free(greyData);
    return grad;
    }
    else
    {
        free(greyData);
        return Nil;
    }
}


-(int) getPatchPriorityList : (struct fillFront *) front : (unsigned char *) image : (unsigned char *) mask : (size_t) bytesPerRow : (int) height : (int) width
{
    double maxWeight = -100000, maxIndex = 1;
    int index = 0;
    
    for(;front->next!=NULL;front=front->next)
    {
        int sumOfConfidence = 0;
        int avgSample = 0, count = 0;
        for(int k = (front->x-texel/2); k < (front->x+texel/2); k++)
        {
            for(int l = (front->y - (4*texel)/2); l < (front->y + (4*texel)/2); l+=4)
            {
                long indexSample = (k*bytesPerRow) + l;
                sumOfConfidence+=mask[indexSample+0]==0?10:0;
                avgSample = image[indexSample+0] + image[indexSample+1] + image[indexSample+2];
                count++;
            }
        }
        
        avgSample/=(count*3);
        
        
        front->_cP = (float)sumOfConfidence/(float)(texel*texel);

        struct gradient *gradImage = [self sobelFilterWithOpenCV :1 :front->x :front->y/4 : height : width : texel];
        
        //NSLog(@"******MASK*********");
        struct gradient *gradMask = [self sobelFilterWithOpenCV :2 :front->x :front->y/4 : height : width : texel];
       if((gradMask->angle!=ExclusionIndex)   &&  (gradImage->angle!=ExclusionIndex))
        {
            float deg = (ABS((gradImage->angle) - (gradMask->angle))*PI/180);
            front->_dP = ABS((sin(deg)));
        }
        else
        {
            front->_dP = 0;
        }
       
        double x;
        ((x = front->_dP*front->_cP)> maxWeight)?(maxWeight = front->_dP*front->_cP,maxIndex = index++):(index++);
        free(gradImage);
        free(gradMask);

    }
    
    if(index == 1)
        return -1;
    else
        return maxIndex;
}


#pragma mark Core Algorithm

-(UIImage*) exemplarWithMask : (UIImage *) image : (UIImage *) regionOfInterest
{
    
    /************************************************************************/
    /*      The terms "Region Of Interest" and "mask" are same.        */
    /*      The terms 'patch' and 'texel' implies the same thing            */
    /************************************************************************/
    
    /********************************************************************************************************************/
    /*      'image' is the source image on which the inpainting is to be done                                           */
    /*      'regionOfInterest' is the image overlay which denotes the manually selected area to be inpainted            */
    /*      'regionOfInterest' has [x,y,z,255] RGBA value for pixels which are to be inpainted, where {x,y,z > 0}       */
    /*      'regionOfInterest' has [0,0,0,0] RGBA value for pixels which are to be ignored.                             */
    /********************************************************************************************************************/
    
    texel = 8;  //the size of texel always needs to be an even number
    //crank this up and down. depending on the size of your image
    
    progress = 0.8;
  
    gradOfImage = malloc(sizeof(gradOfImage));
    
    //'texel' is the patch size that we use through out the algorithm
    
    UIImage *mask =                 [self resizeImage :regionOfInterest width:CGImageGetWidth([image CGImage]) height:CGImageGetHeight([image CGImage]) ];
    
    CGImageRef imageBuffTarget =    [image CGImage];
    CGImageRef imageBuffMask =      [mask CGImage];

    NSUInteger width_target =       CGImageGetWidth(imageBuffTarget);
    NSUInteger height_target =      CGImageGetHeight(imageBuffTarget);
    NSUInteger width_mask =         CGImageGetWidth(imageBuffMask);
    NSUInteger height_mask =        CGImageGetHeight(imageBuffMask);
 
    size_t bytesPerRow_target =     CGImageGetBytesPerRow(imageBuffTarget);
    size_t bytesPerPixel_target =   CGImageGetBitsPerComponent(imageBuffTarget);
    size_t bytesPerRow_mask =       CGImageGetBytesPerRow(imageBuffMask);
    size_t bytesPerPixel_mask =     CGImageGetBitsPerComponent(imageBuffMask);
    
    
    
    unsigned char *target_image =   [self getArray :image :FALSE];
    unsigned char *mask_image =     [self getArray :mask :FALSE];
    /*debug shit begins*/
    debugImage =   (unsigned char *)malloc(height_target*bytesPerPixel_target*width_target);
   // memcpy(debugImage, target_image, height_target*bytesPerPixel_target*width_target);
    /*debug shit ends*/
    
    unsigned char *output_image =   [self getPreprocessedImage:height_target :width_target :bytesPerPixel_target :bytesPerRow_target];
    BOOL loop =                     TRUE;
    
    int count;
    
    /*A little bit of hard-coded linear-thresholding here, just to dispel my fear of the unknown.*/
    for(int k = 0; k < height_mask; k++)
    {
        for(int l = 0; l < bytesPerRow_target; l+=4)
        {
            if(!((mask_image[k*bytesPerRow_target + l + 0]==0)&&(mask_image[k*bytesPerRow_target + l + 1]==0)&&(mask_image[k*bytesPerRow_target + l + 2]==0)))
            {
                mask_image[k*bytesPerRow_target + l + 0] = 180;
                mask_image[k*bytesPerRow_target + l + 1] = 180;
                mask_image[k*bytesPerRow_target + l + 2] = 180;
                mask_image[k*bytesPerRow_target + l + 3] = 180;
            }
        }
    }
    

    
    while (loop)
    {
        
    /******OpenCV is being used, for finding the contour of the RoI.******/
    CV_Utils *openCV =              [[CV_Utils alloc] init];
    struct fillFront *front =       [openCV fillFrontFromContour :mask_image :texel :height_mask :width_mask];    //getting the entire fill front
        if (count>0)
        {
            free(gradOfImage);
            free(gradOfMask);
        }
        
        gradOfImage = [openCV cannyGradient: target_image : height_target :width_target : 1];
        
        gradOfMask = [openCV cannyGradient :mask_image :height_mask :width_mask : 2];
        [openCV compareContour];
    [openCV release];
       
        
    count = 0;
        
    if((front!=NULL))
        {
        struct fillFront *frontCopy =   front;
        int texelIndex =                [self getPatchPriorityList :frontCopy :target_image :mask_image : bytesPerRow_target : height_mask : width_mask];   //getting the texel index for which the priority is the highest
            
        texelIndex<0?loop=FALSE:TRUE;       //fun with ternary operators, infinite loop killer.
        
        float scaled =                  (float)bytesPerRow_mask/(float)bytesPerRow_target;
        NSUInteger height =             height_target;
        NSUInteger width =              width_target;

        BOOL localLoop = TRUE;
            int noOfPoints = 0;
            
        for(;front->next!=NULL&&localLoop;front = front->next,count++)
            {
                if(count==texelIndex)
                    {
                    CGPoint point =  [self getTexel:target_image :mask_image :CGPointMake(front->x , front->y) :texel :scaled :height :width :bytesPerRow_target :bytesPerRow_mask];    //this point represents the patch which best matches the highest priority texel

                    int x1 = point.x-texel/2;
                       
                    for(int k = (front->x-texel/2); k < (front->x+texel/2); )
                        {
                            int y1 = point.y - (4*texel/2);
                            for(int l = (front->y - (4*(texel/2))); l < (front->y + (4*(texel/2)));)
                            {
                                long indexSample = (k*bytesPerRow_target) + l;
                                long indexTarget = (x1*bytesPerRow_target) + y1;
                                
                                
                                if((mask_image [indexSample+0] > 0)&&(mask_image [indexSample+1] > 0)&&(mask_image [indexSample+2] > 0)&&(output_image[indexSample+3] !=   240))
                                {
                                    output_image[indexSample+0] =   target_image[indexTarget+0];
                                    output_image[indexSample+1] =   target_image[indexTarget+1];
                                    output_image[indexSample+2] =   target_image[indexTarget+2];
                                    output_image[indexSample+3] =   240;
                                    
                                    target_image[indexSample+3] = 240;
                                    
                                  
                                    mask_image[indexSample+0]   =   0;
                                    mask_image[indexSample+1]   =   0;
                                    mask_image[indexSample+2]   =   0;
                                    mask_image[indexSample+3]   =   0;
                                }
                               
                                noOfPoints++;
                                y1+=4;
                                l+=4;
                                
                            }
                            x1++;
                            k++;
                        }
                        localLoop = FALSE;
                        
                        
                        /*all debug stuff, delete finally*/
                          dispatch_sync(dispatch_get_main_queue(), ^{
                        unsigned char *output_image2 = (unsigned char *)malloc(height_target*bytesPerPixel_target*width_target);
                        memcpy(output_image2, output_image, (height_target*bytesPerPixel_target*width_target));
                              [self setImage:[self debugImage :output_image2 :target_image :height_target :width_target :bytesPerRow_target :bytesPerPixel_target :CGImageGetColorSpace(imageBuffTarget) :CGImageGetBitmapInfo(imageBuffTarget): point.x: point.y: texel/2 : front->x : front->y]];

                          });
                        //This part of the program is being used to paint the blue and red square markers on the display image.
                        //Can be removed if faster execution is required
                        //However, given that the code is already quite slow, optimizing just this bit wouldn't result in any noticeable performance improvement
                        
                        /*debug begins*/
                        debugImage = Nil;
                        
                        /*debug ends*/

                    }
            }
        }
    else
        {
            loop = FALSE;   //infinite loop's career cut short.
        }


    }

   
    return [self finalImage:output_image :target_image :height_target :width_target :bytesPerRow_target :bytesPerPixel_target :CGImageGetColorSpace(imageBuffTarget) :CGImageGetBitmapInfo(imageBuffTarget)];

}


-(CGPoint) getTexel : (unsigned char *) image : (unsigned char *) mask : (CGPoint) point : (int) texelSize : (float) imageScale : (NSUInteger) height : (NSUInteger) width : (size_t) bytesPerRow_target : (size_t) bytesPerRow_mask
{
    
    double leastRMS = MAXFLOAT;          //an arbitrarily high value to start with, assuming that the mean squared difference will be always less than this.
    CGPoint leastPoint;
    double leastRGB = MAXFLOAT;
    
    int threshold = 10;
    
    double maxIndex = (height*bytesPerRow_mask) + width;
    
    long currIndex = 0;
    
    for (int i=(texelSize+1); i<(height-(texelSize+1));i++) //zone of exclusion has been increased from texel/2 to texel
    {
        long stepWidth = i * bytesPerRow_target;
        for (int j=4*(texelSize+1); j<(bytesPerRow_target-4*(texelSize+1)); j+=4)
        {
            currIndex= stepWidth + j;
            
            if([self checkMaskOverlay :mask :image :i :j :bytesPerRow_target :texelSize])/*checking if the texel/patch lies outside the RoI mask.*/
            {
                double sum = 0;
                
                sum = [self texelCostFunction:mask :image :bytesPerRow_target :i :j :texelSize :point :maxIndex :TRUE];
                
                sum/=(texel * texel);

                if((sum)<(leastRMS-threshold))
                {
                    leastRMS = sum;
                    leastPoint = CGPointMake(i, j);
                    leastRGB = [self texelCostFunction:mask :image :bytesPerRow_target :i :j :texelSize :point :maxIndex :FALSE];
                }
                else if((sum>(leastRMS-threshold))&&(sum<(leastRMS+threshold))/*(sum)==leastRMS*/)
                {
                     double newRGB = [self texelCostFunction:mask :image :bytesPerRow_target :i :j :texelSize :point :maxIndex :FALSE];
                    
                    if(newRGB < leastRGB)
                    {
                        leastRMS = sum;
                        leastPoint = CGPointMake(i, j);
                        leastRGB = newRGB;
                    }
                }
                
            }
        }
        
    }
    
    
    return leastPoint;
}


-(double) texelCostFunction : (unsigned char *) mask : (unsigned char *) image : (size_t) bytesPerRow : (int) i : (int) j : (int) texelSize : (CGPoint) point : (double) maxIndex : (BOOL) mode
{
    double sum = 0;
    
    int x = point.x-(texelSize/2);
    int y;
    
    for(int k = i-(texelSize/2); k < (i+(texelSize/2)); )
    {
        long stepWidthSmall = k * bytesPerRow;
        y = point.y-(4*(texelSize/2));
        
        for(int l = (j-(4*(texelSize/2))); l < (j+(4*(texelSize/2))); )
        {
            long int indexTarget = ((bytesPerRow * x) + y);
            long int indexSample = (stepWidthSmall + l);
            
            
            if(mask[indexTarget+0]==0&&mask[indexTarget+1]==0&&mask[indexTarget+2]==0&&((indexSample<maxIndex)&&(indexTarget<maxIndex)))
            {
            
                if (mode)
                {
                    double vec  =       sqrt(pow((l-y), 2) + pow((k-x), 2));
                    sum         +=      vec*vec;
                }
                else
                {
                    double vec  =       abs(image[indexSample] - image[indexTarget]);
                    sum         +=      vec*vec;
                    vec         =       abs(image[indexSample+1] - image[indexTarget+1]);
                    sum         +=      vec*vec;
                    vec         =       abs(image[indexSample+2] - image[indexTarget+2]);
                    sum         +=      vec*vec;
                }
                
                
            }
            y+=4;
            l+=4;
        }
        x++;
        k++;
    }
    
    return sum;
}

#pragma mark Utilities

-(unsigned char*)getArray : (UIImage *) image : (BOOL) flag
{
    CGImageRef imageBuff = [image CGImage];
    
    NSUInteger height = CGImageGetHeight(imageBuff);
    
    size_t bytesPerRow = CGImageGetBytesPerRow(imageBuff);
    
    CFMutableDataRef pixelDataTarget = CFDataCreateMutableCopy(kCFAllocatorDefault, 0, CGDataProviderCopyData(CGImageGetDataProvider(imageBuff)));
    
    unsigned char *input_image = (unsigned char *)CFDataGetMutableBytePtr(pixelDataTarget);
    unsigned char *output_image = (unsigned char *)malloc(height*bytesPerRow);
    
    for (int i=0; i<height;i++)
    {
        long stepWidth = i * bytesPerRow;
        for (int j=0; j<bytesPerRow; j+=4)
        {
            output_image[stepWidth + (j)+0] = input_image[stepWidth + (j)+0];
            output_image[stepWidth + (j)+1] = input_image[stepWidth + (j)+1];
            output_image[stepWidth + (j)+2] = input_image[stepWidth + (j)+2];
            output_image[stepWidth + (j)+3] = input_image[stepWidth + (j)+3];

        }

    }
    CFRelease(pixelDataTarget);

    return output_image;
}


-(UIImage *)finalImage : (unsigned char *) output_image : (unsigned char *) target_image : (int) height_target : (int) width_target : (size_t) bytesPerRow : (size_t) bytesPerPixel : (CGColorSpaceRef) colorSpace : (CGBitmapInfo) bmpInfo
{
    for(int k = 0; k < height_target; k++)
    {
        for(int l = 0; l < bytesPerRow; l+=4)
        {
            long indexSample = (k*bytesPerRow) + l;
            
            if(output_image[indexSample+3]==255)
            {
                output_image[indexSample+0] = target_image[indexSample+0];
                output_image[indexSample+1] = target_image[indexSample+1];
                output_image[indexSample+2] = target_image[indexSample+2];
            }
            output_image[indexSample+3] = 255;
            
        }
    }

    
    CGContextRef context = CGBitmapContextCreate(output_image, width_target, height_target, bytesPerPixel, bytesPerRow, colorSpace, bmpInfo);
    CGImageRef baseRef = CGBitmapContextCreateImage (context);
    UIImage *finalImage = [UIImage imageWithCGImage:baseRef];
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    UIImageWriteToSavedPhotosAlbum(finalImage, nil, nil, nil);
    NSError *error;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    // Point to Document directory
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    // Write out the contents of home directory to console
   // NSLog(@"Documents directory: %@", [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error]);
    return  finalImage;
    
}


-(Boolean)checkMaskOverlay : (UInt8 *) mask : (UInt8 *) target : (int) i : (int) j : (size_t) bytesPerRow : (int) texelSize
{

    BOOL logic = TRUE;
    for(int k = i-(texelSize/2); k < (i+(texelSize/2)); k++)
    {
        long stepWidthSmall = k * bytesPerRow;
        
        for(int l = (j-(4*(texelSize/2))); l < (j+(4*(texelSize/2))); l+=4)
        {
            long int indexSample = (stepWidthSmall + l);
            
            if(!(mask[indexSample+0]==0&&mask[indexSample+1]==0&&mask[indexSample+2]==0&&target[indexSample+3]!=240))
            {
                logic = FALSE;
                return logic;
            }
        }
    }
    return logic;
}


-(unsigned char *)getPreprocessedImage : (int) height_target : (int) width_target : (size_t) bytesPerPixel_target : (size_t) bytesPerRow_target
{
    unsigned char *image =   (unsigned char *)malloc(height_target*bytesPerPixel_target*width_target);
    for(int k = 0; k < height_target; k++)
    {
        for(int l = 0; l < bytesPerRow_target; l+=4)
        {
            long index = (k*bytesPerRow_target) + l;
            image[index+3] = 255;
            
        }
    }
    return image;
}

#pragma mark Debug Tools


-(UIImage *)debugImage : (unsigned char *) output_image : (unsigned char *) target_image : (int) height_target : (int) width_target : (size_t) bytesPerRow : (size_t) bytesPerPixel : (CGColorSpaceRef) colorSpace : (CGBitmapInfo) bmpInfo : (int) markerX : (int) markerY : (int) size : (int) orgX : (int) orgY
{
    for(int k = 0; k < height_target; k++)
    {
        for(int l = 0; l < bytesPerRow; l+=4)
        {
            long indexSample = (k*bytesPerRow) + l;
            
            if(output_image[indexSample+3]==255)
            {
                output_image[indexSample+0] = target_image[indexSample+0];
                output_image[indexSample+1] = target_image[indexSample+1];
                output_image[indexSample+2] = target_image[indexSample+2];
            }
            
        }
    }
    
    for(int k = markerX-size; k < markerX+size; k++)
    {
        for(int l = markerY-(4*size); l < markerY+4*size; l+=4)
        {
            long indexSample = (k*bytesPerRow) + l;
            
            if((k==markerX-size)||(k==markerX+size-1)||(l == markerY-(4*size))||(l == markerY+4*size-4))
            {
                output_image[indexSample+0] = 255;
                output_image[indexSample+1] = 0;
                output_image[indexSample+2] = 0;
            }
            
        }
    }
    
    BOOL pulse = TRUE;
    int count = 0;
    for(int k = orgX-size; k < orgX+size; k++)
    {
        for(int l = orgY-(4*size); l < orgY+4*size; l+=4)
        {
            long indexSample = (k*bytesPerRow) + l;
            
            if((k==orgX-size)||(k==orgX+size-1)||(l == orgY-(4*size))||(l == orgY+4*size-4))
            {
                output_image[indexSample+0] = 0;
                output_image[indexSample+1] = 0;
                output_image[indexSample+2] = pulse?255:0;
                ++count%2==0?pulse=!pulse:0;
            }
            
        }
    }

    
    CGContextRef context = CGBitmapContextCreate(output_image, width_target, height_target, bytesPerPixel, bytesPerRow, colorSpace, bmpInfo);
    CGImageRef baseRef = CGBitmapContextCreateImage (context);
    UIImage *finalImage = [UIImage imageWithCGImage:baseRef];
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    return  finalImage;
}

@end

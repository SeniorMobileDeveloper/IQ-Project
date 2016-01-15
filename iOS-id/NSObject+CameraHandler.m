//
//  NSObject+CameraHandler.m
//  iOS-id
//
//  Created by stephen on 10/20/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import "NSObject+CameraHandler.h"

@implementation NSObject (CameraHandler)


- (UIImagePickerController *)createPicturePicker:(id)parent {
    
    // create picture control
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = parent;
    picker.allowsEditing = YES;
    
    // Allowing access to albums and photo library is as simple as changing the source type
    // UIImagePickerControllerSourceTypePhotoLibrary
    // UIImagePickerControllerSourceTypeSavedPhotosAlbum
    // UIImagePickerControllerSourceTypeCamera
    
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    return  picker;
}
- (UIImagePickerController *)createLibraryPicker:(id)parent; {
    
    // create library control
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = parent;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    return  picker;
}
- (NSDictionary *)savePickerPictureToDisk:(UIImage *)picture {
   
    // time test
    //double d = CFAbsoluteTimeGetCurrent();
    //NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970];
    
    
    // Store image to disk.
    NSData *imageData = UIImagePNGRepresentation(picture);
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *imageName = [NSString stringWithFormat:@"%@-.png",[NSDate date]];
    NSString *path = [docDir stringByAppendingPathComponent:imageName];
    NSError *error = nil;
    // save to disk
    [imageData writeToFile:path options:NSDataWritingAtomic error:&error];
    
    NSDictionary *obj = [NSDictionary dictionaryWithObjectsAndKeys:imageName,@"filename",path,@"path", nil];
    
    return obj;
}
- (NSDictionary *)createImageDataFromPickerPicture:(UIImage *)picture {

    NSData *imageData = UIImagePNGRepresentation(picture);
    
    NSString *imageName = [NSString stringWithFormat:@"%@-.png",[NSDate date]];

    NSDictionary *obj = [NSDictionary dictionaryWithObjectsAndKeys:imageName,@"filename",imageData,@"image", nil];
    
    return obj;
}

@end

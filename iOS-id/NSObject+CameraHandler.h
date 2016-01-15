//
//  NSObject+CameraHandler.h
//  iOS-id
//
//  Created by stephen on 10/20/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (CameraHandler)

- (UIImagePickerController *)createPicturePicker:(id)parent;
- (UIImagePickerController *)createLibraryPicker:(id)parent;
- (NSDictionary *)savePickerPictureToDisk:(UIImage *)picture;
- (NSDictionary *)createImageDataFromPickerPicture:(UIImage *)picture;

@end

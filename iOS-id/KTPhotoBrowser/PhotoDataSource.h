//
//  SDWebImageDataSource.h
//  Sample
//
//  Created by Kirby Turner on 3/18/10.
//  Copyright 2010 White Peak Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KTPhotoBrowserDataSource.h"
#import "Photos.h"
#import "AppDelegate.h"

@interface PhotoDataSource : NSObject <KTPhotoBrowserDataSource> {
    NSArray *images_;
    NSMutableArray *m_photoArray;
}
- (id) initWithPhotoArray: (NSMutableArray *)photoArray;
- (NSInteger)numberOfPhotos;
- (UIImage *)imageWithURLString:(NSString *)string;
- (UIImage *)imageAtIndex:(NSInteger)index;
- (void) deleteImageAtIndex:(NSInteger)index;
@end

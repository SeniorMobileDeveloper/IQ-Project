//
//  PictureAlbumView.m
//  iOS-id
//
//  Created by stephen on 10/21/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import "PictureAlbumView.h"
#import "NSObject+CameraHandler.h"
//#import "NSObject+DataCoreHandler.h"
#import "AppDelegate.h"

@interface PictureAlbumView ()

// data core properties
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContent;
@property (nonatomic, strong) NSMutableArray *a_ns_tableData;
@property (nonatomic, strong) NSMutableDictionary *a_ns_photosByDate;
@property (nonatomic, strong) NSMutableArray *a_ns_date;

@end

@implementation PictureAlbumView

@synthesize delegate;
@synthesize selectedTask;
@synthesize selectedProject;
@synthesize selectedNote;
@synthesize selectedImageCell;

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
    
    // Setting the flow layout but it isn't actually engaging. However, the
    // collection view now displays thumbnails properly. Leaving this code
    // but not sure what is actually overriding the default collection that
    // is setting the correct alignment
    //PictureAlbumLayout *myLayout = [[PictureAlbumLayout alloc]init];
    [_projectImageCollectionView setCollectionViewLayout:_photoAlbumLayout];
    
    // database;
    // make instance and reference content object
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContent = appDelegate.managedObjectContent;
    
    _mainView.layer.cornerRadius = 10;
    
    [self loadData];
    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout*)_projectImageCollectionView.collectionViewLayout;
    collectionViewLayout.sectionInset = UIEdgeInsetsMake(20, 0, 20, 0);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadData {
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    
    // get records; load into array
    _a_ns_tableData = [appDelegate getPhotosByNote:selectedNote];
    if([_a_ns_tableData count] == 0) return;
    
    _a_ns_photosByDate = [[NSMutableDictionary alloc] init];
    _a_ns_date = [[NSMutableArray alloc] init];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM dd, yyyy"];
    
    for(int i=0; i<[_a_ns_tableData count]; i++)
    {
        Photos *photo = [_a_ns_tableData objectAtIndex:i];
        NSDate *photo_date_created = photo.photo_date_created;
        NSString *date_str = [dateFormatter stringFromDate:photo_date_created];
        if([_a_ns_photosByDate objectForKey:date_str] == nil)
        {
            NSMutableArray *newDateGroup = [[NSMutableArray alloc] init];
            [newDateGroup addObject:photo];
            [_a_ns_photosByDate setObject:newDateGroup forKey:date_str];
            [_a_ns_date addObject:date_str];
        }
        else
        {
            [((NSMutableArray *)[_a_ns_photosByDate objectForKey:date_str]) addObject:photo];
        }
    }
    
    // apply data to collection
    [_projectImageCollectionView reloadData];
    
}
- (IBAction)doneButtonTouch:(id)sender {
    
    // is new data saved?
    //
    // IF NOT confirm cancel
    //
    
    // call delegated method to dismiss. This goes to the
    // parent method where it is defined
    [delegate dismissPopover:YES update:YES];
    
}
- (IBAction)deleteItemButtonTouch:(id)sender {
    
    if (selectedImageCell!=nil) {
    
        NSManagedObjectContext *context = [self managedObjectContent];

        // delete object from database
        [context deleteObject:[_a_ns_tableData objectAtIndex:selectedImageCell.row]];
        
        NSError *error = nil;
        if(![context save:&error]) {
            NSLog(@"Error, can't delete %@ %@",error,[error localizedDescription]);
            return;
        }
        
        // remove from table view
        [_a_ns_tableData removeObjectAtIndex:selectedImageCell.row];
        [_projectImageCollectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:selectedImageCell]];

    }
}


/////////////////////////////////////////////////
//
// Methods defined for Collection View protocol
//
//

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [_a_ns_date count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[_a_ns_photosByDate objectForKey:[_a_ns_date objectAtIndex:section]] count];
    //return [_a_ns_tableData count];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"CollectionCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    // 1099 - 3rd party edit
    
    // reference image view from storyboard
    UIImageView *recipeImageView = (UIImageView *)[cell viewWithTag:100];
    NSString *group_date_str = [_a_ns_date objectAtIndex:indexPath.section];
    Photos *item = [((NSMutableArray *)[_a_ns_photosByDate objectForKey:group_date_str]) objectAtIndex:indexPath.row];
    //Photos *item = [_a_ns_tableData objectAtIndex:indexPath.row];
    NSDate *date = item.photo_date_created;
    //recipeImageView.image = [UIImage imageWithContentsOfFile: [item valueForKey:@"photo_path"]];

    recipeImageView.image = [[UIImage alloc] initWithData:[item valueForKey:@"photo_image"]];

    cell.backgroundColor = [UIColor lightGrayColor];
    
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // remember
    selectedImageCell = indexPath;
    
    // 1099 - 3rd party edit
    
    // highlight
    UICollectionViewCell *datasetCell = [collectionView cellForItemAtIndexPath:indexPath];
    datasetCell.backgroundColor = [UIColor yellowColor];
    PhotoDataSource *dataSource_ = [[PhotoDataSource alloc] initWithPhotoArray:_a_ns_tableData];
    KTPhotoScrollViewController *newController = [[KTPhotoScrollViewController alloc]
                                                  initWithDataSource:dataSource_
                                                  andStartWithPhotoAtIndex:indexPath.row];
    
    [[self navigationController] pushViewController:newController animated:YES];
    // apply selection to preview
    //_selectedImageView.image = [UIImage imageNamed:[_a_ns_tableData objectAtIndex:indexPath.row]];
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // remove highlight
    UICollectionViewCell *datasetCell = [collectionView cellForItemAtIndexPath:indexPath];
    datasetCell.backgroundColor = [UIColor grayColor];
    
}

// 1099 - 3rd party addition

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    NSAssert([kind isEqualToString:UICollectionElementKindSectionHeader], @"Unexpected supplementary element kind");
    UICollectionReusableView* cell = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                        withReuseIdentifier:@"PhotoSectionHeader"
                                                                               forIndexPath:indexPath];
    PhotoCollectionHeaderView *headerCell = (PhotoCollectionHeaderView*)cell;
    //NSAssert([cell isKindOfClass:[ImageCollectionViewHeaderCell class]], @"Unexpected class for header cell");
    
    //ImageCollectionViewHeaderCell* header_view = (ImageCollectionViewHeaderCell*) cell;
    [headerCell.lbl_date setText:[_a_ns_date objectAtIndex:indexPath.section]];
    
    // custom content
    
    return headerCell;
}

/*
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    
    if ([NSStringFromSelector(action) isEqualToString:@"cut:"]) {
        return YES;
    }
    
    return NO;
}
- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    
    //
}
*/

//
// Camera operation
//

- (IBAction)openCameraApp:(id)sender {
    
    // create picture control
    UIImagePickerController *picker = [self createPicturePicker:self];
    
    // execute
    [self presentViewController:picker animated:YES completion:NULL];
    
}
- (IBAction)selectImageFromCamera:(id)sender {
    
    // create library control
    UIImagePickerController *picker = [self createLibraryPicker:self];
    
    // execute
    [self presentViewController:picker animated:YES completion:NULL];
    
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *selectedPicture = info[UIImagePickerControllerEditedImage];
    
    // our note was selected by parent before view was loaded
    
    // save image to camera roll
    //UIImageWriteToSavedPhotosAlbum(selectedPicture, self, nil, nil);
    
    // Store image to disk.
    //NSDictionary *imageData = [self savePickerPictureToDisk:selectedPicture];
    NSDictionary *imageData = [self createImageDataFromPickerPicture:selectedPicture];
    NSError *error = nil;
    
    // save to database
    Photos *newEntry = [NSEntityDescription insertNewObjectForEntityForName:@"Photos" inManagedObjectContext:self.managedObjectContent];
    
    // insert
    newEntry.photo_name = [imageData objectForKey:@"filename"];
    newEntry.photo_path = @""; // [imageData objectForKey:@"path"]; // path;
    newEntry.photo_date_created = [NSDate date];
    newEntry.photo_image = [imageData objectForKey:@"image"];
    
    // create relationship with parent table (assume parent object was set by parent)
    newEntry.note = selectedNote;
    
    // error trap
    error = nil;
    if (![self.managedObjectContent save:&error]) {
        NSLog(@"Error, could not save %@ to local device",[error localizedDescription]);
    }
    
    // reload data
    [self loadData];
    
    // close camera
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


//
//
// end Camera operation
//
//

@end

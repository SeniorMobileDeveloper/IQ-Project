//
//  CollapsableTableViewFooterViewController.m
//  CollapsableTableView
//
//  Created by Bernhard Häussermann on 2012/12/15.
//
//

#import "CollapsableTableViewFooterViewController.h"


@implementation CollapsableTableViewFooterViewController

@synthesize titleLabel;

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


- (NSString*) titleText
{
    return titleLabel.text;
}

- (void) setTitleText:(NSString*) titleText
{
    titleLabel.text = titleText;
    
    CGFloat heightDiff = self.view.frame.size.height - titleLabel.frame.size.height;
    //CGFloat labelHeight = [titleText sizeWithFont:titleLabel.font constrainedToSize:CGSizeMake(titleLabel.frame.size.width,titleLabel.numberOfLines==0 ? MAXFLOAT : titleLabel.font.lineHeight * titleLabel.numberOfLines) lineBreakMode:UILineBreakModeWordWrap].height;
    
    // 1099 -- replaces labelHeight above
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    
    NSDictionary * attributes = @{NSFontAttributeName:titleLabel.font,NSParagraphStyleAttributeName:paragraphStyle};

    CGSize size = CGSizeMake(titleLabel.frame.size.width, titleLabel.numberOfLines==0?MAXFLOAT:titleLabel.font.lineHeight*titleLabel.numberOfLines);
    CGFloat labelHeight = [titleText boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size.height;
    // end 1099
    
    
    CGRect frame = titleLabel.frame;
    frame.size.height = labelHeight;
    titleLabel.frame = frame;
    frame = self.view.frame;
    frame.size.height = labelHeight + heightDiff;
    self.view.frame = frame;
}

@end

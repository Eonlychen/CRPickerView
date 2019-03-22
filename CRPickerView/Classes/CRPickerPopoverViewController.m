//
//  CRPickerPopoverViewController.m
//  CRPickerView
//
//  Created by guxiangyun on 2019/3/21.
//

#import "CRPickerPopoverViewController.h"
#import "CRPicker.h"

@interface CRPickerPopoverViewController ()

/** picker  weak防止循环引用*/
@property (nonatomic, weak) CRPicker  *crPicker;

@end

@implementation CRPickerPopoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.crPicker sizeViews];
    [self.crPicker addAllSubviews];
    [self.view addSubview:self.crPicker];
    self.preferredContentSize = [self.crPicker popOverContentSize];
}


- (instancetype)initWithCRPicker:(CRPicker *)picker
{
    self = [super init];
    if (self) {
        self.crPicker = picker;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    return self;
}

@end

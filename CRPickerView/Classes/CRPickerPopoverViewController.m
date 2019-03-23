//
//  CRPickerPopoverViewController.m
//  CRPickerView
//
//  Created by guxiangyun on 2019/3/21.
//

#import "CRPickerPopoverViewController.h"
#import "CRPicker.h"

@interface CRPickerPopoverViewController ()

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

@end

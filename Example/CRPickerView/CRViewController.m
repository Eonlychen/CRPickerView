//
//  CRViewController.m
//  CRPickerView
//
//  Created by eonly_chen@163.com on 03/21/2019.
//  Copyright (c) 2019 eonly_chen@163.com. All rights reserved.
//

#import "CRViewController.h"
#import <CRPickerView/CRPickerView.h>

@interface CRViewController ()
/**  */
@property (nonatomic, strong) UILabel *label;
/**  */
@property (nonatomic, strong) NSArray <NSArray<NSString *>*>*data;
@end

@implementation CRViewController
- (void)loadView {
    [super loadView];
    [self loadSubViews];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.data = @[@[@"Kevin",@"Lauren",@"Kibby",@"Stella"]];
    
    
}

- (void)defaultPopover:(UIBarButtonItem *)sender {
    [CRPicker showAsPopover:self.data fromViewController:self sourceView:nil sourceRect:CGRectZero barButtonItem:sender doneHandler:^(NSDictionary<NSNumber *,NSString *> * _Nonnull selections) {
        NSString *name = selections[@(0)];
        if (name) {
            self.label.text = name;
        }
    }];

}
- (void)defaultPicker {
    [CRPicker showWithData:self.data doneHandler:^(NSDictionary<NSNumber *,NSString *> * _Nonnull selections) {
        if (selections[@(0)]) {
            self.label.text = selections[@(0)];
        }
    } cancelHandler:^{
        NSLog(@"Canceled Default Picker");
    } selectionChangedHandler:^(NSDictionary<NSNumber *,NSString *> * _Nonnull selections, NSInteger componentThatChanged) {
        NSString *newSelection = selections[@(componentThatChanged)];
        if (!newSelection) {
            newSelection = @"Failed to get new selection";
        }
        NSLog(@"Component \(%@) changed value to \(%@)",@(componentThatChanged),newSelection);
    }];
}
- (void)stylePicker:(id)sender {
    NSArray * data = @[@[@"Sir", @"Mr", @"Mrs", @"Miss"],@[@"Kevin", @"Lauren", @"Kibby", @"Stella"]];
    CRPicker *picker = [[CRPicker alloc] initWithDataSource:data];
    UILabel *customLabel = UILabel.new;
    customLabel.textColor = UIColor.whiteColor;
    customLabel.textAlignment = NSTextAlignmentCenter;
    customLabel.font = [UIFont fontWithName:@"American Typewriter" size:30];
    picker.label = customLabel;

    CRPickerBarButtonItem * fixedSpace = [CRPickerBarButtonItem fixedSpaceWithWidth:20];
    CRPickerBarButtonItem * flexibleSpace = [CRPickerBarButtonItem flexibleSpace];
    CRPickerBarButtonItem * doneButton = [CRPickerBarButtonItem doneWithPicker:picker title:@"确定"];
    CRPickerBarButtonItem * cancelButton = [CRPickerBarButtonItem cancelWithPicker:picker title:@"取消"];
    [picker setToolbarItems:@[fixedSpace,cancelButton,flexibleSpace,doneButton,fixedSpace]];
    [picker setToolbarItemsFont:[UIFont fontWithName:@"American Typewriter" size:17] ];
//    [picker setToolbarButtonsColor:UIColor.redColor];
    [picker setToolbarBarTintColor:UIColor.darkGrayColor];
    [picker setPickerBackgroundColor:UIColor.grayColor];
    picker.backgroundColor = UIColor.grayColor;
    picker.backgroundColorAlpha = 0.50;
    [picker setPickerSelectRowsForComponents: @{@(0):@{@(3):@(1)},@(1):@{@(2):@(1)}}.mutableCopy];
    __weak typeof(self)weakSelf = self;
    if ([sender isKindOfClass:UIBarButtonItem.class]) {

        [picker showAsPopover:self sourceView:nil sourceRect:CGRectZero barButtonItem:sender doneHandler:^(NSDictionary<NSNumber *,NSString *> * _Nonnull selections) {
            __weak typeof(weakSelf)strongSelf = weakSelf;
            NSString *prefix = selections[@(0)];
            NSString *name = selections[@(1)];
            strongSelf.label.text = [NSString stringWithFormat:@"%@ %@",prefix,name];
        }];
    }else {
        [picker show:^(NSDictionary<NSNumber *,NSString *> * _Nonnull selections) {
            __weak typeof(weakSelf)strongSelf = weakSelf;

            NSString *prefix = selections[@(0)];
            NSString *name = selections[@(1)];
            strongSelf.label.text = [NSString stringWithFormat:@"%@ %@",prefix,name];
        } cancelHandler:^{
            NSLog(@"Canceled Styled Picker");
        } selectionChangedHandler:^(NSDictionary<NSNumber *,NSString *> * _Nonnull selections, NSInteger componentThatChanged) {
            NSString *newSelection = selections[@(componentThatChanged)] ?: @"Failed to get new selection!";
            NSLog(@"Component %@ changed value to %@",@(componentThatChanged),newSelection);
        }];
    }


}
- (void)popOverPicker:(UIButton *)sender {
    __weak typeof(self)weakSelf = self;
    
    [CRPicker showAsPopover:self.data fromViewController:self sourceView:sender sourceRect:CGRectZero barButtonItem:nil doneHandler:^(NSDictionary<NSNumber *,NSString *> * _Nonnull selections) {
        __weak typeof(weakSelf)strongSelf = weakSelf;

        NSString *name = selections[@(0)];
        strongSelf.label.text = [NSString stringWithFormat:@"%@",name];
    } cancelHandler:^{
        NSLog(@"Canceled Popover");
    } selectionChangedHandler:^(NSDictionary<NSNumber *,NSString *> * _Nonnull selections, NSInteger componentThatChanged) {
        NSString *newSelection = selections[@(componentThatChanged)]?:@"Failed to get new selection!";
        NSLog(@"Component %@ changed value to %@",@(componentThatChanged),newSelection);
    }];
}



- (UIButton *)buttonWithFrame:(CGRect)frame
                        title:(NSString *)title
                          sel:(SEL)sel
{
    UIButton *btn = UIButton.new;
    btn.frame = frame;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
    [btn setTitleColor:UIColor.grayColor forState:UIControlStateSelected];
    [btn addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    return btn;
}
- (void)loadSubViews {
    self.navigationItem.title = @"CRPicker";
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem.alloc initWithTitle:@"stylePopover" style:UIBarButtonItemStylePlain target:self action:@selector(stylePicker:)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem.alloc initWithTitle:@"defaultPopover" style:UIBarButtonItemStylePlain target:self action:@selector(defaultPopover:)];
    
    CGFloat x = 20,y = 20,w = self.view.frame.size.width - 40, h = 30;
    UIButton *defaultPicker = [self buttonWithFrame:CGRectMake(x,100 +y, w, h) title:@"defaultPicker" sel:@selector(defaultPicker)];
    
    UIButton *styledPicker = [self buttonWithFrame:CGRectMake(x, CGRectGetMaxY(defaultPicker.frame)+h, w, h) title:@"styledPicker" sel:@selector(stylePicker:)];
    
    UIButton *popOverPicker = [self buttonWithFrame:CGRectMake(x, CGRectGetMaxY(styledPicker.frame)+h,w, h) title: @"popOverPicker" sel:@selector(popOverPicker:)];
    
    [self.view addSubview:defaultPicker];
    [self.view addSubview:styledPicker];
    [self.view addSubview:popOverPicker];
    
    self.label = [UILabel.alloc initWithFrame:CGRectMake(x, CGRectGetMaxY(popOverPicker.frame)+y, w, h)];
    self.label.text = @"xxxxxxxxx";
    self.label.textColor = UIColor.redColor;
    self.label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.label];
}
@end

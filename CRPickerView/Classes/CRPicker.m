//
//  CRPicker.m
//  CRPickerView
//
//  Created by guxiangyun on 2019/3/21.
//

#import "CRPicker.h"
#import "CRPickerPopoverViewController.h"
#import "CRPickerBarButtonItem.h"

typedef struct {
    CGFloat backgroundColorAlpha;
    CGFloat pickerHeight;
    CGFloat toolBarHeight;
    NSTimeInterval animationSpeed;
    CGFloat barButtonFixedSpacePadding;
}Constant;

typedef NS_ENUM(NSInteger, AnimationDirection) {
    AnimationDirectionIn,
    AnimationDirectionOut
};

@interface CRPicker ()<UIGestureRecognizerDelegate,
UIPopoverPresentationControllerDelegate,
UIPickerViewDataSource,UIPickerViewDelegate,
UIGestureRecognizerDelegate,
UITextFieldDelegate>

{
    Constant constant;
}

/** done */
@property (nonatomic, copy, readwrite) DoneHandler doneHandler;
/** cancel */
@property (nonatomic, copy, readwrite) CancelHandler cancelHandler;
/** selection */
@property (nonatomic, copy, readwrite) SelectionChangedHandler selectionChangedHandler;

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSString *> *pickerSelection;
@property (nonatomic, strong) NSArray<NSArray <NSString *>*> *pickerData;

@property (nonatomic, strong) UIPickerView *picker;

@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, strong) UIToolbar *toolbar;
/** 弹出模式    默认为false */
@property (nonatomic, assign) BOOL isPopoverMode;

@property (nonatomic, strong, readonly) UIWindow *appWindow;

@property (nonatomic, strong) CRPickerPopoverViewController *crPickerPopoverViewController;


@end

@implementation CRPicker
@synthesize pickerSelectRowsForComponents = _pickerSelectRowsForComponents;

// MARK: Show
+ (void)showWithData:(NSArray <NSArray<NSString *>*>*)data
               doneHandler:(DoneHandler)doneHandler
             cancelHandler:(CancelHandler)cancelHandler
   selectionChangedHandler:(SelectionChangedHandler)selectionChangedHandler {
    CRPicker *picker = [[CRPicker alloc] initWithDataSource:data];
    [picker show:doneHandler cancelHandler:cancelHandler selectionChangedHandler:selectionChangedHandler];
}
+ (void)showWithData:(NSArray<NSArray<NSString *> *> *)data doneHandler:(DoneHandler)doneHandler {
    CRPicker *picker = [[CRPicker alloc] initWithDataSource:data];
    [picker show:doneHandler];
}
- (void)show:(DoneHandler)doneHandler {
    [self show:doneHandler cancelHandler:nil selectionChangedHandler:nil];
}
- (void)show:(DoneHandler)doneHandler cancelHandler:(CancelHandler)cancelHandler selectionChangedHandler:(SelectionChangedHandler)selectionChangedHandler {
    self.doneHandler = doneHandler;
    self.cancelHandler = cancelHandler;
    self.selectionChangedHandler = selectionChangedHandler;
    [self animateViews:AnimationDirectionIn];
}

// MARK: Show As Popover
+ (void)showAsPopover:(NSArray <NSArray<NSString *>*>*)data
   fromViewController:(UIViewController *)fromViewController
           sourceView:(UIView *)sourceView
           sourceRect:(CGRect)sourceRect
        barButtonItem:(UIBarButtonItem *)barButtonItem
          doneHandler:(DoneHandler)doneHandler
        cancelHandler:(CancelHandler)cancelHandler
selectionChangedHandler:(SelectionChangedHandler)selectionChangedHandler {
    CRPicker *picker = [[CRPicker alloc] initWithDataSource:data];
    [picker showAsPopover:fromViewController sourceView:sourceView sourceRect:sourceRect barButtonItem:barButtonItem doneHandler:doneHandler cancelHandler:cancelHandler selectionChangedHandler:selectionChangedHandler];
}
+ (void)showAsPopover:(NSArray <NSArray<NSString *>*>*)data
   fromViewController:(UIViewController *)fromViewController
           sourceView:(nullable UIView *)sourceView
           sourceRect:(CGRect)sourceRect
        barButtonItem:(UIBarButtonItem *)barButtonItem
          doneHandler:(DoneHandler)doneHandler {
    CRPicker *picker = [[CRPicker alloc] initWithDataSource:data];
    [picker showAsPopover:fromViewController sourceView:sourceView sourceRect:sourceRect barButtonItem:barButtonItem doneHandler:doneHandler cancelHandler:nil selectionChangedHandler:nil];
}
- (void)showAsPopover:(UIViewController *)fromViewController
           sourceView:(nullable UIView *)sourceView
           sourceRect:(CGRect)sourceRect
        barButtonItem:(UIBarButtonItem *)barButtonItem
          doneHandler:(DoneHandler)doneHandler {
    [self showAsPopover:fromViewController sourceView:sourceView sourceRect:sourceRect barButtonItem:barButtonItem doneHandler:doneHandler cancelHandler:nil selectionChangedHandler:nil];
}
- (void)showAsPopover:(UIViewController *)fromViewController
           sourceView:(nullable UIView *)sourceView
           sourceRect:(CGRect)sourceRect
        barButtonItem:(UIBarButtonItem *)barButtonItem
          doneHandler:(DoneHandler)doneHandler
        cancelHandler:(CancelHandler)cancelHandler
selectionChangedHandler:(SelectionChangedHandler)selectionChangedHandler {
    if (sourceView == nil && barButtonItem == nil) {
        NSLog(@"%@",@"You must set at least 'sourceView' or 'barButtonItem'");
        return;
    }
    self.isPopoverMode = true;
    self.doneHandler = doneHandler;
    self.cancelHandler = cancelHandler;
    self.selectionChangedHandler = selectionChangedHandler;
    self.crPickerPopoverViewController = [[CRPickerPopoverViewController alloc] initWithCRPicker:self];
    self.crPickerPopoverViewController.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController * popover = self.crPickerPopoverViewController.popoverPresentationController;
    popover.delegate = self;
    if (sourceView) {
        popover.sourceView = sourceView;
        popover.sourceRect = CGRectEqualToRect(sourceRect, CGRectZero) ? sourceView.bounds:CGRectZero;
    }else {
        popover.barButtonItem = barButtonItem;
    }

    [fromViewController presentViewController:self.crPickerPopoverViewController animated:true completion:nil];
}


- (instancetype)initWithDataSource:(NSArray <NSArray<NSString *> *>*)data {
    if (self = [super initWithFrame:CGRectZero]) {
        self.pickerData = [NSArray arrayWithArray:data];
        [self initializeConstant];
        [self initializeisPopoverMode];
        [self setup];
    }
    return self;
}
//- (instancetype)initWithCoder:(NSCoder *)aDecoder {
//    self = [super initWithCoder:aDecoder];
//    return self;
//}
//- (instancetype)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    return self;
//}


#pragma mark -- public
- (void)sizeViews {
    CGSize size = self.isPopoverMode ? [self popOverContentSize] : self.appWindow.bounds.size;
    self.frame = CGRectMake(0, 0, size.width, size.height);
    CGFloat backgroundViewY = self.isPopoverMode ? 0 : self.bounds.size.height-(constant.pickerHeight+constant.toolBarHeight);
    self.backgroundView.frame = CGRectMake(0, backgroundViewY, self.bounds.size.width, constant.pickerHeight+constant.toolBarHeight);
    self.toolbar.frame = CGRectMake(0, 0, self.backgroundView.bounds.size.width, constant.toolBarHeight);
    self.picker.frame = CGRectMake(0, self.toolbar.bounds.size.height, self.backgroundView.bounds.size.width, constant.pickerHeight);
}
- (void)addAllSubviews {
    [self.backgroundView addSubview:self.picker];
    [self.backgroundView addSubview:self.toolbar];
    [self addSubview:self.backgroundView];
}
- (CGSize)popOverContentSize {
    return CGSizeMake(constant.pickerHeight + constant.toolBarHeight, constant.pickerHeight + constant.toolBarHeight);
}
- (void)doneAction {
    if (self.doneHandler) {
        self.doneHandler(self.pickerSelection);
    }
    [self dismissViews];
}
- (void)cancelAction {
    if (self.cancelHandler) {
        self.cancelHandler();
    }
    [self dismissViews];
}

#pragma mark -- overwrite
- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    if (newWindow == nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sizeViews) name:UIDeviceOrientationDidChangeNotification object:nil];
    }else {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    }
}

#pragma mark -- private

- (void)setup {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelAction)];
    [self addGestureRecognizer:tapGestureRecognizer];

    CRPickerBarButtonItem *fixedSpaceItem = [CRPickerBarButtonItem fixedSpaceWithWidth:self.appWindow.bounds.size.width*constant.barButtonFixedSpacePadding];
    CRPickerBarButtonItem *cancelItem = [CRPickerBarButtonItem cancelWithPicker:self title:@"取消"];
    CRPickerBarButtonItem *flexibleSpaceItem = [CRPickerBarButtonItem flexibleSpace];
    CRPickerBarButtonItem *doneItem = [CRPickerBarButtonItem doneWithPicker:self title:@"确定"];
    [self setToolbarItems:@[fixedSpaceItem,cancelItem,flexibleSpaceItem,doneItem,fixedSpaceItem]];
    self.backgroundView.backgroundColor = UIColor.whiteColor;
    [self sizeViews];
    NSInteger index = 0;
    for (NSArray<NSString *>*element in self.pickerData.objectEnumerator) {
        self.pickerSelection[@(index)] = element.firstObject;
        index++;
    }

}
- (CGFloat)_backgroundColorAlpha {
    return self.backgroundColorAlpha ?: constant.backgroundColorAlpha;
}
- (NSInteger)numberOfComponents {
    return self.pickerData.count;
}

- (void)dismissViews {
    if (self.isPopoverMode) {
        [self.crPickerPopoverViewController dismissViewControllerAnimated:true completion:nil];
        self.crPickerPopoverViewController = nil;// Release, as to not create a retain cycle.
    }else {
        [self animateViews:AnimationDirectionOut];
    }

}
- (void)animateViews:(AnimationDirection)direction {
    __block CGRect backgroundFrame = self.backgroundView.frame;
    UIColor *animateColor = self.backgroundColor ?: UIColor.blackColor;
    if (direction == AnimationDirectionIn) {
        self.backgroundColor = [animateColor colorWithAlphaComponent:0];
        backgroundFrame.origin.y = self.appWindow.bounds.size.height;
        self.backgroundView.frame = backgroundFrame;
        [self addAllSubviews];
        [self.appWindow addSubview:self];

        [UIView animateWithDuration:constant.animationSpeed animations:^{
            self.backgroundColor = [animateColor colorWithAlphaComponent:[self _backgroundColorAlpha]];
            CGFloat originY = self.appWindow.bounds.size.height - self.backgroundView.bounds.size.height;
            backgroundFrame = CGRectMake(backgroundFrame.origin.x, originY, backgroundFrame.size.width, backgroundFrame.size.height);
            self.backgroundView.frame = backgroundFrame;
        }];
    }else {
        [UIView animateWithDuration:constant.animationSpeed animations:^{
            self.backgroundColor = [animateColor colorWithAlphaComponent:0];
            CGFloat originY = self.appWindow.bounds.size.height;
            backgroundFrame = CGRectMake(backgroundFrame.origin.x, originY, backgroundFrame.size.width, backgroundFrame.size.height);
            self.backgroundView.frame = backgroundFrame;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
}

/**
  初始化配置
 */
- (void)initializeConstant {
    constant.backgroundColorAlpha = 0.75;
    constant.pickerHeight = 216.0;
    constant.toolBarHeight = 44.0;
    constant.animationSpeed = 0.25;
    constant.barButtonFixedSpacePadding = 0.02;
}
- (void)initializeisPopoverMode {
    self.isPopoverMode = false;
}

- (void)applyToolbarButtonItemsSettingsWithActions:(SEL)actions
                                     settings:(void(^)(UIBarButtonItem *barButtonItem))settings{
    for (UIBarButtonItem *item in _toolbar.items) {
        if (actions != nil && item.action == actions) {
            settings(item);
        }
        if (actions == nil) {
            settings(item);
        }
    }
}
#pragma mark -- setter
    
- (void)setToolbarItems:(NSArray<CRPickerBarButtonItem *>*)items {
    
    self.toolbar.items = items;
    [self setToolbarProperties];
}

- (void)setToolbarProperties {


}
- (void)setToolbarButtonsColor:(UIColor *)toolbarButtonsColor {
    [self applyToolbarButtonItemsSettingsWithActions:nil settings:^(UIBarButtonItem *barButtonItem) {
        barButtonItem.tintColor = toolbarButtonsColor;
    }];
}
- (void)setToolbarDoneButtonColor:(UIColor *)toolbarDoneButtonColor {
    [self applyToolbarButtonItemsSettingsWithActions:@selector(doneAction) settings:^(UIBarButtonItem *barButtonItem) {
        barButtonItem.tintColor = toolbarDoneButtonColor;
    }];
}
- (void)setToolbarCancelButtonColor:(UIColor *)toolbarCancelButtonColor {
    [self applyToolbarButtonItemsSettingsWithActions:@selector(cancelAction) settings:^(UIBarButtonItem *barButtonItem) {
        barButtonItem.tintColor = toolbarCancelButtonColor;
    }];
}
- (void)setToolbarItemsFont:(UIFont *)toolbarItemsFont {
    [self applyToolbarButtonItemsSettingsWithActions:nil settings:^(UIBarButtonItem *barButtonItem) {
        [barButtonItem setTitleTextAttributes:@{NSFontAttributeName:toolbarItemsFont} forState:UIControlStateNormal];
        [barButtonItem setTitleTextAttributes:@{NSFontAttributeName:toolbarItemsFont} forState:UIControlStateSelected];
    }];
}
- (void)setToolbarBarTintColor:(UIColor *)toolbarBarTintColor {
    self.toolbar.barTintColor = toolbarBarTintColor;
}
- (void)setPickerBackgroundColor:(UIColor *)pickerBackgroundColor {
    self.picker.backgroundColor = pickerBackgroundColor;
}
- (void)setPickerSelectRowsForComponents:(NSMutableDictionary<NSNumber *,NSDictionary<NSNumber *,NSNumber *> *> *)pickerSelectRowsForComponents {
    for (NSNumber *component in pickerSelectRowsForComponents.allKeys) {
        int row = pickerSelectRowsForComponents[component].allKeys.firstObject.intValue;
        BOOL isAnimated= pickerSelectRowsForComponents[component].allValues.firstObject.boolValue;
        self.pickerSelection[component] = self.pickerData[component.intValue][row];
        [self.picker selectRow:row inComponent:component.integerValue animated:isAnimated];
    }
}
- (void)setShowsSelectionIndicator:(BOOL)showsSelectionIndicator {
    self.picker.showsSelectionIndicator = showsSelectionIndicator;
}

#pragma mark -- getter

- (NSMutableDictionary<NSNumber *,NSString *> *)pickerSelection {
    if (!_pickerSelection) {
        _pickerSelection = [NSMutableDictionary dictionary];
    }
    return _pickerSelection;
}
- (UIPickerView *)picker {
    if (!_picker) {
        _picker = [UIPickerView.alloc init];
        _picker.dataSource = self;
        _picker.delegate = self;
    }
    return _picker;
}
- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = UIView.new;
    }
    return _backgroundView;
}
- (UIToolbar *)toolbar {
    if (!_toolbar) {
        _toolbar = UIToolbar.new;
    }
    return _toolbar;
}

- (NSMutableDictionary<NSNumber *,NSDictionary<NSNumber *,NSNumber *> *> *)pickerSelectRowsForComponents {
    if (!_pickerSelectRowsForComponents) {
        _pickerSelectRowsForComponents = [NSMutableDictionary dictionary];
    }
    return _pickerSelectRowsForComponents;
}

- (UIWindow *)appWindow {
    return UIApplication.sharedApplication.keyWindow;
}

#pragma mark -- UIPickerViewDataSource,UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView; {
    return self.numberOfComponents;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component; {
    return self.pickerData[component].count;
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *pickerLabel = (UILabel *)view;
    if (pickerLabel == nil) {
        pickerLabel = UILabel.new;
        if (self.label) {
            pickerLabel.textAlignment = self.label.textAlignment;
            pickerLabel.font = self.label.font;
            pickerLabel.textColor = self.label.textColor;
            pickerLabel.backgroundColor = self.label.backgroundColor;
            pickerLabel.numberOfLines = self.label.numberOfLines;
        }else {
            pickerLabel.textAlignment = NSTextAlignmentCenter;
            pickerLabel.font = [UIFont systemFontOfSize:self.fontSize];
        }
    }
    NSString *text = self.pickerData[component][row];
    pickerLabel.text = text;
    return pickerLabel;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.pickerSelection[@(component)] = self.pickerData[component][row];
    if (self.selectionChangedHandler) {
        self.selectionChangedHandler(self.pickerSelection,component);
    }
}
#pragma mark -- UIPopoverPresentationControllerDelegate
- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
    if (self.cancelHandler) {
        self.cancelHandler();
    }
}
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller traitCollection:(UITraitCollection *)traitCollection {
    return UIModalPresentationNone;
}
#pragma mark -- UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (touch.view != nil && touch.view == self) {
        return true;
    }
    return false;
}

//#pragma mark -- UITextFieldDelegate
//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
//    // to do
//
//    return true;
//}

@end

//
//  CRPicker.h
//  CRPickerView
//
//  Created by guxiangyun on 2019/3/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^DoneHandler) (NSDictionary<NSNumber*,NSString *> * selections);
typedef void(^CancelHandler) (void);
typedef void(^SelectionChangedHandler) (NSDictionary<NSNumber *,NSString *> *selections,NSInteger componentThatChanged);


@interface CRPicker : UIView

/** 字体大小 */
@property (nonatomic, assign) CGFloat fontSize;
/** <#属性#> */
@property (nonatomic, assign) CGFloat backgroundColorAlpha;

/** <#属性#> */
@property (nonatomic, strong) UILabel *label;

/** <#属性#> */
@property (nonatomic, strong) UIColor *toolbarButtonsColor;
@property (nonatomic, strong)UIColor *toolbarDoneButtonColor;
@property (nonatomic, strong)UIColor *toolbarCancelButtonColor;
@property (nonatomic, strong)UIFont *toolbarItemsFont;
@property (nonatomic, strong)UIColor *toolbarBarTintColor;
@property (nonatomic, strong)UIColor *pickerBackgroundColor;

/**
 Sets the picker's components row position and picker selections to those String values.
 [Int:[Int:Bool]] equates to [Component: [Row: isAnimated]
 仿swift,存储类型需要变化
 */
@property (nonatomic, strong) NSMutableDictionary<NSNumber *,NSDictionary<NSNumber *,NSNumber *>*> *pickerSelectRowsForComponents;

@property (nonatomic, assign) BOOL showsSelectionIndicator;



// MARK: Show
//
+ (void)showWithData:(NSArray <NSArray<NSString *>*>*)data
               doneHandler:(DoneHandler)doneHandler
             cancelHandler:(CancelHandler)cancelHandler
   selectionChangedHandler:(SelectionChangedHandler)selectionChangedHandler;
+ (void)showWithData:(NSArray<NSArray<NSString *> *> *)data
         doneHandler:(DoneHandler)doneHandler;

// MARK: Show As Popover
//
+ (void)showAsPopover:(NSArray <NSArray<NSString *>*>*)data
   fromViewController:(UIViewController *)fromViewController
           sourceView:(UIView *)sourceView
           sourceRect:(CGRect)sourceRect
        barButtonItem:(UIBarButtonItem *)barButtonItem
          doneHandler:(DoneHandler)doneHandler
        cancelHandler:(CancelHandler)cancelHandler
selectionChangedHandler:(SelectionChangedHandler)selectionChangedHandler;

+ (void)showAsPopover:(NSArray <NSArray<NSString *>*>*)data
   fromViewController:(UIViewController *)fromViewController
           sourceView:(UIView *)sourceView
           sourceRect:(CGRect)sourceRect
        barButtonItem:(UIBarButtonItem *)barButtonItem
          doneHandler:(DoneHandler)doneHandler;

- (CGSize)popOverContentSize;
- (void)sizeViews;
- (void)addAllSubviews;
//- (void)doneAction;
//- (void)cancelAction;
@end

NS_ASSUME_NONNULL_END

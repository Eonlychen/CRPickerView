//
//  CRPickerBarButtonItem.h
//  CRPickerView
//
//  Created by guxiangyun on 2019/3/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class CRPicker;
@interface CRPickerBarButtonItem : UIBarButtonItem

+ (CRPickerBarButtonItem *)doneWithPicker:(CRPicker *)picker
                                    title:(nullable NSString *)title;

+ (CRPickerBarButtonItem *)cancelWithPicker:(CRPicker *)picker
                                      title:(nullable NSString *)title;

+ (CRPickerBarButtonItem *)flexibleSpace;

+ (CRPickerBarButtonItem *)fixedSpaceWithWidth:(CGFloat)width;

@end

NS_ASSUME_NONNULL_END

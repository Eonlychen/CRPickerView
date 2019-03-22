//
//  CRPickerBarButtonItem.m
//  CRPickerView
//
//  Created by guxiangyun on 2019/3/21.
//

#import "CRPickerBarButtonItem.h"
#import "CRPicker.h"

@implementation CRPickerBarButtonItem

+ (CRPickerBarButtonItem *)doneWithPicker:(CRPicker *)picker
                                    title:(nullable NSString *)title {
    if (title) {
        CRPickerBarButtonItem *item = [[CRPickerBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:picker action:@selector(doneAction)];
        return item;
    }
    CRPickerBarButtonItem *item = [[CRPickerBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:picker action:@selector(doneAction)];
    return item;
}
+ (CRPickerBarButtonItem *)cancelWithPicker:(CRPicker *)picker
                                      title:(nullable NSString *)title {
    if (title) {
        CRPickerBarButtonItem *item = [[CRPickerBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:picker action:@selector(cancelAction)];
        return item;
    }
    CRPickerBarButtonItem *item = [[CRPickerBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:picker action:@selector(cancelAction)];
    return item;
}

+ (CRPickerBarButtonItem *)flexibleSpace {
    CRPickerBarButtonItem *item = [[CRPickerBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    return item;
}
+ (CRPickerBarButtonItem *)fixedSpaceWithWidth:(CGFloat)width {
    CRPickerBarButtonItem *item = [[CRPickerBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    item.width = width;
    return item;
}

@end

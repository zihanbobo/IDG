//
//  VRGCalendarView.h
//  Vurig
//
//  Created by in 't Veen Tjeerd on 5/8/12.
//  Copyright (c) 2012 Vurig Media. All rights reserved.
//
//  Modified by cyrusleung on 2014-06-19
//  1.调整了日历样式、汉化等
//  2.增加了农历和节假日显示

#import <UIKit/UIKit.h>
#import "UIColor+expanded.h"

#define kVRGCalendarViewTopBarHeight 70

#define kVRGCalendarViewWidth Screen_Width

#define kVRGCalendarViewDayWidth 44

#define kVRGCalendarViewSignINDayWidth 33

#define kVRGCalendarViewDayHeight 38

@protocol VRGCalendarViewDelegate;

@interface VRGCalendarView : UIView {
    id <VRGCalendarViewDelegate> delegate;

    NSDate *currentMonth;

    UILabel *labelCurrentMonth;

    BOOL isAnimating;
    BOOL prepAnimationPreviousMonth;
    BOOL prepAnimationNextMonth;


    UIImageView *animationView_A;
    UIImageView *animationView_B;

    NSArray *markedDates;
    NSArray *markedColors;
}

@property(nonatomic, assign) id <VRGCalendarViewDelegate> delegate;
@property(nonatomic, retain) NSDate *currentMonth;
@property(nonatomic, retain) UILabel *labelCurrentMonth;
@property(nonatomic, retain) UIImageView *animationView_A;
@property(nonatomic, retain) UIImageView *animationView_B;
@property(nonatomic, retain) NSArray *markedDates;
@property(nonatomic, retain) NSArray *markedColors;
@property(nonatomic, getter = calendarHeight) float calendarHeight;
@property(nonatomic, retain, getter = selectedDate) NSDate *selectedDate;
@property(copy, nonatomic) NSArray *selectedDateArr;
@property(nonatomic, assign) BOOL isFromAttendance;

@property(nonatomic, assign) BOOL isFromCXSignIN;

- (void)selectDate:(int)date;

- (void)reset;

- (void)markDates:(NSArray *)dates;

- (void)markDates:(NSArray *)dates withColors:(NSArray *)colors;

- (void)showNextMonth;

- (void)showPreviousMonth;

- (int)numRows;

- (void)updateSize;

- (UIImage *)drawCurrentState;

/// 选中当前日期
- (void)selectCurrentDate;

- (id)initWithFromCXSignIN:(BOOL)fromCXSignIn;

@end

@protocol VRGCalendarViewDelegate <NSObject>
- (void)calendarView:(VRGCalendarView *)calendarView switchedToMonth:(int)month toYear:(int)year targetHeight:(float)targetHeight animated:(BOOL)animated;

- (void)calendarView:(VRGCalendarView *)calendarView dateSelected:(NSDate *)date lunarDict:(NSMutableDictionary *)dict;
@end
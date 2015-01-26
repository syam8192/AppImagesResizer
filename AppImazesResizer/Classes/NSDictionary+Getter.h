//
//  NSDictionary+Getter.h
//  JKAlarmClock
//
//  Created by B02923 on 13/08/16.
//  Copyright (c) 2013年 N/A. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 連想配列から型指定＆デフォルト値指定して値を取り出す.
 */
@interface NSDictionary (Getter)

- (NSString*)stringForKey:(NSString*)key defaultValue:(NSString*)defaultValue;
- (int)intForKey:(NSString*)key defaultValue:(int)defaultValue;
- (long long)longLongForKey:(NSString*)key defaultValue:(long long)defaultValue;
- (int)boolForKey:(NSString*)key defaultValue:(BOOL)defaultValue;
- (NSDictionary*)dictionaryForKey:(NSString*)key;
- (NSArray*)arrayForKey:(NSString*)key;

@end

/**
 * 配列から型指定して値を取り出す.
 */
@interface NSArray (Getter)

- (NSDictionary*)dictionaryAtIndex:(NSUInteger)index;

- (NSString*)stringAtIndex:(NSUInteger)index defaultValue:(NSString*)defaultValue;

- (id)objectAtIndex:(NSUInteger)index defaultValue:(id)defaultValue;

@end
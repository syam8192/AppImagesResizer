//
//  NSDictionary+Getter.m
//  JKAlarmClock
//
//  Created by B02923 on 13/08/16.
//  Copyright (c) 2013年 N/A. All rights reserved.
//

#import "NSDictionary+Getter.h"

@implementation NSDictionary (Getter)


- (NSString*)stringForKey:(NSString*)key defaultValue:(NSString*)defaultValue {
    NSObject* obj = [self objectForKey:key];
    if (obj) {
        if ([obj isKindOfClass:NSString.class]) {
            return (NSString*)obj;
        }
        if ([obj isKindOfClass:NSNumber.class]) {
            return ((NSNumber*)obj).stringValue;
        }
    }
    return defaultValue;
}

- (int)intForKey:(NSString*)key defaultValue:(int)defaultValue {
    NSObject* obj = [self objectForKey:key];
    if (obj) {
        if ( [obj isKindOfClass:NSNumber.class] ) {
            return ((NSNumber*)obj).intValue;
        }
        if ( [obj isKindOfClass:NSString.class] ) {
            return [((NSString*)obj) intValue];
        }
    }
    return defaultValue;
}

- (long long)longLongForKey:(NSString*)key defaultValue:(long long)defaultValue {
    NSObject* obj = [self objectForKey:key];
    if (obj) {
        if ( [obj isKindOfClass:NSNumber.class] ) {
            return ((NSNumber*)obj).longLongValue;
        }
        if ( [obj isKindOfClass:NSString.class] ) {
            return [((NSString*)obj) longLongValue];
        }
    }
    return defaultValue;
}

- (int)boolForKey:(NSString*)key defaultValue:(BOOL)defaultValue {
    NSObject* obj = [self objectForKey:key];
    if ( obj ) {
        if ( [obj isKindOfClass:NSNumber.class] ) {
            return ((NSNumber*)obj).boolValue;
        }
        if ( [obj isKindOfClass:NSString.class] ) {
            NSString* str = (NSString*)obj;
            if([str compare:@"true" options:NSCaseInsensitiveSearch]==NSOrderedSame)return YES;
            if([str compare:@"false" options:NSCaseInsensitiveSearch]==NSOrderedSame)return NO;
            if([str compare:@"yes" options:NSCaseInsensitiveSearch]==NSOrderedSame)return YES;
            if([str compare:@"no" options:NSCaseInsensitiveSearch]==NSOrderedSame)return NO;
            return [((NSString*)obj) boolValue];
        }
    }
    return defaultValue;
}

- (NSDictionary*)dictionaryForKey:(NSString*)key {
    NSObject* obj = [self objectForKey:key];
    if (obj && [obj isKindOfClass:NSDictionary.class]) {
        return (NSDictionary*)obj;
    }
    return nil;
}

- (NSArray*)arrayForKey:(NSString*)key {
    NSObject* obj = [self objectForKey:key];
    if (obj && [obj isKindOfClass:NSArray.class]) {
        return (NSArray*)obj;
    }
    return nil;
}

@end


@implementation NSArray (Getter)

- (NSDictionary*)dictionaryAtIndex:(NSUInteger)index {
    if (index < self.count) {
        NSObject* obj = [self objectAtIndex:index];
        if ( [obj isKindOfClass:NSDictionary.class] ) {
            return (NSDictionary*)obj;
        }
    }
    return nil;
}

- (NSString*)stringAtIndex:(NSUInteger)index defaultValue:(NSString*)defaultValue {
    if (index < self.count) {
        NSObject* obj = [self objectAtIndex:index];
        if ( [obj isKindOfClass:NSString.class] ) {
            return (NSString*)obj;
        }
    }
    return defaultValue;
}

- (id)objectAtIndex:(NSUInteger)index defaultValue:(id)defaultValue {
    return ( index < self.count ) ? [self objectAtIndex:index] : defaultValue;
}

@end
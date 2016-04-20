//
//  AIMeaning.h
//  Acronym
//
//  Created by Amargoal1 on 4/19/16.
//  Copyright (c) 2016 com.demo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AIMeaning : NSObject
@property (nonatomic, copy) NSString *meaning;
@property NSInteger frequency;
@property NSInteger since;
@property (nonatomic, copy) NSMutableArray *variations;

@end

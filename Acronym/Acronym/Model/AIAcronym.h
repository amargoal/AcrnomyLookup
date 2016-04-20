//
//  AIAcronym.h
//  Acronym
//
//  Created by Amargoal1 on 4/19/16.
//  Copyright (c) 2016 com.demo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AIAcronym : NSObject

@property (nonatomic,copy) NSString *shortForm;
@property (nonatomic,strong) NSMutableArray *meanings;
@end

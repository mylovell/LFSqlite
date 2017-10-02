//
//  ViewController.h
//  SqliteDemo
//
//  Created by Feng Luo on 2017/9/30.
//  Copyright © 2017年 Feng Luo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

// block方法一
@property (nonatomic, strong) BOOL (^exceSql) (NSString *sql);

// block方法二
typedef BOOL (^ExceSqls) (NSArray *sqls);

@end


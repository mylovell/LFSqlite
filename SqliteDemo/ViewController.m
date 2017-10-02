//
//  ViewController.m
//  SqliteDemo
//
//  Created by Feng Luo on 2017/9/30.
//  Copyright © 2017年 Feng Luo. All rights reserved.
//

#import "ViewController.h"
#import <sqlite3.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *age;
@property (weak, nonatomic) IBOutlet UITextField *score;

@end

#define kCachePath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject
sqlite3 *ppDb;
@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 定义属性block
    self.exceSql = ^BOOL(NSString *sql) {
        char *zErrorMsg;
        BOOL result = sqlite3_exec(ppDb, sql.UTF8String, nil, nil, &zErrorMsg) == SQLITE_OK;
        if (!result) {
            NSLog(@"zErrorMsg:%s",zErrorMsg);
            NSLog(@"exce failure : %@",sql);
            return NO;
        }
        return YES;
    };
    
    // 定义block类型
    ExceSqls exceSqls = ^BOOL(NSArray *sqls) {
        for (NSString *sql in sqls) {
            char *zErrorMsg;
            BOOL result = sqlite3_exec(ppDb, sql.UTF8String, nil, nil, &zErrorMsg) == SQLITE_OK;
            if (!result) {
                NSLog(@"zErrorMsg:%s",zErrorMsg);
                NSLog(@"exce failure : %@",sql);
                return NO;
            }
        }
        return YES;
    };
    
    
    [self creatTable];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // /Users/fengluo/Library/Developer/CoreSimulator/Devices/39D77240-6ED8-4FF2-BD81-165260E8C771/data/Containers/Data/Application/494695EA-0B1D-44A3-A4A6-B58CAB03D3FB
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    
}

- (void)creatTable {
    
    // 1、建表，添加字段
    
    
    // 字段加单引号
    NSString *sql = [NSString stringWithFormat:@"create table if not exists 'student' ('number' integer primary key autoincrement not null,'name' text,'sex' text,'age'integer)"];
    // 也可以字段不加单引号
    NSString *sql1 = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS t_student1 (id1 INTEGER, name1 TEXT, age1 INTEGER, score1 REAL, PRIMARY KEY(id1));"];
    // 结尾少了分号也行
    NSString *sql2 = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS t_student2 (id2 INTEGER PRIMARY KEY AUTOINCREMENT, name2 TEXT, age2 INTEGER, score2 REAL)"];
    NSString *sql3 = [NSString stringWithFormat:@"create table if not exists t_student3(myHome INTEGER,ptime text,videosource text,topicImg text,topicSid text,title text,sectiontitle text,vid text,m3u8_url text,playersize integer,topicName text,votecount integer,replyCount integer,replyBoard text,cover text,sizeSD integer,playCount integer,mycover text,length integer,topicDesc text,sizeHD integer,mp4Hd_url text,replyid text,m3u8Hd_url text,desc text,mp4_url text,sizeSHD integer, primary key(myHome))"];
    [self exceSql:sql2];
    
    
}

- (IBAction)insertDefaultData:(UIButton *)sender {
    
    // 2、赋值，插入初始数据（注意NULL和空数据）
    NSString *insertSql1 = @"INSERT INTO t_student2(name2, age2, score2) VALUES ('lee', '""', '28');";
    NSString *insertSql2 = @"INSERT INTO t_student2(name2, age2, score2) VALUES ('yee', null, '');";
    NSString *insertSql3 = @"INSERT INTO t_student2(name2, age2, score2) VALUES ('Fire', 140, 100);";
    [self exceSqls:@[insertSql1,insertSql2,insertSql3]];
    
}

- (IBAction)insertData:(UIButton *)sender {
    
    NSString *insertSql1 = [NSString stringWithFormat:@"INSERT INTO t_student2(name2, age2, score2) VALUES ('%@', '%@', '%@');",self.name.text,self.age.text,self.score.text];
    [self exceSql:insertSql1];
    
}

- (IBAction)deleteAllData:(UIButton *)sender {
    
    // 删除t_student2所有数据的SQL语句
    NSString *deleteSql = @"DELETE FROM t_student2";
    [self exceSql:deleteSql];
    
}

- (IBAction)update:(UIButton *)sender {
    
    NSString *updateSql = @"UPDATE t_student2 SET NAME2 = 'TOM' WHERE id2 = '22';";
    [self exceSql:updateSql];
    
}

- (IBAction)queryData:(UIButton *)sender {
    
    NSString *querySql = @"SELECT * FROM t_student2 WHERE id2 = '22';"; // id2主键为22
    NSString *querySql2 = @"select * from t_student2 where age2 is not NULL";// 不要NUll
    NSString *querySql3 = @"select * from t_student2 where age2 is not '""'";// 不要空值
    NSString *querySql4 = @"select * from t_student2 where age2 is not '""' and age2 is not NULL";// 不要空值 和 NULL
    NSMutableArray *resultArray = [self querySql:querySql4 uid:@"common"];
    NSLog(@"resultArray:%@",resultArray);
    
}

/**
 查询语句, 有结果集返回
 
 @param sql sql语句
 @param uid 用户的唯一标识
 @return 字典(一行记录)组成的数组
 */
- (NSMutableArray <NSMutableDictionary *>*)querySql:(NSString *)sql uid:(NSString *)uid {
    [self openDB:uid];
    // 准备语句(预处理语句)
    
    // 1. 创建准备语句
    // 参数1: 一个已经打开的数据库
    // 参数2: 需要中的sql
    // 参数3: 参数2取出多少字节的长度 -1 自动计算 \0
    // 参数4: 准备语句
    // 参数5: 通过参数3, 取出参数2的长度字节之后, 剩下的字符串
    sqlite3_stmt *ppStmt = nil;
    if (sqlite3_prepare_v2(ppDb, sql.UTF8String, -1, &ppStmt, nil) != SQLITE_OK) {
        NSLog(@"准备语句编译失败");
        return nil;
    }
    
    // 2. 绑定数据(省略)
    
    // 3. 执行
    // 大数组
    NSMutableArray *rowDicArray = [NSMutableArray array];
    while (sqlite3_step(ppStmt) == SQLITE_ROW) {
        // 一行记录 -> 字典
        // 1. 获取所有列的个数
        int columnCount = sqlite3_column_count(ppStmt);
        
        NSMutableDictionary *rowDic = [NSMutableDictionary dictionary];
        [rowDicArray addObject:rowDic];
        // 2. 遍历所有的列
        for (int i = 0; i < columnCount; i++) {
            // 2.1 获取列名
            const char *columnNameC = sqlite3_column_name(ppStmt, i);
            NSString *columnName = [NSString stringWithUTF8String:columnNameC];
            
            // 2.2 获取列值
            // 不同列的类型, 使用不同的函数, 进行获取
            // 2.2.1 获取列的类型
            int type = sqlite3_column_type(ppStmt, i);
            // 2.2.2 根据列的类型, 使用不同的函数, 进行获取
            id value = nil;
            switch (type) {
                case SQLITE_INTEGER:
                    value = @(sqlite3_column_int(ppStmt, i));
                    break;
                case SQLITE_FLOAT:
                    value = @(sqlite3_column_double(ppStmt, i));
                    break;
                case SQLITE_BLOB:
                    value = CFBridgingRelease(sqlite3_column_blob(ppStmt, i));
                    break;
                case SQLITE_NULL:
                    value = @"";
                    break;
                case SQLITE3_TEXT:
                    value = [NSString stringWithUTF8String: (const char *)sqlite3_column_text(ppStmt, i)];
                    break;
                    
                default:
                    break;
            }
            
            [rowDic setValue:value forKey:columnName];
            
        }
    }
    
    
    // 4. 重置(省略)
    
    // 5. 释放资源
    sqlite3_finalize(ppStmt);
    
    [self closeDB];
    
    return rowDicArray;
}

- (BOOL)openDB:(NSString *)uid {
    // 0. 确定路径
    NSString *dbName = @"common.sqlite";
    if (uid.length != 0) {
        dbName = [NSString stringWithFormat:@"%@.sqlite", uid];
    }
    NSString *dbPath = [kCachePath stringByAppendingPathComponent:dbName];
    
    // 1. 创建&打开一个数据库
    return  sqlite3_open(dbPath.UTF8String, &ppDb) == SQLITE_OK;
    
}

/**
 关闭数据库
 */
- (void)closeDB {
    sqlite3_close(ppDb);
}


- (BOOL)exceSql:(NSString *)sql {
    
    // 1 open
    NSString *dbName = @"common.sqlite";
    NSString *dbPath = [kCachePath stringByAppendingPathComponent:dbName];
    BOOL isOpen = sqlite3_open(dbPath.UTF8String, &ppDb) == SQLITE_OK;
    if (!isOpen) {
        NSLog(@"warning:open the database failure");
        return NO;
    }
    
    // 2 exce
    char *zErrorMsg;
    BOOL result = sqlite3_exec(ppDb, sql.UTF8String, nil, nil, &zErrorMsg) == SQLITE_OK;
    if (!result) {
        NSLog(@"zErrorMsg:%s",zErrorMsg);
        NSLog(@"exce failure : %@",sql);
        return NO;
    }
    
    // 3 close
    sqlite3_close(ppDb);
    return YES;
}

- (BOOL)exceSqls:(NSArray *)sqls {
    
    // 1 open
    NSString *dbName = @"common.sqlite";
    NSString *dbPath = [kCachePath stringByAppendingPathComponent:dbName];
    BOOL isOpen = sqlite3_open(dbPath.UTF8String, &ppDb) == SQLITE_OK;
    if (!isOpen) {
        NSLog(@"warning:open the database failure");
        return NO;
    }
    
    // 2 exce
    if (![[sqls class] isSubclassOfClass:[NSArray class]]) {
        NSLog(@"请确保传入的参数是数组!!!");
        return NO;
    }
    if (sqls.count <= 0  ) {
        NSLog(@"数组为空！！！");
        return NO;
    }
    
    for (NSString *sql in sqls) {
        char *zErrorMsg;
        BOOL result = sqlite3_exec(ppDb, sql.UTF8String, nil, nil, &zErrorMsg) == SQLITE_OK;
        if (!result) {
            NSLog(@"zErrorMsg:%s",zErrorMsg);
            NSLog(@"exce failure : %@",sql);
            return NO;
        }
    }
    
    
    // 3 close
    sqlite3_close(ppDb);
    return YES;
}


@end

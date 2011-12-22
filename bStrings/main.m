//
//  main.m
//  bStrings
//
//  Created by v2m on 11-12-22.
//  Copyright (c) 2011年 DremTop. All rights reserved.
//
#import <Foundation/Foundation.h>

typedef enum
{
    create = 0,
    append
}CreateType;
// 从命令行参数分析出的基本数据进一步处理
void opration(char* outFile,char* srcFile,CreateType type);
// 分析path对应的plist文件,写入outFilePath中
void parse(NSString* path,BOOL isOutDir,NSString* outFilePath,CreateType type);
// 根据字典得到所有可以国际化的字符串
NSMutableString* analyseDictionary(NSDictionary* dic);

int main (int argc, const char * argv[])
{
    @autoreleasepool {
        // get arguments
        char* outFile = nil;
        char* srcFile = nil;
        CreateType type = create;
        for (int i = 1; i < argc; i++) {
            if (argv[i][0] == '-') {
                if (strcmp(argv[i], "-a") == 0) {
                    type = append;
                }
                else if (strcmp(argv[i], "-o") == 0)
                {
                    if (argc > i+1) {
                        free(outFile);
                        outFile = (char*)malloc(strlen(argv[++i])+1);
                        strcpy(outFile, argv[i]);
                    }
                }
            }
            else
            {
                free(srcFile);
                srcFile = (char*)malloc(strlen(argv[i])+1);
                strcpy(srcFile, argv[i]);
            }
        }
        
        opration(outFile,srcFile,type);
        free(outFile);
        free(srcFile);
    }
    
    return 0;
}

NSMutableString* analyseDictionary(NSDictionary* dic)
{
    NSMutableString* mString = [NSMutableString stringWithString:@""];
    NSArray* pArray = [dic objectForKey:@"PreferenceSpecifiers"];
    if (pArray == nil|| ![pArray isKindOfClass:[NSArray class]] || [pArray count]<1) {
        return mString;
    }
    
    int num = 0;
    for (NSDictionary* d in pArray) {
        NSString* title = [d objectForKey:@"Title"];
        if (title!= nil) {
            [mString appendFormat:@"/* Item-%d Type:%@ */\n",num, [d objectForKey:@"Type"]];
            [mString appendFormat:@"\"%@\" = \"%@\";\n",title,title];
        }
        
        NSArray* titles = [d objectForKey:@"Titles"];
        if (titles != nil && [titles isKindOfClass:[NSArray class]] && [titles count]>0) {
            for (NSString* str in titles) {
                [mString appendFormat:@"\"%@\" = \"%@\";\n",str,str];
            }
        }
        num++;
        [mString appendString:@"\n"];
    }
    [mString appendString:@"\n"];
    return mString;
    
}

void parse(NSString* path,BOOL isOutDir,NSString* outFilePath,CreateType type)
{
    if ([[path pathExtension] isEqualToString:@"plist"]) {
        NSDictionary* dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
        
        // 得到输出路径
        NSString* outPath = outFilePath;
        if (isOutDir) {
            outPath = [[outFilePath stringByAppendingPathComponent:[[path stringByDeletingPathExtension] lastPathComponent]]stringByAppendingPathExtension:@"strings"];
        }
        // 不存在就创建
        if (![[NSFileManager defaultManager] fileExistsAtPath:outPath]) {
            if (![[NSFileManager defaultManager] createFileAtPath:outPath contents:nil attributes:nil]) {
                printf("%s","Could not create target file.");
                return;
            } 
        }
        
        NSFileHandle* outhandle = [NSFileHandle fileHandleForWritingAtPath:outPath];
        if (outhandle == nil) {
            printf("%s","Can not write now.");
            return ;
        }
        // 得到数据,写入
        NSMutableString *string = analyseDictionary(dictionary);
        // 清空内容
        if(type == create && isOutDir)
            [outhandle truncateFileAtOffset:0];
        else
            [outhandle seekToEndOfFile];
        [outhandle writeData:[string dataUsingEncoding:NSUTF16StringEncoding]];
        [outhandle closeFile];
    }
}

void opration(char* outFile,char* srcFile,CreateType type)
{
    NSFileManager* manager = [NSFileManager defaultManager];
    
    // 根据命令行参数得到的路径
    NSString* srcFilePath = [manager currentDirectoryPath];
    if (srcFile)
        srcFilePath = [NSString stringWithCString:srcFile encoding:[NSString defaultCStringEncoding]];
    NSString* outFilePath = [manager currentDirectoryPath];
    if (outFile)
        outFilePath = [NSString stringWithCString:outFile encoding:[NSString defaultCStringEncoding]];   
    
    // check src
    BOOL isSrcDir = NO;
    if (![manager fileExistsAtPath:srcFilePath isDirectory:&isSrcDir]) {
        srcFilePath = [manager currentDirectoryPath];
        isSrcDir = YES;
    }
    
    BOOL isOutDir = NO;
    if (![manager fileExistsAtPath:outFilePath isDirectory:&isOutDir]) {
        outFilePath = [manager currentDirectoryPath];
        isOutDir = YES;
    }
    
    // out 是文件,且非添加模式,在 遍历plist文件之前就清空内容
    if (!isOutDir && type == create)
    {
        NSFileHandle* oh = [NSFileHandle fileHandleForWritingAtPath:outFilePath];
        if (oh == nil) {
            printf("%s","Can not write now.");
            return ;
        }

        [oh truncateFileAtOffset:0];
        [oh writeData:[NSData dataWithBytes:"" length:0]];
        [oh closeFile];
    }
        
    
    // directory
    if (isSrcDir) {
        NSDirectoryEnumerator* dirEnumerator = [manager enumeratorAtPath:srcFilePath];
        NSString* path = nil;
        while ((path = [dirEnumerator nextObject]) != nil) 
        {
            path = [srcFilePath stringByAppendingPathComponent:path];
            BOOL isDir = NO;
            if (![manager fileExistsAtPath:path isDirectory:&isDir]) 
                continue;
            if (isDir)
            {
                [dirEnumerator skipDescendants];
                continue;
            }
            
            parse(path,isOutDir,outFilePath,type);
        }
    }
    else // file
    {
        parse(srcFilePath,isOutDir,outFilePath,type);
    }
}




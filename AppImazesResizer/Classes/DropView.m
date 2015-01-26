//
//  DropView.m
//  AppIcons
//
//  Created by B02923 on 2014/08/01.
//  Copyright (c) 2014年 B02923. All rights reserved.
//

#import "DropView.h"
#import "NSImage+Resize.h"
#import "NSDictionary+Getter.h"




@interface DropView ()

@property (nonatomic, assign) IBOutlet NSTextView* textView;
@property (nonatomic, assign) IBOutlet NSView* label;

@property (nonatomic, assign) IBOutlet NSSlider* shaerpen1Slider;
@property (nonatomic, assign) IBOutlet NSSlider* shaerpen2Slider;
@property (nonatomic, assign) IBOutlet NSTextField* sharpen1Label;
@property (nonatomic, assign) IBOutlet NSTextField* sharpen2Label;

@property (nonatomic, assign) IBOutlet NSButton* cancelButton;

@property (nonatomic, assign) IBOutlet NSProgressIndicator* indicator;

@property (nonatomic, retain) NSString* outPath;
@property (nonatomic, retain) NSString* outPath_iOS;
@property (nonatomic, retain) NSString* outPath_Android;
@property (nonatomic, retain) NSMutableArray* fileNames;


@property (nonatomic, assign) BOOL canceled;
@property (nonatomic, assign) int fileCount;
@property (nonatomic, assign) int execCount;
@property (nonatomic, assign) int errorCount;
@property (nonatomic, assign) int completeCount;

@end



@implementation DropView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}
- (void)awakeFromNib
{
    if ( [[self superclass] instancesRespondToSelector:@selector(awakeFromNib)] ) {
        [super awakeFromNib];
        [self clearLog];
        [self takeFloatValueFrom:nil];
    }
}
- (void)windowWillClose:(NSNotification *)aNotification {
    [NSApp terminate:self];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
}


// ドラッグしてフィールド内に入ったことの通知
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    // 受付可能なオブジェクトかチェックする
    BOOL bRet = [self acceptableObject:sender];
    if ( bRet != YES ) {
        return NSDragOperationNone;
    }
    
    // ドラッグ中状態に設定
    //    [self setInDragging: YES];
    
    return NSDragOperationGeneric;
}

// 現在ドラッグ中のオブジェクトが自フィールドにドロップ可能か判定する
- (BOOL)acceptableObject:(id <NSDraggingInfo>)info
{
    return YES;
}

// ドラッグ情報からファイルリスト取得
- (NSArray *)fileListInDraggingInfo:(id <NSDraggingInfo>)info
{
    // ペーストボードオブジェクト取得
    NSPasteboard *poPasteBd = [info draggingPasteboard];
    // ドラッグされたファイルの一覧取得
    NSArray *parrFiles = [poPasteBd propertyListForType:NSFilenamesPboardType];
    return parrFiles;
}

// ドロップ処理の実行要求
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    
    self.fileNames = [NSMutableArray array];
    self.errorCount = 0;
    self.completeCount = 0;

    // ドラッグされたファイルの一覧取得
    NSArray *parrFiles = [self fileListInDraggingInfo:sender];
    
    NSString *pstrPath = [parrFiles objectAtIndex:0];
    self.outPath = [pstrPath stringByDeletingLastPathComponent];
    
    // 出力先ディレクトリ
    NSError* err = nil;
    BOOL result = NO;
    
    NSString* iconsDirPath = [self.outPath stringByAppendingPathComponent:@"ResizedImages"];
    
    if ([pstrPath isEqualToString:iconsDirPath]) {
        [self appendLog:@"出力フォルダを入力することはできません."];
        return NO;
    }
    
    self.outPath_iOS =[iconsDirPath stringByAppendingPathComponent:@"iOS"];
    self.outPath_Android =[iconsDirPath stringByAppendingPathComponent:@"Android"];
    
    result = [[NSFileManager defaultManager] createDirectoryAtPath:_outPath_iOS
                                       withIntermediateDirectories:YES
                                                        attributes:nil
                                                             error:&err];
    result = [[NSFileManager defaultManager] createDirectoryAtPath:_outPath_Android
                                       withIntermediateDirectories:NO
                                                        attributes:nil
                                                             error:&err];

    self.indicator.minValue = 0;
    self.indicator.maxValue = parrFiles.count;
    self.canceled = NO;

    self.cancelButton.hidden = NO;
    self.hidden = YES;
    [self clearLog];
    
    [self performSelectorInBackground:@selector(exec:) withObject:parrFiles];

    return YES;
    
}


- (void)exec:(NSArray*)parrFiles {

    self.fileCount = 0;
    for (NSUInteger i=0; i<parrFiles.count; i++) {
        NSString *pathString = [parrFiles objectAtIndex:i];
        [self countPathString:pathString];
    }
    dispatch_sync(dispatch_get_main_queue(), ^(){
        self.indicator.maxValue = (double)self.fileCount;
        self.indicator.doubleValue = 0;
        self.execCount = 0;
        [self.indicator displayIfNeeded];
    });

    for (NSUInteger i=0; i<parrFiles.count; i++) {
        if(self.canceled)break;
        // ドラッグされたファイルパス取得
        NSString *pathString = [parrFiles objectAtIndex:i];
        [self doWithPathString:pathString];
    }

    dispatch_sync(dispatch_get_main_queue(), ^(){
        if (self.canceled) {
            [self appendLog:@"キャンセルしました."];
            self.indicator.doubleValue = 0;
            [self.indicator displayIfNeeded];
        }
        else if ( self.errorCount>0 ) {
            [self appendLog:[NSString stringWithFormat:@"%d 件 処理完了. （うち異常ファイル %d 件を検出）",self.completeCount, self.errorCount]];
        }
        else {
            if (self.completeCount >0 ){
                [self appendLog:[NSString stringWithFormat:@"%d 件 処理完了.",self.completeCount]];
            }
            else {
                [self appendLog:@"処理対象がありませんでした."];
            }
        }
        
        self.cancelButton.hidden = YES;
        self.hidden = NO;
        
    });

}


- (void)countPathString:(NSString*)pathString {
    BOOL isExist, isDir;
    NSFileManager* fileMng = [NSFileManager defaultManager];
    isExist = [fileMng fileExistsAtPath:pathString isDirectory:&isDir];
    if (isExist) {
        if (isDir) {
            NSError* err;
            NSArray* array = [fileMng contentsOfDirectoryAtPath:pathString error:&err];
            if (!err) {
                for (NSString* subPathString in array) {
                    [self countPathString:[pathString stringByAppendingPathComponent:subPathString]];
                }
            }
        }
        else {
            self.fileCount ++;
        }
    }
}



/**
 * パス１件の処理.
 */
- (void)doWithPathString:(NSString*)pathString {
    
    if(self.canceled)return;
    BOOL isExist, isDir;
    NSFileManager* fileMng = [NSFileManager defaultManager];
    isExist = [fileMng fileExistsAtPath:pathString isDirectory:&isDir];

    if ( isExist ) {
        if (isDir) {
            NSError* err;
            NSArray* array = [fileMng contentsOfDirectoryAtPath:pathString error:&err];
            if (!err) {
                for (NSString* subPathString in array) {
                    [self doWithPathString:[pathString stringByAppendingPathComponent:subPathString]];
                }
            }
        }
        else {
            if( ! [self resizeWithFilePath:pathString] ) {
                self.errorCount ++;
            };
            dispatch_sync(dispatch_get_main_queue(), ^(){
                self.execCount++;
                self.indicator.doubleValue = self.execCount;
                [self.indicator displayIfNeeded];
            });
        }
    }
}





- (BOOL)resizeWithFilePath:(NSString*)path {
   
    // 処理対象フィルタ.
    NSString* ext = path.lastPathComponent.pathExtension;
    if ([path.lastPathComponent hasPrefix:@"."])return YES;
    if (!(  [ext caseInsensitiveCompare:@"jpg"]
        ||[ext caseInsensitiveCompare:@"jpeg"]
        ||[ext caseInsensitiveCompare:@"gif"]
        ||[ext caseInsensitiveCompare:@"png"]))
    {
        return YES;
    }
    
    BOOL noError = YES;
    NSImage* orgImage = [[NSImage alloc] initWithContentsOfFile:path];
    NSString* baseName = [path stringByDeletingPathExtension];
    NSMutableString* errStr = [NSMutableString string];

    //
    // ファイル名テスト.
    //
    
    if ( [path.lastPathComponent.stringByDeletingPathExtension hasSuffix:@"@2x"]
        || [path.lastPathComponent.stringByDeletingPathExtension hasSuffix:@"@3x"])
    {
        [errStr appendString:@" - このファイルはスケール指定済（@2x,@3x）のため処理しません.\n"];
        [self appendLog:[NSString stringWithFormat:@"[情報]%@\n%@", path, errStr]];
        return YES;
    }

    //
    // サイズテスト.
    //
    if ( (orgImage.size.width < 3) && (orgImage.size.width < 3) ) {
        [errStr appendString:@" - このファイルは画像のサイズが小さいため処理しません.\n"];
        [self appendLog:[NSString stringWithFormat:@"[情報]%@\n%@", path, errStr]];
        return YES;
    }
    
    //
    // 重複テスト.
    //
    BOOL exist = NO;
    for (NSString* filename in self.fileNames ) {
        if ([path.lastPathComponent.stringByDeletingPathExtension isEqualTo:filename]) {
            exist =YES;
            break;
        }
    }
    if (exist) {
        [errStr appendString:@" - 同名のファイルが存在します. フォルダが異なっていても、同名の複数ファイルは利用できません.\n"];
        noError = NO;
    }
    else {
        [self.fileNames addObject:path.lastPathComponent.stringByDeletingPathExtension];
    }
    
    //
    // ファイル名テスト.
    //
    
    NSRegularExpression* regEx = [NSRegularExpression regularExpressionWithPattern:@"[0-9,a-z,_]"
                                                                           options:0
                                                                             error:nil];
    NSMutableString* name = [NSMutableString stringWithString:path.lastPathComponent.stringByDeletingPathExtension];
    [regEx replaceMatchesInString:name
                          options:0
                            range:NSMakeRange(0, name.length)
                     withTemplate:@""];
    if (name.length>0) {
        [errStr appendString:@" - ファイル名が不正です. 半角英数、”_”以外の文字は Android用ファイル名には利用できません.\n"];
        noError = NO;
    }

    //
    // ファイル名テスト.
    //

    NSRegularExpression* regEx2 = [NSRegularExpression regularExpressionWithPattern:@"^[0-9]"
                                                                           options:0
                                                                             error:nil];
    NSMutableString* name2 = [NSMutableString stringWithString:path.lastPathComponent.stringByDeletingPathExtension];
    [regEx2 replaceMatchesInString:name2
                          options:0
                            range:NSMakeRange(0, name2.length)
                     withTemplate:@""];
    if ( ! [path.lastPathComponent.stringByDeletingPathExtension isEqualToString:name2]) {
        [errStr appendString:@" - ファイル名が不正です. 数字で始まるファイル名は Android では利用できません.\n"];
        
        noError = NO;
    }

    //
    // 画像サイズテスト.
    //

    if ( (((int)orgImage.size.width%3)!=0) || (((int)orgImage.size.width%3)!=0) ) {
        [errStr appendString:[NSString stringWithFormat:@" - 画像ファイルの大きさ(%d,%d)が不正です. タテ・ヨコとも画素数が 3 の倍数である必要があります.\n",
                              (int)orgImage.size.width,
                              (int)orgImage.size.height]];
        noError = NO;
    }

    for (int z=1; z<=3; z++) {
        int sw = orgImage.size.width / 3;
        int sh = orgImage.size.height / 3;
        float filterValue = 0;
        switch (z) {
            case 1:
                filterValue = self.shaerpen1Slider.floatValue;
                break;
            case 2:
                filterValue = self.shaerpen2Slider.floatValue;
                break;
            default:
                break;
        }
        NSImage* img = (z == 3) ? [orgImage copy]
        : [orgImage resizedImageToWidth:sw*z
                                 height:sh*z
                              maskImage:nil
                          filterEnabled:(filterValue>0)
                              intensity:filterValue
                          sharpenRadius:1.0];

        NSString* name = [NSString stringWithFormat:@"%@%@.png",
                          baseName,
                          ((z>1) ? [NSString stringWithFormat:@"@%dx",z] : @"")];
        
        {
            NSString* outName = [name stringByReplacingOccurrencesOfString:self.outPath
                                                                withString:[NSString stringWithFormat:_outPath_iOS, self.outPath]];
            NSError* err = nil;
            BOOL result = NO;
            result = [[NSFileManager defaultManager] createDirectoryAtPath:[outName stringByDeletingLastPathComponent]
                                               withIntermediateDirectories:YES
                                                                attributes:nil
                                                                     error:&err];
            if (result) {
                [img writeToFileAsPNGFile:outName];
            }
            else {
                [errStr appendString:@"[失敗]ファイルを生成できませんでした.\n"];
                noError = NO;
            }
        }
        {
            NSString* outDir = nil;
            switch (z) {
                case 1:
                    outDir = [self.outPath_Android stringByAppendingPathComponent:@"drawable-mdpi"];
                    break;
                case 2:
                    outDir = [self.outPath_Android stringByAppendingPathComponent:@"drawable-xhdpi"];
                    break;
                case 3:
                    outDir = [self.outPath_Android stringByAppendingPathComponent:@"drawable-xxhdpi"];
                    break;
                default:
                    outDir = [self.outPath_Android stringByAppendingPathComponent:@"drawable"]; // ここは来ないハズ.
                    break;
            }
            NSString* outName = [outDir stringByAppendingPathComponent:path.lastPathComponent];
            NSError* err = nil;
            BOOL result = NO;
            result = [[NSFileManager defaultManager] createDirectoryAtPath:[outName stringByDeletingLastPathComponent]
                                               withIntermediateDirectories:YES
                                                                attributes:nil
                                                                     error:&err];
            if ( result ) {
                [img writeToFileAsPNGFile:outName];
            }
            else {
                [errStr appendString:@"[失敗]ファイルを生成できませんでした.\n"];
                noError = NO;
            }
        }
    }
    
    if ( ! noError ) {
        [self appendLog:[NSString stringWithFormat:@"[警告]%@\n%@", path, errStr]];
    }
    
    self.completeCount++;
    return noError;
}

- (IBAction)performClick:(id)sender {
    if (sender == self.cancelButton) {
        self.canceled = YES;
    }
}

- (IBAction)takeFloatValueFrom:(id)sender {
    
    _sharpen1Label.stringValue = (_shaerpen1Slider.floatValue>0) ? [NSString stringWithFormat:@"%.1f%%", _shaerpen1Slider.floatValue*100]:@"OFF";
    _sharpen2Label.stringValue = (_shaerpen2Slider.floatValue>0) ? [NSString stringWithFormat:@"%.1f%%", _shaerpen2Slider.floatValue*100]:@"OFF";
    
}

- (void)appendLog:(NSString*)string {

    [self performSelectorOnMainThread:@selector(doAppendLog:) withObject:string waitUntilDone:NO];
}

- (void)doAppendLog:(NSString*)string {
    [self.textView.textStorage beginEditing];
    NSAttributedString* astr =[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", string]];
    [self.textView.textStorage appendAttributedString:astr];
    [self.textView.textStorage endEditing];
    [self.textView autoscroll:nil];
}

- (IBAction)onClickedClearButton:(id)sender {

    [self clearLog];
    
}

- (void)clearLog {
    [self.textView.textStorage beginEditing];
    [self.textView.textStorage deleteCharactersInRange:NSMakeRange(0, self.textView.textStorage.mutableString.length)];
    [self.textView.textStorage endEditing];
    self.label.hidden = NO;
    self.image = nil;
}


@end

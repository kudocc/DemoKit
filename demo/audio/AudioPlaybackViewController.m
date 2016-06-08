//
//  AudioPlaybackViewController.m
//  audio
//
//  Created by KudoCC on 15/9/21.
//  Copyright (c) 2015年 KudoCC. All rights reserved.
//

#import "AudioPlaybackViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "NSString+CCKit.h"

@interface AudioPlaybackViewController () <UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate> {
    NSInteger pageSize;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *arrayFile;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, assign) NSUInteger indexPlay;

@end

@implementation AudioPlaybackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGSize size = CGSizeMake(self.view.bounds.size.width, [UIScreen mainScreen].bounds.size.height-44-20);
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, size.width, size.height) style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tableFooterView = [UIView new];
    
    NSString *path = [NSString cc_documentPath];
    _arrayFile = [self listFileAtPath:path];
    
    _indexPlay = NSNotFound;
}

- (NSArray *)listFileAtPath:(NSString *)path {
    return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
}

- (AVAudioPlayer *)playFile:(NSString *)file {
    NSURL *url = [NSURL URLWithString:file];
    NSError *error = nil;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    player.delegate = self;
    if (error) {
        NSLog(@"error[%@] when play %@", error, file);
    }
    BOOL res = [player play];
    NSLog(@"play file %@, result %@, duration %f", file, @(res), player.duration);
    return player;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([_player isPlaying]) {
        if (indexPath.row == _indexPlay) {
            [_player stop];
        } else {
            [_player stop];
            NSString *fileName = _arrayFile[indexPath.row];
            NSString *filePath = [[NSString cc_documentPath] stringByAppendingPathComponent:fileName];
            _player = [self playFile:filePath];
            _indexPlay = indexPath.row;
            self.title = [NSString stringWithFormat:@"play:%@", fileName];
        }
    } else {
        if (indexPath.row == _indexPlay) {
            [_player play];
        } else {
            NSString *fileName = _arrayFile[indexPath.row];
            NSString *filePath = [[NSString cc_documentPath] stringByAppendingPathComponent:fileName];
            _player = [self playFile:filePath];
            _indexPlay = indexPath.row;
            self.title = [NSString stringWithFormat:@"play:%@", fileName];
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_arrayFile count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@", _arrayFile[indexPath.row]];
    return cell;
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player {
    if (_player == player) {
        NSString *file = _arrayFile[_indexPlay];
        self.title = [NSString stringWithFormat:@"interruption:%@", file];
    }
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags {
    if (_player == player) {
        NSString *file = _arrayFile[_indexPlay];
        self.title = [NSString stringWithFormat:@"play:%@", file];
        [player play];
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (_player == player) {
        NSString *file = _arrayFile[_indexPlay];
        self.title = [NSString stringWithFormat:@"stop play:%@", file];
    }
}

@end


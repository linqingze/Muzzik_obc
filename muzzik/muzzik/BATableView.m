//
//  ABELTableView.m
//  ABELTableViewDemo
//
//  Created by abel on 14-4-28.
//  Copyright (c) 2014年 abel. All rights reserved.
//

#import "BATableView.h"
#import "BATableViewIndex.h"

@interface BATableView()<BATableViewIndexDelegate>
@property (nonatomic, strong) UILabel * flotageLabel;
@property (nonatomic, strong) BATableViewIndex * tableViewIndex;
@end

@implementation BATableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        self.tableView.showsVerticalScrollIndicator = NO;
        self.tableView.allowsMultipleSelection = YES;
        [self.tableView  setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self addSubview:self.tableView];
        [self.tableView registerClass:[AtfreindCell class] forCellReuseIdentifier:@"AtfreindCell"];
        self.tableViewIndex = [[BATableViewIndex alloc] initWithFrame:(CGRect){SCREEN_WIDTH-40,0,30,frame.size.height}];
        [self addSubview:self.tableViewIndex];
        
        self.flotageLabel = [[UILabel alloc] initWithFrame:(CGRect){(self.bounds.size.width ) / 2-32,(self.bounds.size.height - 64) / 2,64,64}];
        self.flotageLabel.backgroundColor = Color_Additional_5;
        self.flotageLabel.layer.cornerRadius = 3;
        self.flotageLabel.clipsToBounds = YES;
        self.flotageLabel.hidden = YES;
        self.flotageLabel.textAlignment = NSTextAlignmentCenter;
        self.flotageLabel.textColor = [UIColor whiteColor];
        [self.flotageLabel setAlpha:0.4];
        [self addSubview:self.flotageLabel];
    }
    return self;
}

- (void)setDelegate:(id<BATableViewDelegate>)delegate
{
    _delegate = delegate;
    self.tableView.delegate = delegate;
    self.tableView.dataSource = delegate;
    self.tableViewIndex.indexes = [self.delegate sectionIndexTitlesForABELTableView:self];
    CGRect rect = self.tableViewIndex.frame;
    rect.size.height = self.tableViewIndex.indexes.count * 16;
    rect.origin.y = (self.bounds.size.height - rect.size.height) / 2;
    self.tableViewIndex.frame = rect;
    
    self.tableViewIndex.tableViewIndexDelegate = self;
}

- (void)reloadData
{
    [self.tableView reloadData];
    
    UIEdgeInsets edgeInsets = self.tableView.contentInset;
    
    self.tableViewIndex.indexes = [self.delegate sectionIndexTitlesForABELTableView:self];
    CGRect rect = self.tableViewIndex.frame;
    rect.size.height = self.tableViewIndex.indexes.count * 16;
    rect.origin.y = (self.bounds.size.height - rect.size.height - edgeInsets.top - edgeInsets.bottom) / 2 + edgeInsets.top ;
    self.tableViewIndex.frame = rect;
    self.tableViewIndex.tableViewIndexDelegate = self;
}


#pragma mark -
- (void)tableViewIndex:(BATableViewIndex *)tableViewIndex didSelectSectionAtIndex:(NSInteger)index withTitle:(NSString *)title
{
    if ([self.tableView numberOfSections] > index && index > -1){   // for safety, should always be YES
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index]
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:NO];
        if ([title length]>1) {
            title = @"*";
        }
        self.flotageLabel.text = title;
    }
}

- (void)tableViewIndexTouchesBegan:(BATableViewIndex *)tableViewIndex
{
    self.flotageLabel.hidden = NO;
}

- (void)tableViewIndexTouchesEnd:(BATableViewIndex *)tableViewIndex
{
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.4;
    [self.flotageLabel.layer addAnimation:animation forKey:nil];
    
    self.flotageLabel.hidden = YES;
}

- (NSArray *)tableViewIndexTitle:(BATableViewIndex *)tableViewIndex
{
    return [self.delegate sectionIndexTitlesForABELTableView:self];
}
@end

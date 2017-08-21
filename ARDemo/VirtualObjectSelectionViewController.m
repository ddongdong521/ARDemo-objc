//
//  VirtualObjectSelectionViewController.m
//  ARDemo
//
//  Created by apple on 2017/8/4.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import "VirtualObjectSelectionViewController.h"
#import "VirtualObject.h"
#import "UIImage+Extension.h"
#import "SettingManager.h"

@interface VirtualObjectSelectionViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,assign)CGSize size;
@property (nonatomic,assign)NSInteger selectedVirtualObjectRow;
@property (nonatomic,strong)VirtualObject *obj;


@end

@implementation VirtualObjectSelectionViewController
- (instancetype)initWithSize:(CGSize)size{
    if (self = [super init]) {
        self.size = size;
        self.selectedVirtualObjectRow = -1;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.size.width, self.size.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorEffect = [UIVibrancyEffect effectForBlurEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.tableView.bounces = NO;
    self.preferredContentSize = self.size;
    [self.view addSubview:self.tableView];
    
    self.selectedVirtualObjectRow = [SettingManager getSelectedObject];
    
}
#pragma mark TableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [VirtualObject getObjects].count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BOOL cellIsSelected = (indexPath.row == self.selectedVirtualObjectRow);
    
    UITableViewCell *cell = [[UITableViewCell alloc]init];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(53, 10, 200, 30)];
    UIImageView *icon = [[UIImageView alloc]initWithFrame:CGRectMake(15, 10, 30, 30)];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
    UIVisualEffectView *vibrancyView = [[UIVisualEffectView alloc]initWithEffect:vibrancyEffect];
    vibrancyView.frame = cell.contentView.frame;
    [cell.contentView insertSubview:vibrancyView atIndex:0];
    [vibrancyView.contentView addSubview:label];
    [vibrancyView.contentView addSubview:icon];
    if (cellIsSelected) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    VirtualObject *obj = [VirtualObject getObjects][indexPath.row];
    UIImage *thumbnailImage = obj.thumbImage;
    UIImage *invertedImage = [thumbnailImage inverted];
    if (invertedImage) {
        thumbnailImage = invertedImage;
    }
    label.text = obj.title;
    icon.image = thumbnailImage;
    
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row ==self.selectedVirtualObjectRow) {
        if ([self.delegate respondsToSelector: @selector(virtualObjectSelectionViewControllerDidDeselectObject:)]) {
            [self.delegate virtualObjectSelectionViewControllerDidDeselectObject:self];
        }
    }else{
        if ([self.delegate respondsToSelector:@selector(virtualObjectSelectionViewController:DidSelectedObjectAtIndexPath:)]) {
                [self.delegate virtualObjectSelectionViewController:self DidSelectedObjectAtIndexPath:indexPath.row];
            [SettingManager setSelectedObjectWithInteger:indexPath.row];
            }
        }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
}
- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

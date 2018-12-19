//
//  FontDaquanViewController.m
//  maoGang
//
//  Created by xl on 2018/11/28.
//  Copyright © 2018年 bilin. All rights reserved.
//

#import "FontDaquanViewController.h"
#import "FontDaquanCell.h"
#import "EditionController.h"
@interface FontDaquanViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *fontTableView;

@end

@implementation FontDaquanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.fontTableView.delegate = self;
    self.fontTableView.dataSource = self;
    [self.fontTableView registerNib:[UINib nibWithNibName:@"FontDaquanCell" bundle:nil] forCellReuseIdentifier:@"FontDaquanCell"];
    self.fontTableView.rowHeight = 50;
    self.navigationItem.title = @"字体大全";
    self.fontTableView.tableFooterView = [UIView new];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FontDaquanCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FontDaquanCell" forIndexPath:indexPath];
    cell.selectionStyle =  UITableViewCellSelectionStyleNone;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    EditionController *editonVC = [[EditionController alloc] initWithNibName:@"EditionController" bundle:nil titleName:@"传值"];
    [self.navigationController pushViewController:editonVC animated:YES];
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
//
//  VariationsVC.m
//  Acronym
//
//  Created by Amargoal1 on 4/19/16.
//  Copyright (c) 2016 com.demo. All rights reserved.
//

#import "VariationsVC.h"
#import "AIConstants.h"

@interface VariationsVC ()
@property (nonatomic,weak) IBOutlet UITableView *variationsTableView;
@property (nonatomic,weak) IBOutlet UILabel *noResultsLabel;
@end

@implementation VariationsVC

#pragma mark - UIViewController Lifecycle methods
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.meaning.variations.count) {
        [self.variationsTableView setHidden:NO];
        self.noResultsLabel = nil;
    }
    else{
        [self.noResultsLabel setHidden:NO];
        [self.noResultsLabel setText: [NSString stringWithFormat:NSLocalizedString(@"NoVariationsLabelText", @""),self.meaning.meaning]];
        self.variationsTableView = nil;
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- UITableView Datasource methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.meaning.variations.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *reuseIdentifier = @"VariationsCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    AIMeaning *meaning = [self.meaning.variations objectAtIndex:indexPath.row];
    cell.textLabel.text = meaning.meaning;
    cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"MeaningsSubtitleText", @""),(long)meaning.since, (long)meaning.frequency];
    
    
    return cell;
}

#pragma mark- UITableView Delegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44.0;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString *headerIdentifier = @"VariationsHeaderIdentifier";
    UITableViewCell *headerView = [tableView dequeueReusableCellWithIdentifier:headerIdentifier];
    
    headerView.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"VariationsHeaderText", @""),self.meaning.meaning];
    
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    AIMeaning *meaning = [self.meaning.variations objectAtIndex:indexPath.row];
    
    CGFloat titleHeight = [self heightForText:[meaning meaning] withFont:labelBoldTextFont];
    NSString *subTitleText = [NSString stringWithFormat:NSLocalizedString(@"MeaningsSubtitleText", @""),(long)meaning.since, (long)meaning.frequency];
    CGFloat subtitleHeight = [self heightForText:subTitleText withFont:descriptionTextFont];
    
    return titleHeight + subtitleHeight + 2*cellVerticalPadding;
    
}

#pragma mark - Helper method


-(CGFloat) heightForText:(NSString *) text withFont:(UIFont *) font {
    NSDictionary *attributes = @{NSFontAttributeName: font};
    
    CGRect rect = [text boundingRectWithSize:CGSizeMake(self.variationsTableView.frame.size.width-cellHorizontalWaste, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    return rect.size.height;
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

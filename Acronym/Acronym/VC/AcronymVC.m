//
//  AcronymVC.m
//  Acronym
//
//  Created by Amargoal1 on 4/19/16.
//  Copyright (c) 2016 com.demo. All rights reserved.
//

#import "AcronymVC.h"
#import "AIConstants.h"
#import "MBProgressHUD.h"
#import "AIAcronym.h"
#import "AIMeaning.h"
#import "VariationsVC.h"
#import "ConnectionsManager.h"

@interface AcronymVC () <ServerResponseDelegate>

@property (nonatomic, strong) AIAcronym *acronym;
@property (nonatomic, weak) IBOutlet UITableView *acronymTableView;
@property (nonatomic, weak) IBOutlet UITextField *textField;
@property (nonatomic, strong) NSCharacterSet *disallowedCharacters;;
@end

@implementation AcronymVC

#pragma mark- Life cycle methods
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self resetContent];
    
    // Only alpha-numeric characters are allowed to enter in textfield. below set has the disallowed characters
    self.disallowedCharacters = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - UITextField delegate methods
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    // reset All content on screen when user starts entering any text
    [self resetContent];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // Textfield is disabled till user enters atleast one character.
    // Dismiss Keyboard on return
    [textField resignFirstResponder];
    if(![textField.text isEqualToString:@""]){
        
        [self fetchMeaningsForAcronym:textField.text];
    }
    
    return YES;
    
}

/*
 * delegate checks the validity of user text  entry.
 * It checks for below 3 conditions
 * 1. If entered text is less than MAXLENGTH
 * (MAXLENGTH is set to 30. This value is configurable.)
 * 2. accept return key
 * 3. accept only alphabets and numeric characters.
 */

-(BOOL)textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    
    return (newLength <= MAXLENGTH || ([string rangeOfString: @"\n"].location != NSNotFound)) && ([string rangeOfCharacterFromSet:self.disallowedCharacters].location == NSNotFound);
}

#pragma mark- UITableView Datasource methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.acronym.meanings.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *reuseIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    AIMeaning *meaning = [self.acronym.meanings objectAtIndex:indexPath.row];
    cell.textLabel.text = meaning.meaning;
    cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"MeaningsSubtitleText", @""),(long)meaning.since, (long)meaning.frequency];
    
    return cell;
}

#pragma mark- UITableView Delegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44.0;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    static NSString *headerIdentifier = @"HeaderIdentifier";
    UITableViewCell *headerView = [tableView dequeueReusableCellWithIdentifier:headerIdentifier];
    
    headerView.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"HeaderText", @""),self.textField.text];
    
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // Calculate height required for title text and subtitle text. Then add padding above and below.
    AIMeaning *meaning = [self.acronym.meanings objectAtIndex:indexPath.row];
    
    CGFloat titleHeight = [self heightForText:[meaning meaning] withFont:labelBoldTextFont];
    
    NSString *subTitleText = [NSString stringWithFormat:NSLocalizedString(@"MeaningsSubtitleText", @""),(long)meaning.since, (long)meaning.frequency];
    CGFloat subtitleHeight = [self heightForText:subTitleText withFont:descriptionTextFont];
    
    return titleHeight + subtitleHeight + 2 * cellVerticalPadding;
    
}


#pragma mark - Web service
-(void) fetchMeaningsForAcronym: (NSString *) acronym {
    
    NSDictionary *parameters = @{@"sf": acronym};
    // show loading indicator when web service is made
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[ConnectionsManager sharedManager] fetchMeaningsForAcronym:parameters withdelegate:self];
}

#pragma mark - Helper methods

-(void) resetContent{
    [self.acronymTableView setHidden:YES];
    self.acronym = nil;
}

-(CGFloat) heightForText:(NSString *) text withFont:(UIFont *) font {
    NSDictionary *attributes = @{NSFontAttributeName: font};
    
    CGRect rect = [text boundingRectWithSize:CGSizeMake(self.acronymTableView.frame.size.width - cellHorizontalWaste, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    return rect.size.height;
}

#pragma mark - Error handling

-(void)showErrorAlertWithTitle:(NSString *) title message:(NSString *) message{
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    
    [alertView show];
}

#pragma mark - ServerResponseDelegate

-(void)success:(id)responseObject
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    //self.acronym ;
    
    if([responseObject isKindOfClass:[NSArray class]] && [responseObject count] > 0 ){
        for(NSDictionary *dict in responseObject){
            
            // even though response object is of type array, we are just capturing 1st object as the response of this web service always has just one object for acronym and its corresponding meanings.
            AIAcronym *acronym = [[AIAcronym alloc] init];
            [acronym setShortForm: [dict objectForKey:@"sf"]] ;
            [acronym setMeanings:[self getMeanings:[dict objectForKey:@"lfs"]]];
            
            
            self.acronym = acronym;
            if (self.acronym && self.acronym.meanings.count > 0) {
                [self.acronymTableView setHidden:NO];
                [self.acronymTableView setContentOffset:CGPointZero animated:NO];
                [self.acronymTableView reloadData];
            }
            else{
                // show no results alerts
                [self showErrorAlertWithTitle:NSLocalizedString(@"NoResultsTitle", @"") message:[NSString stringWithFormat:NSLocalizedString(@"NoResultsMessage", @""),self.textField.text]];
            }
            
        }
    }
}

-(void)failure:(id)response
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    // show error alert with error description
    [self showErrorAlertWithTitle:nil message:@"Request failed"];
}

#pragma mark end ServerResponseDelegate


//Get meanings
-(NSMutableArray *) getMeanings:(NSMutableArray *) responseArray {
    NSMutableArray *meaningArray = [NSMutableArray array];
    for(NSDictionary *dict in responseArray){
        
        AIMeaning *meaning = [[AIMeaning alloc] init];
        [meaning setMeaning: [dict objectForKey:@"lf"]] ;
        [meaning setFrequency: [[dict objectForKey:@"freq"] integerValue]] ;
        [meaning setSince: [[dict objectForKey:@"since"] integerValue]] ;
        [meaning setVariations:[self getVariations:[dict objectForKey:@"vars"]]];
        [meaningArray addObject:meaning];
    }
    return meaningArray;
}

//Get variations
-(NSMutableArray *) getVariations:(NSMutableArray *) responseArray {
    NSMutableArray *variationsArray = [NSMutableArray array];
    for(NSDictionary *dict in responseArray){
        
        AIMeaning *meaning = [[AIMeaning alloc] init];
        [meaning setMeaning: [dict objectForKey:@"lf"]] ;
        [meaning setFrequency: [[dict objectForKey:@"freq"] integerValue]] ;
        [meaning setSince: [[dict objectForKey:@"since"] integerValue]] ;
        
        [variationsArray addObject:meaning];
    }
    return variationsArray;
}


#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"VariationsIdentifier"]) {
        NSIndexPath *indexPath = [self.acronymTableView indexPathForSelectedRow];
        VariationsVC *destinationViewController = [segue destinationViewController];
        destinationViewController.meaning = [self.acronym.meanings objectAtIndex:indexPath.row];
    }
}

@end

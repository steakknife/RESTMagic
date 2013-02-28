//
//  RMListViewController.m
//  RESTMagic

#import "RMListViewController.h"

@implementation RMListViewController

-(void)objectDidLoad{
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    objectDict = [NSJSONSerialization JSONObjectWithData:objectData options:NSJSONReadingMutableContainers error:nil];
    [self.tableView reloadData];
    
    if ([objectDict objectForKey:@"addButton"]) {
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem:)];
        
        self.navigationItem.rightBarButtonItem = addButton;
    }
    
}


-(void)addItem:(id)sender{
    if (objectDict[@"addButton"]) {
        RMAPIManager* apiManager = [RMAPIManager sharedAPIManager];

        if ([objectDict[@"addButton"] count] > 1) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Add an Item" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
            
            for (NSDictionary* addItem in objectDict[@"addButton"]) {
                [actionSheet addButtonWithTitle:addItem[@"title"]];
            }
            [actionSheet addButtonWithTitle:@"Cancel"];
            actionSheet.cancelButtonIndex = [actionSheet numberOfButtons] -1;

            [actionSheet showInView:self.view];
            
        } else if ([objectDict[@"addButton"] count] > 0) {
            
            [apiManager openURL:[apiManager URLForResourceAtPath:objectDict [@"addButton"][0][@"path"]] withNavigationController:self.navigationController];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (objectDict[@"addButton"]) {
        RMAPIManager* apiManager = [RMAPIManager sharedAPIManager];
        
        if ([objectDict[@"addButton"] count] >1) {
            if (buttonIndex < actionSheet.numberOfButtons) {
                [apiManager openURL:[apiManager URLForResourceAtPath:objectDict [@"addButton"][buttonIndex][@"path"]] withNavigationController:self.navigationController];
                
            }
        }
    }

}


- (id)initWithStyle:(UITableViewStyle)style{
    return [super initWithStyle:UITableViewStyleGrouped];
}

-(void)loadView{
    [super loadView];
    listTitle = @"List";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.tableView.backgroundView.backgroundColor = [UIColor colorWithRed:214.0/255.0 green:219.0/255.0 blue:228.0/255.0 alpha:1.0f];
    self.title = listTitle;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    
    if ([objectDict objectForKey:@"sections"]) {
        return [[objectDict objectForKey:@"sections"] count];
    }
    return 0;
}


- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
    
    if ([objectDict objectForKey:@"sections"]) {
        return
        [[[objectDict objectForKey:@"sections"] objectAtIndex:section] objectForKey:@"title"];
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([objectDict objectForKey:@"sections"]) {
        return [[[[objectDict objectForKey:@"sections"] objectAtIndex:section] objectForKey:@"leftItems"] count];
    }
    
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    UIView* rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth/2, 40)];
    UILabel* rightSide = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth/2-5, 40)];
    NSDictionary *object = [[objectDict objectForKey:@"sections"] objectAtIndex:[indexPath section]];
    id rightItem = [[object objectForKey:@"rightItems"] objectAtIndex:[indexPath row]];
    NSString *rightText = [NSString stringWithFormat:@"%@",
                           rightItem];
    if ([rightText length] != 0 && rightItem) {
        rightSide.text = [NSString stringWithFormat:@"%@", [[object objectForKey:@"rightItems"] objectAtIndex:[indexPath row]]];
    }
    rightSide.backgroundColor = [UIColor colorWithRed:0.968 green:0.968 blue:0.968 alpha:1.0];
    rightSide.textAlignment = NSTextAlignmentRight;
    [rightView addSubview:rightSide];
    cell.accessoryView = rightView;
    
    return cell;
}



- (NSString *)tableView:(UITableView *)tableView textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([objectDict objectForKey:@"sections"]) {
        NSDictionary *object = [[objectDict objectForKey:@"sections"] objectAtIndex:[indexPath section]];
        
        return [[object objectForKey:@"leftItems"] objectAtIndex:[indexPath row]];
    }
    return nil;
}


- (NSString *)tableView:(UITableView *)tableView urlForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RMAPIManager* apiManager = [RMAPIManager sharedAPIManager];
    NSDictionary *section = [[objectDict objectForKey:@"sections"] objectAtIndex:[indexPath section]];
    NSString* path = [[section objectForKey:@"paths"] objectAtIndex:[indexPath row]];
    if ([path length] != 0) {
        return [apiManager urlForResourceAtPath:path];
    }
    return @"";
    
}
@end
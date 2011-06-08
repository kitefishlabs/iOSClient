//
//  GamePickerRecentViewController.m
//  ARIS
//
//  Created by David J Gagnon on 6/7/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#import "GamePickerSearchViewController.h"
#import "AppServices.h"
#import "Game.h"
#import "ARISAppDelegate.h"
#import "GameDetails.h"
#import "GamePickerCell.h"
#include <QuartzCore/QuartzCore.h>

@implementation GamePickerSearchViewController

@synthesize gameTable;
@synthesize gameList;
@synthesize filteredGameList;
@synthesize refreshButton,theSearchBar;
@synthesize disableViewOverlay,searchText;

//Override init for passing title and icon to tab bar
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self) {
        self.title = @"Search";
        self.tabBarItem.image = [UIImage imageNamed:@"game.png"];
		self.filteredGameList = [[NSMutableArray alloc]initWithCapacity:1];
		
		//register for notifications
		NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
		[dispatcher addObserver:self selector:@selector(refreshViewFromModel) name:@"NewGameListReady" object:nil];
		[dispatcher addObserver:self selector:@selector(removeLoadingIndicator) name:@"RecievedGameList" object:nil];
		
    }
    return self;
}

- (void)dealloc {
	[gameList release];
    [refreshButton release];
    [super dealloc];
}



#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
    self.refreshButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
    
    self.navigationItem.rightBarButtonItem = self.refreshButton;
    
	NSLog(@"GamePickerViewController: View Loaded");
}

- (void)viewDidAppear:(BOOL)animated {
	NSLog(@"GamePickerViewController: View Appeared");	
    [self.theSearchBar becomeFirstResponder];
	self.gameList = [NSMutableArray arrayWithCapacity:1];
    
	[gameTable reloadData];
	//[self refresh];
    
	NSLog(@"GamePickerViewController: view did appear");
    [super viewDidAppear:animated];
}


-(void)refresh {
	NSLog(@"GamePickerViewController: Refresh Requested");
    
    [[AppServices sharedAppServices] fetchGameListBySearch: self.searchText];
	[self showLoadingIndicator];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


#pragma mark custom methods, logic
-(void)showLoadingIndicator{
	UIActivityIndicatorView *activityIndicator = 
	[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
	[activityIndicator release];
	[[self navigationItem] setRightBarButtonItem:barButton];
	[barButton release];
	[activityIndicator startAnimating];
}

-(void)removeLoadingIndicator{
	[[self navigationItem] setRightBarButtonItem:self.refreshButton];
}


- (void)refreshViewFromModel {
	NSLog(@"GamePickerViewController: Refresh View from Model");
	
	//Sort the game list
	NSArray* sortedGameList = [[AppModel sharedAppModel].gameList sortedArrayUsingSelector:@selector(compareDistanceFromPlayer:)];
    
	self.gameList = sortedGameList;
    
	[gameTable reloadData];
}


#pragma mark Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (tableView == self.searchDisplayController.searchResultsTableView)
		return [self.filteredGameList count];
	else return [self.gameList count];
    
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	//NSLog(@"GamePickerVC: Cell requested for section: %d row: %d",indexPath.section,indexPath.row);
    
	
	static NSString *CellIdentifier = @"Cell";
    GamePickerCell *cell = (GamePickerCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		// Create a temporary UIViewController to instantiate the custom cell.
		UIViewController *temporaryController = [[UIViewController alloc] initWithNibName:@"GamePickerCell" bundle:nil];
		// Grab a pointer to the custom cell.
		cell = (GamePickerCell *)temporaryController.view;
		// Release the temporary UIViewController.
		[temporaryController release];
    }
	
	Game *currentGame;
	if (tableView == self.searchDisplayController.searchResultsTableView) 
		currentGame = [self.filteredGameList objectAtIndex:indexPath.row];
	else currentGame = [self.gameList objectAtIndex:indexPath.row];
    
	cell.titleLabel.text = currentGame.name;
	double dist = currentGame.distanceFromPlayer;
	cell.distanceLabel.text = [NSString stringWithFormat:@"%1.1f %@",  dist/1000, NSLocalizedString(@"km", @"") ];
	cell.authorLabel.text = currentGame.authors;
	cell.numReviewsLabel.text = [NSString stringWithFormat:@"%@%@", [[NSNumber numberWithInt:currentGame.numReviews] stringValue], @" reviews"];
    cell.starView.rating = currentGame.rating;
    cell.starView.backgroundColor = [UIColor clearColor];
	
    [cell.starView setStarImage:[UIImage imageNamed:@"small-star-halfselected.png"]
                       forState:kSCRatingViewHalfSelected];
    [cell.starView setStarImage:[UIImage imageNamed:@"small-star-highlighted.png"]
                       forState:kSCRatingViewHighlighted];
    [cell.starView setStarImage:[UIImage imageNamed:@"small-star-hot.png"]
                       forState:kSCRatingViewHot];
    [cell.starView setStarImage:[UIImage imageNamed:@"small-star-highlighted.png"]
                       forState:kSCRatingViewNonSelected];
    [cell.starView setStarImage:[UIImage imageNamed:@"small-star-selected.png"]
                       forState:kSCRatingViewSelected];
    [cell.starView setStarImage:[UIImage imageNamed:@"small-star-hot.png"]
                       forState:kSCRatingViewUserSelected];
    
    
	if ([currentGame.iconMediaUrl length] > 0) {
		Media *iconMedia = [[Media alloc] initWithId:1 andUrlString:currentGame.iconMediaUrl ofType:@"Icon"];
		[cell.iconView loadImageFromMedia:iconMedia];
	}
	else cell.iconView.image = [UIImage imageNamed:@"Icon.png"];
    cell.iconView.layer.masksToBounds = YES;
    cell.iconView.layer.cornerRadius = 10.0;
    
    if (indexPath.row % 2 == 0){  
        cell.contentView.backgroundColor = [UIColor colorWithRed:233.0/255.0  
                                                           green:233.0/255.0  
                                                            blue:233.0/255.0  
                                                           alpha:1.0];  
    } else {  
        cell.contentView.backgroundColor = [UIColor colorWithRed:200.0/255.0  
                                                           green:200.0/255.0  
                                                            blue:200.0/255.0  
                                                           alpha:1.0];  
    } 
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //do select game notification;
    Game *selectedGame;
	selectedGame = [self.gameList objectAtIndex:indexPath.row];
	
	GameDetails *gameDetailsVC = [[GameDetails alloc]initWithNibName:@"GameDetails" bundle:nil];
	gameDetailsVC.game = selectedGame;
	[self.navigationController pushViewController:gameDetailsVC animated:YES];
	[gameDetailsVC release];	
    
}

- (void)tableView:(UITableView *)aTableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
	Game *selectedGame;
	selectedGame = [self.gameList objectAtIndex:indexPath.row];
	
	GameDetails *gameDetailsVC = [[GameDetails alloc]initWithNibName:@"GameDetails" bundle:nil];
	gameDetailsVC.game = selectedGame;
	[self.navigationController pushViewController:gameDetailsVC animated:YES];
	[gameDetailsVC release];	
}

-(CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60;
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark UISearchBarDelegate Methods

- (void)searchBar:(UISearchBar *)searchBar
    textDidChange:(NSString *)searchText {
    // We don't want to do anything until the user clicks 
    // the 'Search' button.
    // If you wanted to display results as the user types 
    // you would do that here.
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    // searchBarTextDidBeginEditing is called whenever 
    // focus is given to the UISearchBar
    // call our activate method so that we can do some 
    // additional things when the UISearchBar shows.
    [self searchBar:searchBar activate:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    // searchBarTextDidEndEditing is fired whenever the 
    // UISearchBar loses focus
    // We don't need to do anything here.
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    // Clear the search text
    // Deactivate the UISearchBar
    searchBar.text=@"";
    [self searchBar:searchBar activate:NO];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    // Do the search and show the results in tableview
    // Deactivate the UISearchBar
	
    // You'll probably want to do this on another thread
    // SomeService is just a dummy class representing some 
    // api that you are using to do the search
    self.searchText = searchBar.text;
	
    [self searchBar:searchBar activate:NO];
	[self refresh];
    }

// We call this when we want to activate/deactivate the UISearchBar
// Depending on active (YES/NO) we disable/enable selection and 
// scrolling on the UITableView
// Show/Hide the UISearchBar Cancel button
// Fade the screen In/Out with the disableViewOverlay and 
// simple Animations
- (void)searchBar:(UISearchBar *)searchBar activate:(BOOL) active{	
    self.gameTable.allowsSelection = !active;
    self.gameTable.scrollEnabled = !active;
    if (!active) {
        [disableViewOverlay removeFromSuperview];
        [searchBar resignFirstResponder];
    } else {
        self.disableViewOverlay.alpha = 0;
        [self.view addSubview:self.disableViewOverlay];
		
        [UIView beginAnimations:@"FadeIn" context:nil];
        [UIView setAnimationDuration:0.5];
        self.disableViewOverlay.alpha = 0.6;
        [UIView commitAnimations];
		
        // probably not needed if you have a details view since you 
        // will go there on selection
        NSIndexPath *selected = [self.gameTable 
                                 indexPathForSelectedRow];
        if (selected) {
            [self.gameTable deselectRowAtIndexPath:selected 
                                             animated:NO];
        }
    }
    [searchBar setShowsCancelButton:active animated:YES];
}




@end
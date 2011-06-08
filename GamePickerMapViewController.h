//
//  GamePickerMapViewController.h
//  ARIS
//
//  Created by David J Gagnon on 6/7/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppModel.h"
#import "Location.h"
#import <MapKit/MapKit.h>
#import "Annotation.h"

@interface GamePickerMapViewController : UIViewController<MKMapViewDelegate,UIActionSheetDelegate> {
    IBOutlet MKMapView *mapView;
	NSArray *locations;
	BOOL tracking;
	BOOL appSetNextRegionChange;
	IBOutlet UIBarButtonItem *mapTypeButton;
	IBOutlet UIBarButtonItem *playerTrackingButton;
	IBOutlet UIToolbar *toolBar;
	int silenceNextServerUpdateCount;
	int newItemsSinceLastView;
    
	NSTimer *refreshTimer;
    
}

-(void) refresh;
-(void) zoomAndCenterMap;
-(void) showLoadingIndicator;




@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) NSArray *locations;

@property BOOL tracking;


@property (nonatomic, retain) IBOutlet UIBarButtonItem *mapTypeButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *playerTrackingButton;
@property (nonatomic, retain) IBOutlet UIToolbar *toolBar;


@end
//
//  NoteEditorViewController.h
//  ARIS
//
//  Created by Brian Thiel on 8/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"

@protocol NoteEditorViewControllerDelegate
- (void) noteEditorViewControllerDidFinish;
@end
@interface NoteEditorViewController : UIViewController
- (id) initWithNote:(Note *)n inView:(NSString *)view delegate:(id<NoteEditorViewControllerDelegate>)d;
@end

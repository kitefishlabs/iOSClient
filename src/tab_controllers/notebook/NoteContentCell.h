//
//  NoteContentCell.h
//  ARIS
//
//  Created by Brian Thiel on 1/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NoteContentProtocol;
@class NoteContentCell;
@protocol NoteContentCellDelegate
- (void) cellStartedEditing:(NoteContentCell *)c;
- (void) cellFinishedEditing:(NoteContentCell *)c;
@end

@interface NoteContentCell : UITableViewCell
- (void) setupWithNoteContent:(id<NoteContentProtocol>)nc delegate:(id<NoteContentCellDelegate>)d;
@end

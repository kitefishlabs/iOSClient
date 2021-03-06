//
//  Player.m
//  ARIS
//
//  Created by David Gagnon on 5/30/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

//Additional Comment

#import "Player.h"
#import "NSDictionary+ValidParsers.h"

@implementation Player

@synthesize username;
@synthesize displayname;
@synthesize playerId;
@synthesize playerMediaId;
@synthesize groupname;
@synthesize groupGameId;
@synthesize location;
@synthesize hidden;

- (id) init
{
    if(self = [super init])
    {
        self.username      = @"Unknown Player";
        self.displayname   = @"Unknown Player";
        self.playerId      = 0;
        self.playerMediaId = 0;
        self.groupname     = @"";
        self.groupGameId   = 0;
    }
    return self;
}

- (id) initWithDictionary:(NSDictionary *)dict
{
    if(self = [super init])
    {
        self.username      = [dict validStringForKey:@"user_name"];
        self.displayname   = [dict validStringForKey:@"display_name"];
		self.playerId      = [dict validIntForKey:@"player_id"];
		self.playerMediaId = [dict validIntForKey:@"media_id"];
        self.groupname     = [dict validObjectForKey:@"group_name"];
		self.groupGameId   = [dict validIntForKey:@"group_game_id"];
        if([dict validObjectForKey:@"latitude"] && [dict validObjectForKey:@"longitude"])
            self.location = [[CLLocation alloc] initWithLatitude:[dict validFloatForKey:@"latitude"] longitude:[dict validFloatForKey:@"longitude"]];
    }
    return self;
}

- (GameObjectType) type
{
    return GameObjectPlayer;
}

- (int) compareTo:(Player *)ob
{
    return self.playerId == ob.playerId;
}

- (NSString *) name
{
    return self.displayname;
}

- (int) iconMediaId
{
    return 9;
}

- (GameObjectViewController *) viewControllerForDelegate:(id<GameObjectViewControllerDelegate>)d fromSource:(id)s
{
    return nil;
}

@end

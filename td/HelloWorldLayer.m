//
//  HelloWorldLayer.m
//  terrainDemo
//
//  Created by Lars Birkemose on 03/02/12.
//  Copyright Protec Electronics 2012. All rights reserved.
//
// ----------------------------------------------------------
// Import the interfaces

#import "HelloWorldLayer.h"

// ----------------------------------------------------------
// HelloWorldLayer implementation

@implementation HelloWorldLayer

// ----------------------------------------------------------

+( CCScene* )scene {
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	// add layer as a child to scene
	[scene addChild: layer];
	// return the scene
	return scene;
}

// ----------------------------------------------------------

-( id )init {
    CGPoint upperRight;
    
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	self = [ super init ];

    // reset stuff
    m_mode = USER_MODE_BALL;
    upperRight = ccp( [ [ CCDirector sharedDirector ] winSize].width, [ [ CCDirector sharedDirector ] winSize].height );
    
    // create world
    [ self addChild:WORLD ];
    		
    // buttons
    m_plus = [ CCSprite spriteWithFile:PLUS_FILE ];
    m_plus.position = ccpAdd( upperRight, PLUS_POSITION );
    m_plus.color = BUTTON_COLOR_OFF;
    [ self addChild:m_plus ];
    
    m_minus = [ CCSprite spriteWithFile:MINUS_FILE ];
    m_minus.position = ccpAdd( upperRight, MINUS_POSITION );
    m_minus.color = BUTTON_COLOR_OFF;
    [ self addChild:m_minus ];
    
	// initialize touch 
	[ [ CCTouchDispatcher sharedDispatcher ] addTargetedDelegate:self priority:0 swallowsTouches:YES ];

	// init animation
	[ self schedule:@selector( animate: ) ];	
	    
    // done
	return( self );
}

// ----------------------------------------------------------

-( void ) dealloc {
    // clean up

	
	// done
	[ super dealloc ];
}

// ----------------------------------------------------------
// scheduled animation

-( void )animate:( ccTime )dt {
    
    m_terrainTimer += dt;
    
    [ WORLD update:dt ];

}


// ----------------------------------------------------------

-( BOOL )ccTouchBegan:( UITouch* )touch withEvent:( UIEvent* )event {
	CGPoint pos;
	
	// get touch position and convert to screen coordinates
	pos = [ touch locationInView: [ touch view ] ];
	pos = [ [ CCDirector sharedDirector ] convertToGL:pos ];
        
    [ self ccTouchMoved:touch withEvent:event ];
    // done
    return( YES );
}

// ----------------------------------------------------------

-( void )ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
	CGPoint pos;
	
    if ( m_terrainTimer > EDIT_INTERVAL ) {
        m_terrainTimer = 0;
        
        // get touch position and convert to screen coordinates
        pos = [ touch locationInView: [ touch view ] ];
        pos = [ [ CCDirector sharedDirector ] convertToGL:pos ];
        
        if ( m_mode != USER_MODE_BALL ) {
            
            // no need to modify coordinates, as terrain fills entire screen
            if ( m_mode == USER_MODE_ADD ) [ WORLD.terrain add:pos withDiameter:EDIT_TERRAIN_SIZE ];
            if ( m_mode == USER_MODE_REMOVE ) [ WORLD.terrain remove:pos withDiameter:EDIT_TERRAIN_SIZE ];
            
        }
    }    
    
}

// ----------------------------------------------------------

-( void )ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
	CGPoint pos;
	
	// get touch position and convert to screen coordinates
	pos = [ touch locationInView: [ touch view ] ];
	pos = [ [ CCDirector sharedDirector ] convertToGL:pos ];
    
    if ( ccpDistance( pos, m_plus.position ) < BUTTON_DETECTION_RANGE ) {
        m_mode = USER_MODE_ADD;
        m_plus.color = BUTTON_COLOR_ON;
        m_minus.color = BUTTON_COLOR_OFF;
    } else if ( ccpDistance( pos, m_minus.position ) < BUTTON_DETECTION_RANGE ) {
        m_mode = USER_MODE_REMOVE;
        m_plus.color = BUTTON_COLOR_OFF;
        m_minus.color = BUTTON_COLOR_ON;    
    } else {
        if ( ( m_mode == USER_MODE_BALL ) && ( [WORLD.terrain pointInsideTerrain:pos ] == NO ) )
            [ WORLD addBall:pos ];
        m_mode = USER_MODE_BALL;
        m_plus.color = BUTTON_COLOR_OFF;
        m_minus.color = BUTTON_COLOR_OFF;    
    }

}




// ----------------------------------------------------------

@end























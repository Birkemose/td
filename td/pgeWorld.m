//
//  pgeWorld.m
//  terrainDemo
//
//  Created by Lars Birkemose on 03/02/12.
//  Copyright (c) 2012 Protec Electronics. All rights reserved.
//
// ----------------------------------------------------------
// import headers

#import "pgeWorld.h"

// ----------------------------------------------------------
// implementation

@implementation pgeWorld

// ----------------------------------------------------------
// properties

@synthesize space = m_space;
@synthesize terrain = m_terrain;

// ----------------------------------------------------------
// methods
// ----------------------------------------------------------

+( pgeWorld* )sharedWorld {
    // the instance of this class is stored here
    static pgeWorld* g_world = nil;
    // check to see if an instance already exists
    if ( g_world == nil ) {
        g_world = [ [ [ self class ] alloc ] init ];
	}
    // return the instance of this class
    return( g_world );
}

// ----------------------------------------------------------

-( pgeWorld* )init {
    self = [ super init ]; 
    // initialize
    m_ballList = [ [ NSMutableArray arrayWithCapacity:10 ] retain ];
    // create chipmunk space
    m_space = [ [ [ ChipmunkSpace alloc ] init ] retain ];
    m_space.gravity = CGPointMake( 0, WORLD_GRAVITY );
    m_space.damping = WORLD_DAMPING;
    m_space.iterations = 5;
    // create terrain
    m_terrain = [ pgeTerrain terrainWithSpace:m_space andImage:@"terraindemo.png" ];
    [ self addChild:m_terrain z:-1 ];
    // done
    return( self );
}

// ----------------------------------------------------------

-( void )dealloc {
    // clean up
    [ m_space release ];
    [ m_ballList release ];
    // done
    [ super dealloc ];
}

// ----------------------------------------------------------
// update the world

-( void )update:( ccTime )dt {
    ChipmunkShape* shape;
    
    // update physics
    [ m_space step:1.0f / GAME_FPS ];
    
    // remove balls fallen out
    // scan through balls
    for ( int index = m_ballList.count - 1; index >= 0; index -- ) {
        shape = [ m_ballList objectAtIndex:index ];
        if ( shape.body.pos.y < 0 ) {
            [ m_space removeBody:shape.body ];
            [ m_space removeShape:shape ];
            [ m_ballList removeObjectAtIndex:index ];
        }
    }
     
     
}

// ----------------------------------------------------------

-( void )draw {
    [ super draw ];
    //
#if GAME_DEBUG_DRAW == 1
    cpSegmentShape* segment;
    cpCircleShape* circle;
    
    // iterate
    for ( ChipmunkShape* shape in [ m_space shapes ] ) {
        switch ( shape.shape->klass_private->type ) {
            case CP_SEGMENT_SHAPE:
                // draw terrain segments
                glColor4f( 0, 1, 0, 1 );
                segment = ( cpSegmentShape* )shape.shape;
                ccDrawLine( segment->ta, segment->tb );
                break;
            case CP_CIRCLE_SHAPE:
                // draw circle
                glColor4f( 1, 1, 1, 1 );
                circle = ( cpCircleShape* )shape.shape;
                ccDrawCircle( circle->tc, circle->r, shape.body.angle, 32, YES );
                break;
            case CP_POLY_SHAPE:
                
                
                
                break;
            default:
                break;
                
        }
    }
#endif
}

// ----------------------------------------------------------

-( void )addBall:( CGPoint )pos {
    float mass = 20;
    float radius = 8;
    
    ChipmunkBody* body = [ [ ChipmunkBody alloc ] initWithMass:mass andMoment:cpMomentForCircle( mass, 0, radius, CGPointZero ) ];
    body.pos = pos;
    body.angle = M_PI;
    [ m_space addBody:body ];
    
    ChipmunkShape* shape = [ ChipmunkCircleShape circleWithBody:body radius:radius offset:CGPointZero ];
    shape.elasticity = 0.8f;
    shape.friction = 0.2f;
    [ m_space addShape:shape ];
    
    [ m_ballList addObject:shape ];

}

// ----------------------------------------------------------

@end
























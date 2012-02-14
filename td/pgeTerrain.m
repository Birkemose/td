//
//  pgeTerrain.m
//  terrainDemo
//
//  Created by Lars Birkemose on 03/02/12.
//  Copyright 2012 Protec Electronics. All rights reserved.
//
// ----------------------------------------------------------
// import headers

#import "pgeTerrain.h"

// ----------------------------------------------------------
// consts

// ----------------------------------------------------------
// implementation

@implementation pgeTerrain

// ----------------------------------------------------------
// properties

@synthesize size = m_size;

// ----------------------------------------------------------
// methods
// ----------------------------------------------------------

+( pgeTerrain* )terrainWithSpace:( ChipmunkSpace* )space andImage:( NSString* )filename {
    return( [ [ [ self alloc ] initWithSpace:space andImage:filename ] autorelease ] );
}

// ----------------------------------------------------------

-( pgeTerrain* )initWithSpace:( ChipmunkSpace* )space andImage:( NSString* )filename {
    // super
    self = [ super init ];
    
    // initialize
    m_space = space;
    
    // load the image
    // the image must be 8 bit grayscale format ( otherwise it looks like taking acid )
    // note:
    // chipmunk will smoothen the terrain based on blur, so if your terrain looks jagged, blur it a bit
	CGImageRef image = [ UIImage imageNamed:filename ].CGImage;
    CFDataRef data = CGDataProviderCopyData( CGImageGetDataProvider( image ) );

    // get size of terrain image
    m_size = CGSizeMake( CGImageGetWidth( image ), CGImageGetHeight( image ) );

    // Tell Quartz to use grayscale on the image
    // this means that only one byte is used for each pixel ( blitz fast )
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray( );
    
    // create chipmunk terrain sampler, based on a CGBitmapContext
    m_sampler = [ [ [ ChipmunkCGContextSampler alloc ] initWithWidth:m_size.width 
                                                              height:m_size.height 
                                                          colorSpace:colorSpace
                                                          bitmapInfo:kCGImageAlphaNone 
                                                           component:0 ] retain ];
    // release the colorspace
    CGColorSpaceRelease( colorSpace );
    
    // copy the image data to the bitmat context to initialize it with initial terrain 
    memcpy( CGBitmapContextGetData( m_sampler.context ), CFDataGetBytePtr( data ), m_size.width * m_size.height );

    // calculate the range of the generated geometry
    // in this demo I use a 240 * 160 image to generate the terrain
    // I then scale it by 2 ( TERRAIN_PIXEL_SIZE ) to match the screen of the iPhone
    m_winSize = CGSizeMake( m_size.width * TERRAIN_PIXEL_SIZE, m_size.height * TERRAIN_PIXEL_SIZE );

    // add a border to the terrain if needed
    // if you got the offset below right, this shold be fully visible, and drawn along edges
    [ m_sampler setBorderValue:TERRAIN_PIXEL_SIZE ];
       
    // set sampler output range
    // this defines what the output range of the generated chipmunk geometry is, and is the range within the tilecache works
    // in this example, terrain and output ( screen ) is scaled excactely 1:2 
    // because we offset the cache half a pixel to sample in pixel center, we need to offset the output accordingly
    // note:
    // in theory you can scale terrain image and output to anything you want
    // but if you want to keep terrain image as small as possible, and maybe even go 1:4 to save time, use the offset for better results
    m_sampler.outputRect = cpBBNew( TERRAIN_PIXEL_SIZE / 2, TERRAIN_PIXEL_SIZE / 2, m_winSize.width - ( TERRAIN_PIXEL_SIZE / 2 ), m_winSize.height - ( TERRAIN_PIXEL_SIZE / 2 ) );

    // create tile cache
    // tileSize finetunes the performance. 128'ish seems to be a magic number ( high five to 128 )
    // samplesPerTile indicates many samples will be taken across a tile, the more the better the resolution
    //   the formula shown optimizes so that samples fits the pixels of the terrain image
    // cacheSize is irelleval on non scrolling terrains, and shold only be large enough to hold whats on the screen
    m_cache = [ [ [ ChipmunkBasicTileCache alloc ] initWithSampler:m_sampler 
                                                             space:m_space 
                                                          tileSize:TERRAIN_TILE_SIZE 
                                                    samplesPerTile:1 + ( TERRAIN_TILE_SIZE / TERRAIN_PIXEL_SIZE ) 
                                                         cacheSize:512 ] retain ];
 
    // offset the tile cache to sample in pixel center
    m_cache.tileOffset = cpv( -TERRAIN_PIXEL_SIZE / 2, -TERRAIN_PIXEL_SIZE / 2 ); 
    
    // set the transformation matrix of the context, to match the output
    // this means that coordinates of outut and terrain bitmap are the same
    // as out output matches the screen, we need not to worry about screen to image transformations
    CGContextConcatCTM( m_sampler.context, CGAffineTransformMake( 1.0f / TERRAIN_PIXEL_SIZE, 0, 0, 1.0f  /TERRAIN_PIXEL_SIZE, 0, 0 ) );

    // finally define some characteristics on the segments created
    m_cache.segmentRadius = TERRAIN_THICKNESS;
    m_cache.simplifyThreshold = TERRAIN_GEOMETRY_REDUCTION;
     
    // done
    return( self );
}

// ----------------------------------------------------------

-( void )dealloc {
    // clean up
    [ m_cache release ];
    [ m_sampler release ];
    // done
    [ super dealloc ];
}

// ----------------------------------------------------------

-( void )draw {    
    // before drawing the terrain, ensure that the rect we are drawing, has been updated with geometry
    // if there is anything going on outside the screen, which should be updated, this rect should be expanded to include it
    // as this demo fixes the terrain to the screen, we just update the screen rect
    [ m_cache ensureRect:cpBBNew( 0, 0, m_winSize.width, m_winSize.height ) ];
    
    // then all the rest
    [ super draw ]; 
}

// ----------------------------------------------------------
// returns is any given point is inside the terrain 
// I have been unable to find any CGContextReadPixel that would support transformations, so lets do it manually

-( BOOL )pointInsideTerrain:( CGPoint )pos {
    int pointer;
    unsigned char* data;
    
    // transform output ( in this example == screen ) to image coordinates
    pos = ccp( pos.x * m_size.width / m_winSize.width, m_size.height - ( pos.y * m_size.height / m_winSize.height ) );
    
    // get an ffset into image data ( 1 byte greyscale )
    pointer = ( int )pos.x + ( ( int )pos.y * m_size.width );
    
    // get a pointer to all the lovely data
    data = ( unsigned char* )[ m_sampler.pixelData bytes ];
    
    // check if pixel is terrain
    return( IS_TERRAIN( data[ pointer ] ) );
}

// ----------------------------------------------------------
// note that there is not need to worry about coordinates, as we set the transformation matrix earlier
// is that KEWL or wot?

// G O D !, I LOVE iPhone programming ...

-( void )add:( CGPoint )pos withDiameter:( float )diameter {
    float radius = diameter / 2;
    
    // draw a black cicel to add terrain
    CGContextSetGrayFillColor( m_sampler.context, 0.0, 1.0 );
    CGContextFillEllipseInRect( m_sampler.context, CGRectMake( pos.x - radius / 2, pos.y - radius / 2, diameter, diameter ) );

    // mark a slightly larger rect as dirty, to make sure some rounding doesnt ruin terrain
    [ m_cache markDirtyRect:cpBBNew( pos.x - radius - 1, pos.y - radius - 1, pos.x + radius + 1, pos.y + radius + 1 ) ];

}

// ----------------------------------------------------------

-( void )remove:(CGPoint)pos withDiameter:( float )diameter {
    float radius = diameter / 2;

    // draw a white cicel to remove terrain
    CGContextSetGrayFillColor( m_sampler.context, 1.0, 1.0 );
    CGContextFillEllipseInRect( m_sampler.context, CGRectMake( pos.x - radius / 2, pos.y - radius / 2, diameter, diameter ) );
    
    // mark a slightly larger rect as dirty, to make sure some rounding doesnt ruin terrain
    [ m_cache markDirtyRect:cpBBNew( pos.x - radius - 1, pos.y - radius - 1, pos.x + radius + 1, pos.y + radius + 1 ) ];

}

// ----------------------------------------------------------

@end


























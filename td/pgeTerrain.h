//
//  pgeTerrain.h
//  terrainDemo
//
//  Created by Lars Birkemose on 03/02/12.
//  Copyright 2012 Protec Electronics. All rights reserved.
//
// ----------------------------------------------------------
// import headers

#import "GameConfig.h"
#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "ObjectiveChipmunk.h"
#import "ChipmunkImageSampler.h"

// ----------------------------------------------------------
// defines

#define TERRAIN_TILE_SIZE               64                 // a good number to use
#define TERRAIN_PIXEL_SIZE              2                   // scale from terrain image to output

#define TERRAIN_THICKNESS               1.0f                // thickness of terrain segments
#define TERRAIN_GEOMETRY_REDUCTION      1.5f                // geometry reduction ( for smoother output )

#define IS_TERRAIN( color )             ( color < 128 )     // dark is terrain

// ----------------------------------------------------------
// typedefs

// ----------------------------------------------------------
// interface

@interface pgeTerrain : CCNode {
    ChipmunkSpace*                  m_space;                // the chipmunk space
    ChipmunkCGContextSampler*       m_sampler;              // image sampler
    ChipmunkBasicTileCache*         m_cache;                // terrain cache 
    CGSize                          m_size;                 // size of terrain image 
    CGSize                          m_winSize;              // window size
		CCTexture2D*                      m_texture;
}

// ----------------------------------------------------------
// properties

@property ( readonly ) CGSize size;

// ----------------------------------------------------------
// methods

+( pgeTerrain* )terrainWithSpace:( ChipmunkSpace* )space andImage:( NSString* )filename;
-( pgeTerrain* )initWithSpace:( ChipmunkSpace* )space andImage:( NSString* )filename;

-( BOOL )pointInsideTerrain:( CGPoint )pos;

-( void )add:( CGPoint )pos withDiameter:( float )diameter;
-( void )remove:( CGPoint )pos withDiameter:( float )diameter;

// ----------------------------------------------------------

@end

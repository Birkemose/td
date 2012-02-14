#import "ObjectiveChipmunk.h"

#import "cpMarch.h"
#import "cpPolyline.h"

/// Wrapper for the cpPolyline type.
@interface ChipmunkPolyline : NSObject {
@private
	cpPolyline _line;
	cpFloat _area;
}

-(id)initWithPolyline:(cpPolyline)line;
+(ChipmunkPolyline *)fromPolyline:(cpPolyline)line;

/// Returns true if the first and last vertex are equal.
@property(readonly) bool isLooped;

/// Returns the signed area of the polyline calculated by cpAreaForPoly.
/// Non-looped polylines return an area of 0.
@property(readonly) cpFloat area;

/// Centroid of the polyline calculated by cpCentroidForPoly.
/// It is an error to call this on a non-looped polyline.
@property(readonly) cpVect centroid;

/// Calculates the moment of inertia for a looped polyline with the given mass and offset.
-(cpFloat)momentForMass:(cpFloat)mass offset:(cpVect)offset;


/// Vertex count.
@property(readonly) NSUInteger count;

/// Array of vertexes.
@property(readonly) const cpVect *verts;

/**
	Returns a copy of a polyline simplified by using the Douglas-Peucker algorithm.
	This works very well on smooth or gently curved shapes, but not well on straight edged or angular shapes.
*/
-(ChipmunkPolyline *)simplifyCurves:(cpFloat)tolerance;

/**
	Returns a copy of a polyline simplified by discarding "flat" vertexes.
	This works well on straigt edged or angular shapes, not as well on smooth shapes.
*/
-(ChipmunkPolyline *)simplifyVertexes:(cpFloat)tolerance;

// Generate a convex hull that contains a polyline. (looped or not)
-(ChipmunkPolyline *)toConvexHull;

/// Create an array of segments for each segment in this polyline.
-(NSArray *)asChipmunkSegmentsWithBody:(ChipmunkBody *)body radius:(cpFloat)radius offset:(cpVect)offset;

/// Create a ChipmunkPolyShape from this polyline. (Must be convex!)
-(ChipmunkPolyShape *)asChipmunkPolyShapeWithBody:(ChipmunkBody *)body offset:(cpVect)offset;

@end


/// Wrapper for the cpPolylineSet type.
@interface ChipmunkPolylineSet : NSObject<NSFastEnumeration> {
@private
	NSMutableArray *_lines;
}

-(id)initWithPolylineSet:(cpPolylineSet *)set;
+(ChipmunkPolylineSet *)fromPolylineSet:(cpPolylineSet *)set;

@property(readonly) NSUInteger count;

-(ChipmunkPolyline *)lineAtIndex:(NSUInteger)index;

@end


/**
	A sampler is an object that provides a basis function to build shapes from.
	This can be from a block of pixel data (loaded from a file, or dumped from the screen), or even a mathematical function such as Perlin noise.
*/
@interface ChipmunkAbstractSampler : NSObject {
@protected
	cpMarchSampleFunc _sampleFunc;
}

/// Get the primitive cpMarchSampleFunc used by this sampler.
@property(readonly) cpMarchSampleFunc sampleFunc;

/// Designated initializer.
-(id)initWithSamplingFunction:(cpMarchSampleFunc)sampleFunc;

/// Sample at a specific point.
-(cpFloat)sample:(cpVect)pos;

/// March a certain area of the sampler.
-(ChipmunkPolylineSet *)march:(cpBB)bb xSamples:(NSUInteger)xSamples ySamples:(NSUInteger)ySamples hard:(bool)hard;

@end



/// A simple sampler type that wraps a block as it's sampling function.
typedef cpFloat (^ChipmunkMarchSampleBlock)(cpVect point);

@interface ChipmunkBlockSampler : ChipmunkAbstractSampler {
	ChipmunkMarchSampleBlock _block;
}

/// Initializes the sampler using a copy of the passed block.
-(id)initWithBlock:(ChipmunkMarchSampleBlock)block;
+(ChipmunkBlockSampler *)samplerWithBlock:(ChipmunkMarchSampleBlock)block;

@end



#import "ChipmunkImageSampler.h"
#import "ChipmunkPointCloudSampler.h"
#import "ChipmunkTileCache.h"
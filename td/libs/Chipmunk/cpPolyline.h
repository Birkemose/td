// Polylines are just arrays of vertexes.
// They are looped if the first vertex is equal to the last.
// cpPolyline structs are intended to be passed by value and destroyed when you are done with them.
typedef struct cpPolyline {
  int count, capacity;
  cpVect *verts;
} cpPolyline;

/// Destroy a polyline instance.
void cpPolylineDestroy(cpPolyline line);

// Returns true if the first vertex is equal to the last.
cpBool cpPolylineIsLooped(cpPolyline line);

/**
	Returns a copy of a polyline simplified by using the Douglas-Peucker algorithm.
	This works very well on smooth or gently curved shapes, but not well on straight edged or angular shapes.
*/
cpPolyline cpPolylineSimplifyCurves(cpPolyline line, cpFloat tol);

/**
	Returns a copy of a polyline simplified by discarding "flat" vertexes.
	This works well on straigt edged or angular shapes, not as well on smooth shapes.
*/
cpPolyline cpPolylineSimplifyVertexes(cpPolyline line, cpFloat tol);

// Generate a convex hull that contains a polyline. (looped or not)
cpPolyline cpPolylineToConvexHull(cpPolyline line);


/// Polyline sets are collections of polylines, generally built by cpMarchSoft() or cpMarchHard().
typedef struct cpPolylineSet {
  int count, capacity;
  cpPolyline *lines;
} cpPolylineSet;

/// Allocate a new polyline set.
cpPolylineSet *cpPolylineSetAlloc(void);

/// Initialize a new polyline set.
cpPolylineSet *cpPolylineSetInit(cpPolylineSet *set);

/// Allocate and initialize a polyline set.
cpPolylineSet *cpPolylineSetNew(void);

/// Destroy a polyline set.
void cpPolylineSetDestroy(cpPolylineSet *set, cpBool freePolylines);

/// Destroy and free a polyline set.
void cpPolylineSetFree(cpPolylineSet *set, cpBool freePolylines);

/**
	Add a line segment to a polyline set.
	A segment will either start a new polyline, join two others, or add to or loop an existing polyline.
	This is mostly intended to be used as a callback directly from cpMarchSoft() or cpMarchHard().
*/
void cpPolylineSetCollectSegment(cpVect v0, cpVect v1, cpPolylineSet *lines);

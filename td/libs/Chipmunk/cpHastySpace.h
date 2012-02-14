/// cpHastySpace is exclusive to Chipmunk Pro
/// Currently it enables ARM NEON optimizations in the solver, but in the future will include other optimizations such as
/// a multi-threaded solver and multi-threaded collision broadphases.
typedef struct cpHastySpace {
	cpSpace space;
} cpHastySpace;

/// Create a new hasty space.
cpSpace *cpHastySpaceNew(void);

/// When stepping a hasty space, you must use this function.
void cpHastySpaceStep(cpSpace *space, cpFloat dt);

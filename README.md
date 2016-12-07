# Carnivores simulation

A friend and I were curious about the order of the shapes in the "Circle of
Life" in the game [Carnivore](https://boardgamegeek.com/boardgame/184730/carnivores).  We
postulated that the order had something to do with the "ease" of making each
shape, which might have something to do with the probability that it would
arise by chance.

I ran some simulations using [Julia](http://julialang.org/) to check if this

### Simulation 1: 4 stones on a small board (radius 3)

## Simulations

### Classifying shapes

- Singletons and doubletons are specified just by size
- 3-hexes all have unique moments of inertia
- Almost all 4-hexes have unique moments of inertia. The long wave and long bar have the same moment, but their inertial matrices have different eigenvalues.

The results are below. ("Circle position" counts in the reverse order of the
arrows, so the singleton is #1 and the tall staff is #12.) Notably, some shapes
are out of order. It looks like the second two size-3 shapes (short staff and triangle)
should be reversed, and it looks like the four of the first three size-4 shapes are out of order.
The size-4's should go:

- worm (current first size-4)
- rhombus (currently third)
- arch (currently fourth)
- hockey stick (currently second)

## To do

- Implement periodic boundary conditions
- Re-implement with 3 stones
- Use more stones (10-20, but requiring that there are no 5-shapes)
- Simulate interacting stones
- General: how do player choice and "ease" of creation interact?
- General: how about "sequential" constructions? e.g., what if it's easier to make one third shape than another when coming from different 2-shapes?

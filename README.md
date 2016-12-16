# Carnivores simulation

The order of the shapes in the "Circle of Life" in the game
[Carnivores](https://boardgamegeek.com/boardgame/184730/carnivores)

## Terminology

Multiple hexes form a polyhex (or "shape"). There is one 1-hex, one 2-hex,
three 3-hexes, and seven 4-hexes.

In the (reverse) order of the Circle of Life, I call them:

- singleton
- doubleton
- short wave
- short bar
- triangle
- pistol
- wave
- worm
- bee
- arch
- propeller
- long wave

The names of the 4-hexes follow
[MathWorld's](http://mathworld.wolfram.com/Polyhex.html) naming scheme.

## Simulations

These simulations are run with [Julia](http://julialang.org).

### Working with hexes

I've relied heavily on this [outstanding post](http://www.redblobgames.com/grids/hexagons) by Amit Patel.

### Classifying shapes

- Singletons and doubletons are specified just by size.
- 3- and 4-hexes all have unique [moments of inertia](https://en.wikipedia.org/wiki/Moment_of_inertia) (about their center of mass perpendicular to the plane of the board).

## To do

- Migrate to a module and separate code
- Implement periodic boundary conditions?
- Use more stones (10-20, but requiring that there are no 5-shapes)
- Simulate interacting stones
- General: how do player choice and "ease" of creation interact?
- General: how about "sequential" constructions? e.g., what if it's easier to make one third shape than another when coming from different 2-shapes?

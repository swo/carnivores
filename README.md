# Carnivores simulation

A friend and I were curious about the order of the shapes in the "Circle of
Life" in the game [Carnivore](https://boardgamegeek.com/boardgame/184730/carnivores).  We
postulated that the order had something to do with the "ease" of making each
shape, which might have something to do with the probability that it would
arise by chance.

## Results

### Simulation 1: 4 stones on a small board (radius 3)

I ran some simulations using [Julia](http://julialang.org/) to check if this
were the case. In each simulation, I would:

- Set out a hexagonal grid of "radius" 3 (i.e., from the center tile, you can go three tiles in any of the 6 directions)
- Pick four of those tiles at random (without replacement)
- Separate the tiles into contiguous groups
- Evaluate the size and moment of inertia of each group

It turns out that each shape in the Circle has a unique moment of inertia,
which made it convenient to classify each shape.

The results are below. ("Circle position" counts in the reverse order of the
arrows, so the singleton is #1 and the tall staff is #12.) Notably, some shapes
are out of order. It looks like the second two size-3 shapes (short staff and triangle)
should be reversed, and it looks like the four of the first three size-4 shapes are out of order.
The size-4's should go:

- worm (current first size-4)
- rhombus (currently third)
- arch (currently fourth)
- hockey stick (currently second)

| Circle position | # appearances | Size | MOI  |
|-----------------|---------------|------|------|
| 1               | 25,968,845    | 1    | 0.0  |
| 2               | 5,669,059     | 2    | 0.5  |
| 3               | 398,327       | 3    | 2.1  |
| 4               | 190,875       | 3    | 2.0  |
| 5               | 229,673       | 3    | 1.3  |
| 6               | 22,243        | 4    | 3.2  |
| 7               | 7,818         | 4    | 5.0  |
| 8               | 10,679        | 4    | 5.3  |
| 9               | 9,015         | 4    | 2.5  |
| 10              | 6,420         | 4    | 4.2  |
| 11              | 2,928         | 4    | 3.0  |
| 12              | 0             | 4    | 10.0 |

## My names for shapes

1. Singleton
2. Doubleton
3. Telephone
4. Short staff
5. Triangle
6. Gun
7. Worm
8. Hockey stick
9. Rhombus
10. Arch
11. Helicopter
12. Long staff

## To do

- Implement periodic boundary conditions
- Re-implement with 3 stones
- Use more stones (10-20, but requiring that there are no 5-shapes)
- Simulate interacting stones
- General: how do player choice and "ease" of creation interact?
- General: how about "sequential" constructions? e.g., what if it's easier to make one third shape than another when coming from different 2-shapes?

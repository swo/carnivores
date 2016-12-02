# Carnivores simulation

A friend and I were curious about the order of the shapes in the "Circle of
Life" in the game [Carnivore](https://boardgamegeek.com/boardgame/184730/carnivores).  We
postulated that the order had something to do with the "ease" of making each
shape, which might have something to do with the probability that it would
arise by chance.

I ran some simulations using [Julia](http://julialang.org/) to check if this
were the case. In each simulation, I would:

- Set out a hexagonal grid of "radius" 3 (i.e., from the center tile, you can go three tiles in any of the 6 directions)
- Pick four of those tiles at random (without replacement)
- Separate the tiles into contiguous groups
- Evaluate the size and moment of inertia of each group

It turns out that each shape in the Circle has a unique moment of inertia,
which made it convenient to classify each shape.

The results are below. ("Circle position" counts in the reverse order of the
arrows, so the singleton is #1 and the straight-4 is #12.) Notably, some shapes
are out of order. It looks like the second two size-3 shapes (straight-3 and triangle)
should be reversed, and it looks like the four of the first three size-4 shapes are out of order.
The size-4's should go:

- worm (current first size-4)
- rhombus (currently third)
- C (currently fourth)
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

Of course, it could be that the shapes are based on some combination of energy
*and* entropy (i.e., the hexes are repulsive). For example, even though the
size-3 triangle is more entropically favorable than the straight-3, it has more
edges that are adjacent to other edges.

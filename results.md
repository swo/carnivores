# Simulation 1: 4 tiles on a small board

## Methods

- Set out a hexagonal grid of "radius" 4 (i.e., from the center tile, you can go 3 tiles in any of the 6 directions)
- Pick four of those tiles at random (without replacement)
- Separate the tiles into contiguous groups
- Evaluate the size and moment of inertia of each group
- Repeat 10 million times

## Results

| Shape      | Counts   |
|------------|----------|
| singleton  | 30654116 |
| doubleton  | 4117885  |
| short wave | 171730   |
| triangle   | 95128    |
| short bar  | 83924    |
| pistol     | 5355     |
| worm       | 2683     |
| bee        | 2123     |
| arch       | 1519     |
| long wave  | 1391     |
| propeller  | 699      |
| long bar   | 672      |

## Conclusions

The order of the polyhexes in the Circle of Life mostly matches the order of
their relative frequencies with two exceptions:

- In the Circle, the second two 3-hexes are the short bar and triangle. In the simulation, the two are reversed.
- In the Circle, the long wave is third 4-hex. In the simulation, it is the fifth.

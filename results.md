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

The difference between the last two is within the margin of error. (For a
multinomial distribution, the variance for the counts in a category is similar
to the number of counts in that category if the category is rare. Thus, the
standard deviation for the long bar is around 25.)

## Conclusions

The order of the polyhexes in the Circle of Life mostly matches the order of
their relative frequencies with two exceptions:

- In the Circle, the second two 3-hexes are the short bar and triangle. In the simulation, the two are reversed.
- In the Circle, the long wave is third 4-hex. In the simulation, it is the fifth.

# Simulation 2: 3 tiles on a small board

## Methods

The setup is as above, but with 3 tiles rather than 4.

## Results

| Shape      | Counts   |
|------------|----------|
| singleton  | 22473282 |
| doubleton  | 3385782  |
| short wave | 123461   |
| triangle   | 69374    |
| short bar  | 58883    |

## Conclusions

The order of the 3-hexes is the same as predicted by the previous simulation.

# Simulation 3: 3 tiles on a varying board

## Methods

The setup is as above, but I varied the board radius from 1 up to 9.

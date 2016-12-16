#!/usr/bin/env julia

import Base.+, Base.-, Base.*
import StatsBase.sample, StatsBase.sample!
using Iterators

# Store cubic coordinates for each hex
immutable Hex
    x::Int
    y::Int
end

# Allow a cubic construction
Hex(x, y, z) = if (x + y + z == 0) Hex(x, y) else error("cubic coordinates do not sum to 0") end

# Define basic algeraic relationship for Hex objects
+(a::Hex, b::Hex) = Hex(a.x + b.x, a.y + b.y)
*(a::Int, h::Hex) = Hex(a * h.x, a * h.y)
-(a::Hex, b::Hex) = Hex(a.x - b.x, a.y - b.y)

"""
Convert a Hex object into a Cartesian (x, y) pair
"""
hex2cartesian(h::Hex)::Array{Float64} = [h.x + 0.5 * h.y, sqrt(3)/2 * h.y]

"""
Classify a polyhex (of size 1 to 4). The names used are:
 - For size 1, singleton
 - For size 2, doubleton
 - For size 3, triangle, short wave, and short bar
 - For size 4, as per MathWorld (http://mathworld.wolfram.com/Polyhex.html) but with
    "long" prefixed to worm and wave

`idx` is the indices of the selected tiles among an array
`grid` of hexes.
"""
function classify_polyhex(idx, grid)::String
    # some can be classified just by the size of the polyhex
    if length(idx) == 1
        return "singleton"
    elseif length(idx) == 2
        return "doubleton"
    else
        # larger ones can be distinguished by moment of inertia
        m = round(moi(idx, grid), 2)
        if length(idx) == 3
            if m == 1.67
                return "short wave"
            elseif m == 2.0
                return "short bar"
            elseif m == 1.0
                return "triangle"
            end
        elseif length(idx) == 4
            if m == 2.75
                return "pistol"
            elseif m == 4.0
                return "long wave"
            elseif m == 4.25
                return "worm"
            elseif m == 2.0
                return "bee"
            elseif m == 3.25
                return "arch"
            elseif m == 3.0
                return "propeller"
            elseif m == 5.0
                return "long bar"
            end
        end
    end
    error("unrecognized shape of size $(length(idx)) with MOI $(moi(idx, grid))")
end


"""
Distance between two hexes
"""
dist(a::Hex, b::Hex)::Int = (abs(a.x - b.x) + abs(a.x + a.y - b.x - b.y) + abs(a.y - b.y)) / 2

"""
Center of mass of an array of hexes. Or, given the indices `idx` of the
selected tiles from a `grid`, compute the center of mass.
"""
com(hs)::Array{Float64} = hex2cartesian(sum(hs)) / convert(Float64, length(hs))
function com(idx::Array{Int}, grid::Array{Hex})::Array{Float64}
    c = zeros(Float64, 2)
    for i = idx
        c += hex2cartesian(grid[i])
    end
    c /= convert(Float64, length(idx))
    c
end

"""
Moment of intertia of an array of hexes. Or, given the indices `idx` of the
selected tiles from a grid, compute the moment of inertia.
"""
moi(hs)::Float64 = sum([norm(com(hs) - hex2cartesian(h)) ^ 2 for h in hs])
function moi(idx, grid)::Float64
    c = com(idx, grid)
    d = 0
    for i = idx
        d += norm(c - hex2cartesian(grid[i])) ^ 2
    end
    d
end

"""
Return the names of the polyhexes in the Circle of Life. Use this as a verification
of the names and classifications.
"""
function circleoflife()::Array{String}
    shapes = [ # 1-hex shapes
              [Hex(0, 0, 0)],
              # 2-hex
              [Hex(0, 0, 0), Hex(1, 0, -1)],
              # 3-hexes
              [Hex(0, 0, 0), Hex(1, 0, -1), Hex(2, -1, -1)],
              [Hex(0, 0, 0), Hex(1, 0, -1), Hex(2, 0, -2)],
              [Hex(0, 0, 0), Hex(-1, 0, 1), Hex(0, -1, 1)],
              # 4-hexes
              [Hex(0, 0, 0), Hex(1, 0, -1), Hex(2, 0, -2), Hex(1, 1, -2)],
              [Hex(0, 0, 0), Hex(1, 0, -1), Hex(2, -1, -1), Hex(3, -1, -2)],
              [Hex(0, 0, 0), Hex(1, 0, -1), Hex(2, 0, -2), Hex(3, -1, -2)],
              [Hex(0, 0, 0), Hex(1, 0, -1), Hex(1, -1, 0), Hex(2, -1, -1)],
              [Hex(0, 0, 0), Hex(1, 0, -1), Hex(1, 1, -2), Hex(0, 2, -2)],
              [Hex(0, 0, 0), Hex(1, 0, -1), Hex(-1, 1, 0), Hex(0, -1, 1)],
              [Hex(0, 0, 0), Hex(1, 0, -1), Hex(2, 0, -2), Hex(3, 0, -3)]]

    [classify_polyhex(shape) for shape in shapes]
end

"""
Return a grid of hexes of a certain radius. The radius is the number of hexes
beyond the center one (i.e., a one-hex grid has radius 0; radius 1 means 7 hexes,
etc.).
"""
function grid(radius::Int)::Array{Hex, 1}
    [Hex(x, y, -x - y) for x in -radius:radius for y in max(-radius, -x - radius):min(radius, radius - x)]
end

"""
Return a 2D array of true/false values such that [i, j] is true only if the hexes
at indices i and j in the grid are adjacent (distance 1).
"""
function adjacencymatrix(grid::Array{Hex, 1})::BitArray{2}
    n = length(grid)
    adj = falses(n, n)
    for i in 1:(n - 1)
        for j in (i + 1):n
            if dist(grid[i], grid[j]) == 1
                adj[i, j] = true
                adj[j, i] = true
            end
        end
    end
    adj
end

"""
Assign values (in place) to groups array based on an adjacency matrix and a list
of the indices (with respect to that matrix) of the tiles in question.
"""
function assigngroups!(groups::Array{Int}, adjacent::BitArray{2}, idx::Array{Int})
    # initialize each tile in its own group
    if length(idx) != length(groups) error("bad length") end

    for i = eachindex(groups)
        groups[i] = i
    end

    for i in 1:(length(idx) - 1)
        for j in (i + 1):length(idx)
            if adjacent[idx[i], idx[j]] && groups[i] != groups[j]
                # change of all of j's group to i's group
                for k = eachindex(groups)
                    if groups[k] == groups[j]
                        groups[k] = groups[i]
                    end
                end
            end
        end
    end
    nothing
end

function simulate(n_trials, n_tiles, radius)
    gr = grid(radius)
    grid_size = length(gr)
    aj = adjacencymatrix(gr)

    dat = Dict{String, Int}()
    idx = zeros(Int, n_tiles)
    groups = zeros(Int, n_tiles)

    for k = circleoflife()
        dat[k] = 0
    end

    for trial_i = 1:n_trials
        sample!(1:grid_size, idx, replace=false)
        assigngroups!(groups, aj, idx)

        for g = distinct(groups)
            # indices (with respect to the grid) of tiles in group g
            dat[classify_polyhex(idx[find(x -> x == g, groups)], gr)] += 1
        end
    end
    dat
end

"""
Run a simulation and report the results.
"""
function report(n_trials, n_tiles, radius)
    # generate the data
    dat = simulate(n_trials, n_tiles, radius)

    for name in sort(collect(keys(dat)), by=x -> dat[x], rev=true)
        counts = dat[name]
        println(name, "\t", counts, "\t")
    end
end

"""
Count the appearance of each shape for every way of drawing n_tiles from a
grid of radius. (Like the simulate function, but it's deterministic.)
"""
function deterministic(n_tiles, radius)
    gr = grid(radius)
    grid_size = length(gr)
    aj = adjacencymatrix(gr)

    dat = Dict{String, Int}()
    groups = zeros(Int, n_tiles)

    for k = circleoflife()
        dat[k] = 0
    end

    for idx = subsets(Array(1:grid_size), n_tiles)
        assigngroups!(groups, aj, idx)

        for g = distinct(groups)
            dat[classify_polyhex(idx[find(x -> x == g, groups)], gr)] += 1
        end
    end

    dat
end

#=
For radii 1 to 7, find all ways to draw 3 hexes from the grid, and count the shapes.
=#
n_tiles = 3
println("radius\tshape\tcounts")
for radius in 1:7
    dat = deterministic(n_tiles, radius)
    for shape in ["singleton", "doubleton", "short wave", "short bar", "triangle"]
        println(radius, "\t", shape, "\t", dat[shape])
    end
end

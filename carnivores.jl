#!/usr/bin/env julia

import Base.+, Base.-, Base.*#, Base.convert
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

hex2cartesian(h::Hex)::Array{Float64} = [h.x + 0.5 * h.y, sqrt(3)/2 * h.y]

"""
Classify a polyhex (of size 1 to 4). The names used are:
 - For size 1, singleton
 - For size 2, doubleton
 - For size 3, triangle, short wave, and short bar
 - For size 4, as per MathWorld (http://mathworld.wolfram.com/Polyhex.html) but with
    "long" prefixed to worm and wave
"""
function classify_polyhex(hs)::String
    # some can be classified just by the size of the polyhex
    if length(hs) == 1
        return "singleton"
    elseif length(hs) == 2
        return "doubleton"
    else
        # larger ones can be distinguished by moment of inertia
        m = round(moi(hs), 2)
        if length(hs) == 3
            if m == 1.67
                return "short wave"
            elseif m == 2.0
                return "short bar"
            elseif m == 1.0
                return "triangle"
            end
        elseif length(hs) == 4
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
    error("unrecognized shape of size $(length(hs)) with MOI $(moi(hs)), rounded to $(round(moi(hs), 2))")
end

"""
Distance between two hexes
"""
dist(a::Hex, b::Hex)::Int = (abs(a.x - b.x) + abs(a.x + a.y - b.x - b.y) + abs(a.y - b.y)) / 2

"""
Center of mass of an array of hexes
"""
com(hs)::Array{Float64} = hex2cartesian(sum(hs)) / convert(Float64, length(hs))

"""
Moment of intertia of an array of hexes
"""
moi(hs)::Float64 = sum([norm(com(hs) - hex2cartesian(h)) ^ 2 for h in hs])

"""
Actually do the sampling and classification
"""
function simulate_trials!(dat, grid, n_tiles, n_trials::Int)
    # pre-allocated space for the drawn tiles
    tiles = Array{Hex}(n_tiles)
    groups = Array{Int}(n_tiles)

    for i in 1:n_trials
        # drawn tiles from the grid; put them into groups
        tiles = Set(sample(grid, n_tiles, replace=false))
        groups = hex_groups(tiles)

        # characterize each group and add it to the output data
        for g in groups
            dat[classify_polyhex(g)] += 1
        end
    end
end

"""
Return the names of the polyhexes in the Circle of Life. Use this as a verification
of the names and classifications.
"""
function circleoflife()::Array{String}
    shapes = [ # 1-hex shapes
              Set([Hex(0, 0, 0)]),
                 # 2-hex
                 Set([Hex(0, 0, 0), Hex(1, 0, -1)]),
                 # 3-hexes
                 Set([Hex(0, 0, 0), Hex(1, 0, -1), Hex(2, -1, -1)]),
                 Set([Hex(0, 0, 0), Hex(1, 0, -1), Hex(2, 0, -2)]),
                 Set([Hex(0, 0, 0), Hex(-1, 0, 1), Hex(0, -1, 1)]),
                 # 4-hexes
                 Set([Hex(0, 0, 0), Hex(1, 0, -1), Hex(2, 0, -2), Hex(1, 1, -2)]),
                 Set([Hex(0, 0, 0), Hex(1, 0, -1), Hex(2, -1, -1), Hex(3, -1, -2)]),
                 Set([Hex(0, 0, 0), Hex(1, 0, -1), Hex(2, 0, -2), Hex(3, -1, -2)]),
                 Set([Hex(0, 0, 0), Hex(1, 0, -1), Hex(1, -1, 0), Hex(2, -1, -1)]),
                 Set([Hex(0, 0, 0), Hex(1, 0, -1), Hex(1, 1, -2), Hex(0, 2, -2)]),
                 Set([Hex(0, 0, 0), Hex(1, 0, -1), Hex(-1, 1, 0), Hex(0, -1, 1)]),
                 Set([Hex(0, 0, 0), Hex(1, 0, -1), Hex(2, 0, -2), Hex(3, 0, -3)])]

    [classify_polyhex(shape) for shape in shapes]
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

#=
println("radius\tshort wave\ttriangle\tshort bar")
for radius in 1:20
    dat = simulate(10000, 3, radius)
    println(radius, "\t", dat["short wave"], "\t", dat["triangle"], "\t", dat["short bar"])
end
=#

function grid(radius::Int)::Array{Hex, 1}
    [Hex(x, y, -x - y) for x in -radius:radius for y in max(-radius, -x - radius):min(radius, radius - x)]
end

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
Break an array of hexes an array of arrays. Each array is a group of continguous
hexes.
"""
function assigngroups(adjacent::BitArray{2}, idx::Array{Int})::Array{Int}
    # initialize each tile in its own group
    n = length(idx)
    groups = Array(1:n)

    for i in 1:(n - 1)
        for j in (i + 1):n
            if adjacent[idx[i], idx[j]] && groups[i] != groups[j]
                # change of all of j's group to i's group
                old_group = groups[j]
                new_group = groups[i]

                for k in 1:n
                    if groups[k] == old_group
                        groups[k] = new_group
                    end
                end
            end
        end
    end
    groups
end

function simulate(n_trials, n_tiles, radius)
    gr = grid(radius)
    aj = adjacencymatrix(gr)

    dat = Dict{String, Int}()

    for k in circleoflife()
        dat[k] = 0
    end

    for trial_i = 1:n_trials
        idx = sample(1:length(gr), n_tiles, replace=false)
        groups = assigngroups(aj, idx)

        for g = distinct(groups)
            # indices (with respect to the grid) of tiles in group g
            g_idx = idx[find(x -> x == g, groups)]
            dat[classify_polyhex(gr[g_idx])] += 1
        end
    end
    dat
end

report(1000, 3, 2)

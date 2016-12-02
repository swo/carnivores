#!/usr/bin/env julia

import Base.+, Base.*, Base./
import StatsBase.sample

# Store cubic coordinates for each hex
immutable Hex
    x::Float64
    y::Float64
    z::Float64
end

# Allow an axial construction (that just converts back to cubic coordinates)
Hex(q, r) = Hex(q, r, -q - r)

# Define basic algeraic relationship for Hex objects
+(a::Hex, b::Hex) = Hex(a.x + b.x, a.y + b.y, a.z + b.z)
*(a::Float64, h::Hex) = Hex(a * h.x, a * h.y, a * h.z)
/(h::Hex, a::Float64) = (1.0 / a) * h

"""
Distance between two hexes `a` and `b`
"""
dist(a::Hex, b::Hex)::Float64 = max(abs(a.x - b.x), abs(a.y - b.y), abs(a.z - b.z))

"""
Center of mass of an list of hexes
"""
com(hs::Array{Hex})::Hex = sum(hs) / convert(Float64, length(hs))

"""
Moment of intertia for a list of hexes
"""
function moi(hs::Array{Hex})::Float64
    c = com(hs)
    sum([dist(c, h) ^ 2 for h in hs])
end

"""
Break an array of hexes an array of arrays. Each array is a group of continguous
hexes.
"""
function hex_groups(hs::Array{Hex})::Array{Array{Hex}}
    gs = Array{Hex}[]
    for h in hs
        assigned = false
        for g in gs, i in g
            if dist(h, i) == 1.0
                push!(g, h)
                assigned = true
                break
            end
        end

        if !assigned
            push!(gs, [h])
        end
    end
    gs
end

"""
Compute the "character" (length and MOI) of a group of hexes.
"""
group_char(x::Array{Hex})::Tuple{Int,Float64} = (length(x), round_digit(moi(x), 1))

"""
Round `x` down to `d` decimal places
"""
round_digit(x::Float64, d::Int)::Float64 = round(x * 10 ^ d) / 10 ^ d

"""
Run `n_trials` simulations by placing `n_tiles` hexes randomly in a space with
radius 2 * `max_coord` + 1.
"""
simulate = function(n_trials, n_tiles, max_coord)
    # the possible grid of hexes
    const grid = [Hex(x, y, -x - y) for x in -max_coord:max_coord for y in max(-max_coord, -x - max_coord):min(max_coord, max_coord - x)]

    # store a hash (length, moi) => # of times this shape occurs
    dat = Dict{Tuple{Int, Float64}, Int}()

    for i in 1:n_trials
        # drawn n_tiles hexes from the grid, put them into groups
        tiles = sample(grid, n_tiles, replace=false)
        groups = hex_groups(tiles)

        # characterize each group and add it to the output data
        for g in groups
            c = group_char(g)
            if haskey(dat, c)
                dat[c] += 1
            else
                dat[c] = 1
            end
        end
    end

    return dat
end

# generate the data
dat = simulate(1e7, 4, 3)

# the list of shapes in the circle of life
const shapes = [(1, 0.0),
                (2, 0.5),
                (3, 2.1), (3, 2.0), (3, 1.3),
                (4, 3.2), (4, 5.0), (4, 5.3), (4, 2.5), (4, 4.2), (4, 3.0), (4, 10.0)]


# check that all the shapes in the simulation data are present in the circle of life
for k in keys(dat)
    if !(k in shapes)
        throw("missing $(k)")
    end
end

# print the output
for (i, k) in enumerate(shapes)
    if haskey(dat, k)
        println(i, "\t", dat[k], "\t", k)
    else
        println(i, "\t", 0, "\t", k)
    end
end

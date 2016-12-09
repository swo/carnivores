#!/usr/bin/env julia

import Base.+, Base.-, Base.*#, Base.convert
import StatsBase.sample, StatsBase.sample!

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
function classify_polyhex(hs::Array{Hex})::String
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
com(hs::Array{Hex})::Array{Float64} = hex2cartesian(sum(hs)) / convert(Float64, length(hs))

"""
Moment of intertia of an array of hexes
"""
moi(hs::Array{Hex})::Float64 = sum([norm(com(hs) - hex2cartesian(h)) ^ 2 for h in hs])

"""
Break an array of hexes an array of arrays. Each array is a group of continguous
hexes.
"""
function hex_groups(hs::Array{Hex})::Array{Array{Hex}}
    groups = Array{Hex}[]
    for h in hs
        add_hex_to_groups!(groups, h)
    end
    groups
end

function add_hex_to_groups!(groups, hex)
    for group in groups
        for member in group
            if dist(hex, member) == 1
                push!(group, hex)
                return nothing
            end
        end
    end

    push!(groups, [hex])
    nothing
end

"""
Run `n_trials` simulations by placing `n_tiles` hexes randomly in a space with
a given radius (i.e., you can go `radius` steps away from the center).
"""
function simulate(n_trials::Int, n_tiles::Int, radius::Int)
    # the possible grid of hexes
    grid = [Hex(x, y, -x - y) for x in -radius:radius for y in max(-radius, -x - radius):min(radius, radius - x)]

    # store a hash {polyhex name => # of times this shape occurs}
    dat = Dict{String, Int}()

    # pre-allocate the keys of the dictionary to avoid inferences
    for k in circle_of_life()
        dat[k] = 0
    end

    simulate_trials!(dat, grid, n_tiles, n_trials)

    return dat
end

"""
Actually do the sampling and classification
"""
function simulate_trials!(dat, grid, n_tiles, n_trials::Int)
    # pre-allocated space for the drawn tiles
    tiles = Array{Hex}(n_tiles)
    groups = Array{Int}(n_tiles)

    for i in 1:n_trials
        # drawn tiles from the grid; put them into groups
        sample!(grid, tiles, replace=false)
        groups = hex_groups(tiles)
        #hex_groups!(groups, tiles)

        #=
        for g in unique(groups)
            c = classify_polyhex(tiles[find(x -> x == g, groups)])
            dat[c] += 1
        end
        =#

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
function circle_of_life()::Array{String}
    shapes1 = [[Hex(0, 0, 0)]]

    shapes2 = [[Hex(0, 0, 0), Hex(1, 0, -1)]]

    shapes3 = [[Hex(0, 0, 0), Hex(1, 0, -1), Hex(2, -1, -1)],
               [Hex(0, 0, 0), Hex(1, 0, -1), Hex(2, 0, -2)],
               [Hex(0, 0, 0), Hex(-1, 0, 1), Hex(0, -1, 1)]]

    shapes4 = [[Hex(0, 0, 0), Hex(1, 0, -1), Hex(2, 0, -2), Hex(1, 1, -2)],
               [Hex(0, 0, 0), Hex(1, 0, -1), Hex(2, -1, -1), Hex(3, -1, -2)],
               [Hex(0, 0, 0), Hex(1, 0, -1), Hex(2, 0, -2), Hex(3, -1, -2)],
               [Hex(0, 0, 0), Hex(1, 0, -1), Hex(1, -1, 0), Hex(2, -1, -1)],
               [Hex(0, 0, 0), Hex(1, 0, -1), Hex(1, 1, -2), Hex(0, 2, -2)],
               [Hex(0, 0, 0), Hex(1, 0, -1), Hex(-1, 1, 0), Hex(0, -1, 1)],
               [Hex(0, 0, 0), Hex(1, 0, -1), Hex(2, 0, -2), Hex(3, 0, -3)]]

    [classify_polyhex(shape) for shape in vcat(shapes1, shapes2, shapes3, shapes4)]
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
println("radius\tshort wave:triangle\ttriangle:short bar")
for radius in 1:20
    dat = simulate(1e6, 3, radius)
    ratio1 = dat["short wave"] / dat["triangle"]
    ratio2 = dat["triangle"] / dat["short bar"]
    println(radius, "\t", ratio1, "\t", ratio2)
end
=#
@time report(1000000, 4, 4)
#Profile.print(format=:flat, sortedby=:count)
#circle_of_life()

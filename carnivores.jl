#!/usr/bin/env julia

import Base.+, Base.-, Base.*#, Base.convert
import StatsBase.sample

# Store cubic coordinates for each hex
immutable Hex
    x::Int
    y::Int
end

# Allow a cubic construction
Hex(x, y, z) = if (x + y + z == 0) Hex(x, y) else error("cubic coordinates do not sum to 0") end

# Define basic algeraic relationship for Hex objects
+(a::Hex, b::Hex) = Hex(a.x + b.x, a.y + b.y)
#+(a::Hex, b::Hex) = Hex(a.x + b.x, a.y + b.y, a.z + b.z)
*(a::Int, h::Hex) = Hex(a * h.x, a * h.y)
-(a::Hex, b::Hex) = Hex(a.x - b.x, a.y - b.y)
#*(a::Float64, h::Hex{Int}) = Hex{Float64}(a * h.x, a * h.y, a * h.z)
#/(h::Hex, a::Float64) = (1.0 / a) * h

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
#dist(a::Hex, b::Hex)::Int = max(abs(a.x - b.x), abs(a.y - b.y), abs(a.z - b.z))
dist(a::Hex, b::Hex)::Int = (abs(a.x - b.x) + abs(a.x + a.y - b.x - b.y) + abs(a.y - b.y)) / 2
#dist(a::Cartesian, b::Cartesian)::Float64 = norm(a - b)

"""
Center of mass of an array of hexes
"""
#com(hs::Array{Hex})::Hex = sum(hs) / convert(Float64, length(hs))
com(hs::Array{Hex})::Array{Float64} = hex2cartesian(sum(hs)) / convert(Float64, length(hs))

"""
Moment of intertia of an array of hexes
"""
moi(hs::Array{Hex})::Float64 = sum([norm(com(hs) - hex2cartesian(h)) ^ 2 for h in hs])
#=
function moi(hs::Array{Hex})::Float64
    c = com(hs)
    sum([dist(c, h) ^ 2 for h in hs])
end
=#

"""
Break an array of hexes an array of arrays. Each array is a group of continguous
hexes.
"""
function hex_groups(hs::Array{Hex})::Array{Array{Hex}}
    gs = Array{Hex}[]
    for h in hs
        assigned = false
        for g in gs, i in g
            if dist(h, i) == 1
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
Round `x` down to `d` decimal places
"""
round_digit(x::Float64, d::Int)::Float64 = round(x * 10 ^ d) / 10 ^ d

"""
Run `n_trials` simulations by placing `n_tiles` hexes randomly in a space with
a given radius (i.e., you can go `radius` steps away from the center).
"""
simulate = function(n_trials, n_tiles, radius)
    # the possible grid of hexes
    const grid = [Hex(x, y, -x - y) for x in -radius:radius for y in max(-radius, -x - radius):min(radius, radius - x)]

    # store a hash {polyhex name => # of times this shape occurs}
    dat = Dict{String, Int}()

    for i in 1:n_trials
        # drawn n_tiles hexes from the grid, put them into groups
        tiles = sample(grid, n_tiles, replace=false)
        groups = hex_groups(tiles)

        # characterize each group and add it to the output data
        for g in groups
            c = classify_polyhex(g)
            if haskey(dat, c)
                dat[c] += 1
            else
                dat[c] = 1
            end
        end
    end

    return dat
end

"""
Return the names of the polyhexes in the Circle of Life. Use this as a verification
of the names and classifications.
"""
function circle_of_life()
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

    for shape in vcat(shapes1, shapes2, shapes3, shapes4)
        println(shape)
        println(length(shape))
        println(moi(shape))
        println()
    end

    #[classify_polyhex(shape) for shape in vcat(shapes1, shapes2, shapes3, shapes4)]
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
@time report(1e7, 4, 4)
#circle_of_life()

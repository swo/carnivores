import sys, os
sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))
from hextile import *

import itertools

def show_hexes(grid_radius, hex_chars, empty_hex='.'):
    line_diameter = 2 * grid_radius + 1
    char_diameter = 4 * grid_radius + 1
    lines = [[' '] * char_diameter for i in range(line_diameter)]

    for h in grid(grid_radius):
        l, p = hex_to_line_char(grid_radius, h)
        lines[l][p] = empty_hex

    for h, c in hex_chars:
        l, p = hex_to_line_char(grid_radius, h)
        lines[l][p] = c

    return [''.join(l) for l in reversed(lines)]

def print_hexes(grid_radius, hex_chars, empty_hex='.'):
    for l in show_hexes(grid_radius, hex_chars, empty_hex=empty_hex):
        print(l)

def hex_to_line_char(r, h):
    hex_x, hex_y = [int(x) for x in h.coords]
    z = hex_x + hex_y

    line = r + z
    char = 2 * hex_x - z + 2 * r

    return (line, char)


def any_adjacent_to(group, h):
    return any([m.distance_to(h) == 1 for m in group])

def groups_adjacent(group1, group2):
    return any([x.distance_to(y) == 1 for x in group1 for y in group2])

def add_hex_to_groups(groups, h):
    adjacent_groups = [g for g in groups if any_adjacent_to(g, h)]
    other_groups = [g for g in groups if not any_adjacent_to(g, h)]

    if len(adjacent_groups) == 0:
        return other_groups + [[h]]
    else:
        return other_groups + [[m for g in adjacent_groups for m in g] + [h]]

def hex_groups(hs):
    groups = []
    for h in hs:
        groups = add_hex_to_groups(groups, h)

    return groups

def classify(hs):
    moi = moment_of_intertia(hs)
    moi_eq = lambda x: abs(moi - x) < 1e-2

    if len(hs) == 1:
        return 'singleton'
    elif len(hs) == 2:
        return 'doubleton'
    elif len(hs) == 3 and moi_eq(1.67):
        return 'short wave'
    elif len(hs) == 3 and moi_eq(2.00):
        return 'short bar'
    elif len(hs) == 3 and moi_eq(1.00):
        return 'triangle'
    elif len(hs) == 4 and moi_eq(4.00):
        return 'long wave'
    elif len(hs) == 4 and moi_eq(2.75):
        return 'pistol'
    elif len(hs) == 4 and moi_eq(4.25):
        return 'worm'
    elif len(hs) == 4 and moi_eq(2.00):
        return 'bee'
    elif len(hs) == 4 and moi_eq(3.25):
        return 'arch'
    elif len(hs) == 4 and moi_eq(3.00):
        return 'propellor'
    elif len(hs) == 4 and moi_eq(5.00):
        return 'long bar'
    else:
        raise RuntimeError('unrecognized shape {} with MOI {} and COM {}'.format(hs, moi, center_of_mass(hs)))

def circle_of_life():
    return [classify(hs) for hs in \
        [[Hex(0, 0)], \
         [Hex(0, 0), Hex(1, 0)], \
         [Hex(0, 0), Hex(1, 0), Hex(2, -1)], \
         [Hex(0, 0), Hex(1, 0), Hex(2,  0)], \
         [Hex(0, 0), Hex(-1, 0), Hex(0, -1)], \
         [Hex(0, 0), Hex(1, 0), Hex(2, 0), Hex(1, 1)], \
         [Hex(0, 0), Hex(1, 0), Hex(2, -1), Hex(3, -1)], \
         [Hex(0, 0), Hex(1, 0), Hex(2, 0), Hex(3, -1)], \
         [Hex(0, 0), Hex(1, 0), Hex(1, -1), Hex(2, -1)], \
         [Hex(0, 0), Hex(1, 0), Hex(1, 1), Hex(0, 2)], \
         [Hex(0, 0), Hex(1, 0), Hex(-1, 1), Hex(0, -1)], \
         [Hex(0, 0), Hex(1, 0), Hex(2, 0), Hex(3, 0)]]]

def grid(radius):
    return [Hex(x, y) \
            for x in range(-radius, radius + 1) \
            for y in range(max(-radius, -(x + radius)), min(radius, radius - x) + 1)]

def deterministic_appearances(n_tiles, grid_radius):
    gr = grid(grid_radius)
    dat = {}
    for chosen_tiles in itertools.combinations(gr, n_tiles):
        c = tuple(sorted([classify(g) for g in hex_groups(chosen_tiles)]))
        if c in dat:
            dat[c] += 1
        else:
            dat[c] = 1

    return dat

def follows(lst, b, a):
    '''Does b follow a in lst?'''
    ai = lst.index(a)
    bi = lst.index(b)
    return bi == ai + 1 or (bi == 0 and ai == len(lst) - 1)

def is_legal_move(gr, stones1, stones2, new_stone1):
    if new_stone1 in stones1 or new_stone1 in stones2:
        return False

    if new_stone1 not in gr:
        return False

    groups1 = hex_groups(stones1)
    if max([len(g) for g in groups1]) > 4:
        raise RuntimeError('already ill-formed groups')

    new_groups1 = add_hex_to_groups(groups1, new_stone1)
    if max([len(g) for g in new_groups1]) > 4:
        return False

    return True

def evolve(gr, stones1, stones2, new_stone1):
    if not is_legal_move(gr, stones1, stones2, new_stone1):
        raise RuntimeError('illegal move')

    groups1 = hex_groups(stones1 + [new_stone1])
    groups2 = hex_groups(stones2)

    # check which of the opponents' groups are adjacent to any of our groups
    consumed = []
    for group1 in groups1:
        for group2 in groups2:
            if groups_adjacent(group1, group2):
                predator = classify(group1)
                prey = classify(group2)
                if follows(circle_of_life(), predator, prey):
                    if group2 not in consumed:
                        consumed.append(group2)

    new_stones1 = [x for g in groups1 for x in g]
    new_stones2 = [x for g in groups2 for x in g if g not in consumed]

    return (new_stones1, new_stones2)

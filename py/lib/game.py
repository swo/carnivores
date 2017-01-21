import sys, os
sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))
from hextile import *

def any_adjacent_to(group, h):
    return any([m.distance_to(h) == 1 for m in group])

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
    return [Hex(x, y) for x in range(-radius, radius + 1) for y in range(max(-radius, -(x + radius)), min(radius, radius - x) + 1)]

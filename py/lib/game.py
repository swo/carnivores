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
    pass

def circle_of_life():
    pass

def grid(radius):
    return [Hex(x, y) for x in range(-radius, radius + 1) for y in range(max(-radius, -(x + radius)), min(radius, radius - x) + 1)]

#!/usr/bin/env python3

import pytest
from context import lib
from lib.game import *

class TestGrid:
    def test_radius0(self):
        assert grid(0) == [Hex(0, 0)]

    def test_radius1(self):
        assert grid(1) == [Hex(-1, 0), Hex(-1, 1), Hex(0, -1), Hex(0, 0), Hex(0, 1), Hex(1, -1), Hex(1, 0)]

    def test_radius_size(self):
        # I define radius 0 as the first centered hexagonal number
        for r in range(1, 10):
            assert len(grid(r - 1)) == 1 + 6 * (r * (r - 1) / 2)


class TestGroups:
    def test_any_adjacent(self):
        assert any_adjacent_to([Hex(0, 0), Hex(1, 0)], Hex(0, 1))
        assert not any_adjacent_to([Hex(0, 0), Hex(1, 0)], Hex(0, 2))

    def test_add_add(self):
        assert add_hex_to_groups([[Hex(0, 0), Hex(1, 0)]], Hex(-1, 0)) == [[Hex(0, 0), Hex(1, 0), Hex(-1, 0)]]

    def test_add_noadd(self):
        assert add_hex_to_groups([[Hex(0, 0), Hex(1, 0)]], Hex(-2, 0)) == [[Hex(0, 0), Hex(1, 0)], [Hex(-2, 0)]]

    def test_group(self):
        assert hex_groups([Hex(0, 0), Hex(1, 0), Hex(-2, 0)]) == [[Hex(0, 0), Hex(1, 0)], [Hex(-2, 0)]]

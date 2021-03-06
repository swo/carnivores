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


class TestHexToLineChar:
    def test1(self):
        assert hex_to_line_char(1, Hex(0, 0)) == (1, 2)

    def test2(self):
        assert hex_to_line_char(1, Hex(1, -1)) == (1, 4)

    def test3(self):
        assert hex_to_line_char(1, Hex(1, 0)) == (2, 3)

    def test4(self):
        assert hex_to_line_char(1, Hex(0, -1)) == (0, 3)


class TestShow:
    def test1(self):
        assert show_hexes(0, []) == ['.']

    def test2(self):
        assert show_hexes(0, [(Hex(0, 0), 'x')]) == ['x']

    def test_empty_1(self):
        assert show_hexes(1, []) == [' . . ', '. . .', ' . . ']

    def test3(self):
        assert show_hexes(1, [(Hex(0, 0), 'c'), (Hex(1, -1), 'r'), (Hex(1, 0), 'n')]) == [' . n ', '. c r', ' . . ']


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


class TestCircle:
    def test(self):
        assert circle_of_life() == ['singleton', 'doubleton', 'short wave', 'short bar', 'triangle', 'pistol', 'long wave', 'worm', 'bee', 'arch', 'propellor', 'long bar']


class TestDeterministic:
    def test_n_choices(self):
        for r in range(1, 3):
            for n in range(4):
                gr = grid(r)
                res = deterministic_appearances(n, r)
                n_res = sum(res.values())
                assert n_res == len(list(itertools.combinations(gr, n)))

    def test_2_1(self):
        assert deterministic_appearances(2, 1) == {('doubleton',): 12, ('singleton', 'singleton'): 9}


class TestFollow:
    def test_simple(self):
        lst = ['a', 'b', 'c', 'd']
        assert follows(lst, 'b', 'a')
        assert follows(lst, 'c', 'b')
        assert follows(lst, 'd', 'c')

    def test_loop(self):
        lst = ['a', 'b', 'c', 'd']
        assert follows(lst, 'a', 'd')


class TestLegal:
    def test_stone_already_placed(self):
        assert not is_legal_move(grid(3), [Hex(0, 0)], [], Hex(0, 0))

    def test_stone_not_in_grid(self):
        assert not is_legal_move(grid(1), [], [], Hex(4, 0))

    def test_groups_already_too_large(self):
        with pytest.raises(RuntimeError):
            is_legal_move(grid(2), [Hex(0, 0), Hex(1, 0), Hex(-1, 0), Hex(0, 1), Hex(0, -1)], [], Hex(2, -2))

    def test_new_group_too_large(self):
        assert not is_legal_move(grid(2), [Hex(0, 0), Hex(1, 0), Hex(-1, 0), Hex(0, 1)], [], Hex(0, -1))

    def test_allowed_move(self):
        assert is_legal_move(grid(2), [Hex(0, 0), Hex(1, 0), Hex(-1, 0)], [], Hex(0, 1))


class TestEvolve:
    def test_raise_illegal(self):
        with pytest.raises(RuntimeError):
            evolve(grid(1), [Hex(0, 0), Hex(1, 0), Hex(-1, 0), Hex(0, 1)], [], Hex(0, -1))

    def test_capture(self):
        assert evolve(grid(1), [Hex(0, 0)], [Hex(1, 0)], Hex(-1, 0)) == ([Hex(0, 0), Hex(-1, 0)], [])

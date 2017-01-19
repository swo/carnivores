#!/usr/bin/env python3

import pytest
from context import lib
from lib.hextile import *

class TestHexArithmetic:
    def test_str(self):
        assert str(Hex(1, 2)) == 'Hex(1, 2)'

    def test_eq(self):
        assert Hex(0, 1) == Hex(0, 1)

    def test_add(self):
        assert Hex(1, 2) + Hex(0, -1) == Hex(1, 1)

    def test_mul(self):
        assert Hex(1, 2) * 3 == Hex(3, 6)

    def test_div(self):
        assert Hex(3, 3) / 3 == Hex(1, 1)

    def test_sub(self):
        assert Hex(3, 3) - Hex(1, 2) == Hex(2, 1)


class TestHexToCartesian:
    def test_nearly_equals(self):
        assert Hex(0, 0).nearly_equals(Hex(0 + 1e-7, 0 - 1e-7))

    def test_not_nearly_equals(self):
        assert not Hex(0, 0).nearly_equals(Hex(0 + 1e-5, 0))

    def test1(self):
        assert Hex(2, 1).to_cartesian().nearly_equals(Hex(2.5, 0.866025))


class TestDistanceTo:
    def test1(self):
        assert Hex(0, 0).distance_to(Hex(4, -3)) == 4


class TestHexSum:
    def test1(self):
        assert hex_sum([Hex(1, 1), Hex(1, -2)]) == Hex(2, -1)


class TestCenterOfMass:
    pass


class TestMomentOfIntertia:
    pass

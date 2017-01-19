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

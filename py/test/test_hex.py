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

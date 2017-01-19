import numpy as np

class Hex:
    def __init__(self, x, y):
        self.coords = np.array([x, y])

    def __repr__(self):
        return "Hex({}, {})".format(*self.coords)

    def __str__(self):
        return self.__repr__()

    def __eq__(self, other):
        return all(self.coords == other.coords)

    def __add__(self, other):
        return Hex(*(self.coords + other.coords))

    def __sub__(self, other):
        return Hex(*(self.coords - other.coords))

    def __mul__(self, other):
        return Hex(*(self.coords * other))

    def __truediv__(self, other):
        return Hex(*(self.coords / other))

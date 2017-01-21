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

    # def __lt__(self, other):
    #     return self.coords < other.coords

    def nearly_equals(self, other, epsilon=1e-6):
        return max(map(abs, self.coords - other.coords)) < epsilon

    def to_cartesian(self):
        return Hex(self.coords[0] + 0.5 * self.coords[1], np.sqrt(3) / 2 * self.coords[1])

    def distance_to(self, other):
        return (sum(map(abs, self.coords - other.coords)) + abs(sum(self.coords) - sum(other.coords))) / 2

    def adjacent_to(self, other):
        return self.distance_to(other) == 1

def hex_sum(hs):
    return sum(hs, Hex(0, 0))

def center_of_mass(hs):
    return hex_sum([h.to_cartesian() for h in hs]) / len(hs)

def moment_of_intertia(hs):
    com = center_of_mass(hs)
    return sum([sum((h.to_cartesian() - com).coords ** 2) for h in hs])

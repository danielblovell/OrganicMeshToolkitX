"""
Organic Mesh Toolkit X

3D Vector Mathematics

This class intentionally does not depend on Blender's mathutils
so the geometry engine can run anywhere.
"""

from __future__ import annotations

from dataclasses import dataclass
import math


@dataclass(slots=True)
class Vector3:
    """
    Immutable-style 3D vector.
    """

    x: float = 0.0
    y: float = 0.0
    z: float = 0.0

    def copy(self) -> "Vector3":
        return Vector3(self.x, self.y, self.z)

    @property
    def length(self) -> float:
        return math.sqrt(
            self.x * self.x +
            self.y * self.y +
            self.z * self.z
        )

    @property
    def length_squared(self) -> float:
        return (
            self.x * self.x +
            self.y * self.y +
            self.z * self.z
        )

    def normalize(self) -> "Vector3":

        l = self.length

        if l == 0:
            return Vector3()

        return Vector3(
            self.x / l,
            self.y / l,
            self.z / l
        )

    def dot(self, other: "Vector3") -> float:

        return (
            self.x * other.x +
            self.y * other.y +
            self.z * other.z
        )

    def cross(self, other: "Vector3") -> "Vector3":

        return Vector3(
            self.y * other.z - self.z * other.y,
            self.z * other.x - self.x * other.z,
            self.x * other.y - self.y * other.x
        )

    def distance(self, other: "Vector3") -> float:
        return (self - other).length

    def __add__(self, other: "Vector3") -> "Vector3":

        return Vector3(
            self.x + other.x,
            self.y + other.y,
            self.z + other.z
        )

    def __sub__(self, other: "Vector3") -> "Vector3":

        return Vector3(
            self.x - other.x,
            self.y - other.y,
            self.z - other.z
        )

    def __mul__(self, scalar: float) -> "Vector3":

        return Vector3(
            self.x * scalar,
            self.y * scalar,
            self.z * scalar
        )

    def __truediv__(self, scalar: float) -> "Vector3":

        return Vector3(
            self.x / scalar,
            self.y / scalar,
            self.z / scalar
        )

    def __neg__(self) -> "Vector3":

        return Vector3(
            -self.x,
            -self.y,
            -self.z
        )

    def __iter__(self):

        yield self.x
        yield self.y
        yield self.z

    def __repr__(self):

        return (
            f"Vector3("
            f"{self.x:.6f}, "
            f"{self.y:.6f}, "
            f"{self.z:.6f})"
        )
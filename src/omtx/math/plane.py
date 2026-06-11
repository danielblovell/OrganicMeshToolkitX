"""Plane primitive."""

from __future__ import annotations

from dataclasses import dataclass

from omtx.math.vector3 import Vector3


@dataclass(slots=True)
class Plane:
    """3D plane represented by normal and distance from origin."""

    normal: Vector3
    distance: float

    @classmethod
    def from_point_normal(cls, point: Vector3, normal: Vector3) -> Plane:
        """Create a plane from point and normal."""
        n = normal.normalize()
        return cls(normal=n, distance=n.dot(point))

    def signed_distance_to(self, point: Vector3) -> float:
        """Return signed distance from point to plane."""
        return self.normal.dot(point) - self.distance

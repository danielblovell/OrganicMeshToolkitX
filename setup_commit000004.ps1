New-Item -ItemType Directory -Force -Path "src\omtx\math" | Out-Null
New-Item -ItemType Directory -Force -Path "tests" | Out-Null

@'
"""Axis-aligned bounding box."""

from __future__ import annotations

from dataclasses import dataclass

from omtx.math.vector3 import Vector3


@dataclass(slots=True)
class BoundingBox:
    """Axis-aligned bounding box."""

    minimum: Vector3
    maximum: Vector3

    @classmethod
    def empty(cls) -> "BoundingBox":
        """Create an empty bounding box."""
        return cls(
            minimum=Vector3(float("inf"), float("inf"), float("inf")),
            maximum=Vector3(float("-inf"), float("-inf"), float("-inf")),
        )

    @property
    def size(self) -> Vector3:
        """Return box size."""
        return self.maximum - self.minimum

    @property
    def center(self) -> Vector3:
        """Return box center."""
        return (self.minimum + self.maximum) * 0.5

    def expand_to_include(self, point: Vector3) -> None:
        """Expand box to include a point."""
        self.minimum = Vector3(
            min(self.minimum.x, point.x),
            min(self.minimum.y, point.y),
            min(self.minimum.z, point.z),
        )

        self.maximum = Vector3(
            max(self.maximum.x, point.x),
            max(self.maximum.y, point.y),
            max(self.maximum.z, point.z),
        )

    def contains(self, point: Vector3) -> bool:
        """Return True if point is inside the box."""
        return (
            self.minimum.x <= point.x <= self.maximum.x
            and self.minimum.y <= point.y <= self.maximum.y
            and self.minimum.z <= point.z <= self.maximum.z
        )
'@ | Set-Content "src\omtx\math\bounding_box.py"

@'
"""Ray primitive."""

from __future__ import annotations

from dataclasses import dataclass

from omtx.math.vector3 import Vector3


@dataclass(slots=True)
class Ray:
    """3D ray with origin and normalized direction."""

    origin: Vector3
    direction: Vector3

    def __post_init__(self) -> None:
        self.direction = self.direction.normalize()

    def point_at(self, distance: float) -> Vector3:
        """Return point along ray at distance."""
        return self.origin + self.direction * distance
'@ | Set-Content "src\omtx\math\ray.py"

@'
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
    def from_point_normal(cls, point: Vector3, normal: Vector3) -> "Plane":
        """Create a plane from point and normal."""
        n = normal.normalize()
        return cls(normal=n, distance=n.dot(point))

    def signed_distance_to(self, point: Vector3) -> float:
        """Return signed distance from point to plane."""
        return self.normal.dot(point) - self.distance
'@ | Set-Content "src\omtx\math\plane.py"

@'
"""Line segment primitive."""

from __future__ import annotations

from dataclasses import dataclass

from omtx.math.vector3 import Vector3


@dataclass(slots=True)
class LineSegment:
    """Finite line segment."""

    start: Vector3
    end: Vector3

    @property
    def length(self) -> float:
        """Return segment length."""
        return self.start.distance(self.end)

    @property
    def midpoint(self) -> Vector3:
        """Return segment midpoint."""
        return (self.start + self.end) * 0.5
'@ | Set-Content "src\omtx\math\line_segment.py"

@'
"""Math primitives for Organic Mesh Toolkit X."""

from omtx.math.bounding_box import BoundingBox
from omtx.math.line_segment import LineSegment
from omtx.math.plane import Plane
from omtx.math.ray import Ray
from omtx.math.vector3 import Vector3

__all__ = [
    "Vector3",
    "BoundingBox",
    "Ray",
    "Plane",
    "LineSegment",
]
'@ | Set-Content "src\omtx\math\__init__.py"

@'
from omtx.math import BoundingBox, LineSegment, Plane, Ray, Vector3


def test_bounding_box_expand_and_contains():
    box = BoundingBox.empty()

    box.expand_to_include(Vector3(1, 2, 3))
    box.expand_to_include(Vector3(-1, 5, 0))

    assert box.minimum == Vector3(-1, 2, 0)
    assert box.maximum == Vector3(1, 5, 3)
    assert box.contains(Vector3(0, 3, 1))
    assert not box.contains(Vector3(3, 3, 1))


def test_ray_point_at():
    ray = Ray(origin=Vector3(1, 0, 0), direction=Vector3(2, 0, 0))

    assert ray.point_at(3) == Vector3(4, 0, 0)


def test_plane_signed_distance():
    plane = Plane.from_point_normal(Vector3(0, 0, 5), Vector3(0, 0, 1))

    assert plane.signed_distance_to(Vector3(0, 0, 8)) == 3
    assert plane.signed_distance_to(Vector3(0, 0, 2)) == -3


def test_line_segment():
    segment = LineSegment(Vector3(0, 0, 0), Vector3(2, 0, 0))

    assert segment.length == 2
    assert segment.midpoint == Vector3(1, 0, 0)
'@ | Set-Content "tests\test_math_primitives.py"

Write-Host "Commit 000004 math primitives files created."
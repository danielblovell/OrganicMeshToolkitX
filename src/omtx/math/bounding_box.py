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
    def empty(cls) -> BoundingBox:
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

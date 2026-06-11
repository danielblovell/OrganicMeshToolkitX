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

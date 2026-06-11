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

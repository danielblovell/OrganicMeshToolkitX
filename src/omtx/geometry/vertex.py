"""Vertex data structure."""

from __future__ import annotations

from dataclasses import dataclass, field

from omtx.math.vector3 import Vector3


@dataclass(slots=True)
class Vertex:
    """A mesh vertex with a position and optional identifier."""

    position: Vector3
    id: int | None = None
    attributes: dict[str, object] = field(default_factory=dict)

    def distance_to(self, other: Vertex) -> float:
        """Return distance to another vertex."""
        return self.position.distance(other.position)

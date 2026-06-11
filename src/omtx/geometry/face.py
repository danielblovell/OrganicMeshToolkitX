"""Face data structure."""

from __future__ import annotations

from dataclasses import dataclass, field

from omtx.geometry.vertex import Vertex
from omtx.math.vector3 import Vector3


@dataclass(slots=True)
class Face:
    """Polygon face defined by ordered vertices."""

    vertices: list[Vertex]
    id: int | None = None
    attributes: dict[str, object] = field(default_factory=dict)

    @property
    def vertex_count(self) -> int:
        """Return number of vertices in the face."""
        return len(self.vertices)

    def normal(self) -> Vector3:
        """Return approximate face normal using the first three vertices."""
        if len(self.vertices) < 3:
            return Vector3()

        a = self.vertices[0].position
        b = self.vertices[1].position
        c = self.vertices[2].position

        return (b - a).cross(c - a).normalize()

    def area(self) -> float:
        """Return polygon area by fan triangulation."""
        if len(self.vertices) < 3:
            return 0.0

        origin = self.vertices[0].position
        total = 0.0

        for i in range(1, len(self.vertices) - 1):
            b = self.vertices[i].position
            c = self.vertices[i + 1].position
            total += (b - origin).cross(c - origin).length * 0.5

        return total

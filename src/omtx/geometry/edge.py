"""Edge data structure."""

from __future__ import annotations

from dataclasses import dataclass

from omtx.geometry.vertex import Vertex


@dataclass(slots=True)
class Edge:
    """Undirected mesh edge connecting two vertices."""

    start: Vertex
    end: Vertex
    id: int | None = None

    @property
    def length(self) -> float:
        """Return edge length."""
        return self.start.distance_to(self.end)

    def contains(self, vertex: Vertex) -> bool:
        """Return True if the vertex is one of the edge endpoints."""
        return vertex is self.start or vertex is self.end

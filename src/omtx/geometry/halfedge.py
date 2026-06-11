"""Half-edge data structure."""

from __future__ import annotations

from dataclasses import dataclass
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from omtx.geometry.halfedge_face import HalfEdgeFace
    from omtx.geometry.halfedge_vertex import HalfEdgeVertex


@dataclass(slots=True)
class HalfEdge:
    """Directed edge used by a half-edge mesh."""

    origin: HalfEdgeVertex
    twin: HalfEdge | None = None
    next: HalfEdge | None = None
    previous: HalfEdge | None = None
    face: HalfEdgeFace | None = None
    id: int | None = None

    @property
    def destination(self) -> HalfEdgeVertex | None:
        """Return the destination vertex of this half-edge."""
        if self.twin is None:
            return None
        return self.twin.origin

    @property
    def is_boundary(self) -> bool:
        """Return True if this half-edge has no face."""
        return self.face is None

    def set_twins(self, other: HalfEdge) -> None:
        """Pair this half-edge with its opposite half-edge."""
        self.twin = other
        other.twin = self

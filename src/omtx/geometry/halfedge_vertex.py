"""Half-edge vertex."""

from __future__ import annotations

from dataclasses import dataclass, field

from omtx.math.vector3 import Vector3


@dataclass(slots=True)
class HalfEdgeVertex:
    """Vertex used by a half-edge mesh."""

    position: Vector3
    id: int | None = None
    halfedge_id: int | None = None
    attributes: dict[str, object] = field(default_factory=dict)

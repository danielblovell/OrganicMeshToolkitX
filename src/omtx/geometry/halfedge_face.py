"""Half-edge face."""

from __future__ import annotations

from dataclasses import dataclass, field


@dataclass(slots=True)
class HalfEdgeFace:
    """Face used by a half-edge mesh."""

    halfedge_id: int
    id: int | None = None
    attributes: dict[str, object] = field(default_factory=dict)

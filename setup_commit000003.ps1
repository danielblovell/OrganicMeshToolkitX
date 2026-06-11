New-Item -ItemType Directory -Force -Path "src\omtx\geometry" | Out-Null
New-Item -ItemType Directory -Force -Path "tests" | Out-Null

@'
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
'@ | Set-Content "src\omtx\geometry\halfedge.py"

@'
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
'@ | Set-Content "src\omtx\geometry\halfedge_vertex.py"

@'
"""Half-edge face."""

from __future__ import annotations

from dataclasses import dataclass, field


@dataclass(slots=True)
class HalfEdgeFace:
    """Face used by a half-edge mesh."""

    halfedge_id: int
    id: int | None = None
    attributes: dict[str, object] = field(default_factory=dict)
'@ | Set-Content "src\omtx\geometry\halfedge_face.py"

@'
"""Half-edge mesh container."""

from __future__ import annotations

from dataclasses import dataclass, field

from omtx.geometry.halfedge import HalfEdge
from omtx.geometry.halfedge_face import HalfEdgeFace
from omtx.geometry.halfedge_vertex import HalfEdgeVertex
from omtx.math.vector3 import Vector3


@dataclass(slots=True)
class HalfEdgeMesh:
    """Minimal half-edge mesh implementation."""

    vertices: list[HalfEdgeVertex] = field(default_factory=list)
    halfedges: list[HalfEdge] = field(default_factory=list)
    faces: list[HalfEdgeFace] = field(default_factory=list)
    name: str = "HalfEdgeMesh"

    def add_vertex(self, position: Vector3) -> HalfEdgeVertex:
        """Add a vertex."""
        vertex = HalfEdgeVertex(position=position, id=len(self.vertices))
        self.vertices.append(vertex)
        return vertex

    def add_face(self, vertices: list[HalfEdgeVertex]) -> HalfEdgeFace:
        """Add a polygon face using ordered vertices."""
        if len(vertices) < 3:
            raise ValueError("A face requires at least three vertices.")

        start_index = len(self.halfedges)
        new_edges: list[HalfEdge] = []

        for vertex in vertices:
            edge = HalfEdge(origin=vertex, id=len(self.halfedges))
            self.halfedges.append(edge)
            new_edges.append(edge)

            if vertex.halfedge_id is None:
                vertex.halfedge_id = edge.id

        face = HalfEdgeFace(halfedge_id=start_index, id=len(self.faces))
        self.faces.append(face)

        edge_count = len(new_edges)

        for i, edge in enumerate(new_edges):
            edge.next = new_edges[(i + 1) % edge_count]
            edge.previous = new_edges[(i - 1) % edge_count]
            edge.face = face

        self._pair_twins_for_new_edges(new_edges)

        return face

    def _pair_twins_for_new_edges(self, new_edges: list[HalfEdge]) -> None:
        """Pair new half-edges with existing opposite half-edges."""
        for edge in new_edges:
            destination = edge.next.origin if edge.next is not None else None

            if destination is None:
                continue

            for candidate in self.halfedges:
                if candidate is edge:
                    continue

                candidate_destination = (
                    candidate.next.origin if candidate.next is not None else None
                )

                if candidate.origin is destination and candidate_destination is edge.origin:
                    edge.set_twins(candidate)
                    break

    @property
    def vertex_count(self) -> int:
        return len(self.vertices)

    @property
    def halfedge_count(self) -> int:
        return len(self.halfedges)

    @property
    def face_count(self) -> int:
        return len(self.faces)

    def face_halfedges(self, face: HalfEdgeFace) -> list[HalfEdge]:
        """Return ordered half-edges around a face."""
        result: list[HalfEdge] = []

        start = self.halfedges[face.halfedge_id]
        current = start

        while True:
            result.append(current)

            if current.next is None:
                break

            current = current.next

            if current is start:
                break

        return result

    def face_vertices(self, face: HalfEdgeFace) -> list[HalfEdgeVertex]:
        """Return ordered vertices around a face."""
        return [edge.origin for edge in self.face_halfedges(face)]

    def boundary_halfedges(self) -> list[HalfEdge]:
        """Return all boundary half-edges."""
        return [edge for edge in self.halfedges if edge.twin is None]
'@ | Set-Content "src\omtx\geometry\halfedge_mesh.py"

@'
"""Core geometry types for Organic Mesh Toolkit X."""

from omtx.geometry.edge import Edge
from omtx.geometry.face import Face
from omtx.geometry.halfedge import HalfEdge
from omtx.geometry.halfedge_face import HalfEdgeFace
from omtx.geometry.halfedge_mesh import HalfEdgeMesh
from omtx.geometry.halfedge_vertex import HalfEdgeVertex
from omtx.geometry.mesh import Mesh
from omtx.geometry.vertex import Vertex

__all__ = [
    "Vertex",
    "Edge",
    "Face",
    "Mesh",
    "HalfEdge",
    "HalfEdgeVertex",
    "HalfEdgeFace",
    "HalfEdgeMesh",
]
'@ | Set-Content "src\omtx\geometry\__init__.py"

@'
from omtx.geometry import HalfEdgeMesh
from omtx.math.vector3 import Vector3


def test_create_triangle_halfedge_mesh():
    mesh = HalfEdgeMesh()

    a = mesh.add_vertex(Vector3(0, 0, 0))
    b = mesh.add_vertex(Vector3(1, 0, 0))
    c = mesh.add_vertex(Vector3(0, 1, 0))

    face = mesh.add_face([a, b, c])

    assert mesh.vertex_count == 3
    assert mesh.halfedge_count == 3
    assert mesh.face_count == 1
    assert len(mesh.face_halfedges(face)) == 3
    assert len(mesh.face_vertices(face)) == 3


def test_adjacent_triangles_create_twin_halfedges():
    mesh = HalfEdgeMesh()

    a = mesh.add_vertex(Vector3(0, 0, 0))
    b = mesh.add_vertex(Vector3(1, 0, 0))
    c = mesh.add_vertex(Vector3(0, 1, 0))
    d = mesh.add_vertex(Vector3(1, 1, 0))

    mesh.add_face([a, b, c])
    mesh.add_face([b, d, c])

    twin_count = sum(1 for edge in mesh.halfedges if edge.twin is not None)

    assert twin_count == 2


def test_boundary_halfedges():
    mesh = HalfEdgeMesh()

    a = mesh.add_vertex(Vector3(0, 0, 0))
    b = mesh.add_vertex(Vector3(1, 0, 0))
    c = mesh.add_vertex(Vector3(0, 1, 0))

    mesh.add_face([a, b, c])

    assert len(mesh.boundary_halfedges()) == 3
'@ | Set-Content "tests\test_halfedge.py"

Write-Host "Commit 000003 half-edge subsystem files created."
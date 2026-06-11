New-Item -ItemType Directory -Force -Path "src\omtx\geometry" | Out-Null
New-Item -ItemType Directory -Force -Path "tests" | Out-Null

@'
"""Core geometry types for Organic Mesh Toolkit X."""

from omtx.geometry.edge import Edge
from omtx.geometry.face import Face
from omtx.geometry.mesh import Mesh
from omtx.geometry.vertex import Vertex

__all__ = ["Vertex", "Edge", "Face", "Mesh"]
'@ | Set-Content "src\omtx\geometry\__init__.py"

@'
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

    def distance_to(self, other: "Vertex") -> float:
        """Return distance to another vertex."""
        return self.position.distance(other.position)
'@ | Set-Content "src\omtx\geometry\vertex.py"

@'
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
'@ | Set-Content "src\omtx\geometry\edge.py"

@'
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
'@ | Set-Content "src\omtx\geometry\face.py"

@'
"""Mesh data structure."""

from __future__ import annotations

from dataclasses import dataclass, field

from omtx.geometry.edge import Edge
from omtx.geometry.face import Face
from omtx.geometry.vertex import Vertex
from omtx.math.vector3 import Vector3


@dataclass(slots=True)
class Mesh:
    """Basic polygon mesh container."""

    vertices: list[Vertex] = field(default_factory=list)
    edges: list[Edge] = field(default_factory=list)
    faces: list[Face] = field(default_factory=list)
    name: str = "Mesh"

    def add_vertex(self, position: Vector3) -> Vertex:
        """Add a vertex and return it."""
        vertex = Vertex(position=position, id=len(self.vertices))
        self.vertices.append(vertex)
        return vertex

    def add_edge(self, start: Vertex, end: Vertex) -> Edge:
        """Add an edge and return it."""
        edge = Edge(start=start, end=end, id=len(self.edges))
        self.edges.append(edge)
        return edge

    def add_face(self, vertices: list[Vertex]) -> Face:
        """Add a face and return it."""
        face = Face(vertices=vertices, id=len(self.faces))
        self.faces.append(face)
        return face

    @property
    def vertex_count(self) -> int:
        return len(self.vertices)

    @property
    def edge_count(self) -> int:
        return len(self.edges)

    @property
    def face_count(self) -> int:
        return len(self.faces)

    def surface_area(self) -> float:
        """Return total mesh surface area."""
        return sum(face.area() for face in self.faces)
'@ | Set-Content "src\omtx\geometry\mesh.py"

@'
from omtx.geometry import Mesh
from omtx.math.vector3 import Vector3


def test_mesh_counts():
    mesh = Mesh(name="Triangle")

    a = mesh.add_vertex(Vector3(0, 0, 0))
    b = mesh.add_vertex(Vector3(1, 0, 0))
    c = mesh.add_vertex(Vector3(0, 1, 0))

    mesh.add_edge(a, b)
    mesh.add_edge(b, c)
    mesh.add_edge(c, a)
    mesh.add_face([a, b, c])

    assert mesh.vertex_count == 3
    assert mesh.edge_count == 3
    assert mesh.face_count == 1


def test_triangle_area():
    mesh = Mesh()

    a = mesh.add_vertex(Vector3(0, 0, 0))
    b = mesh.add_vertex(Vector3(1, 0, 0))
    c = mesh.add_vertex(Vector3(0, 1, 0))

    mesh.add_face([a, b, c])

    assert mesh.surface_area() == 0.5


def test_face_normal():
    mesh = Mesh()

    a = mesh.add_vertex(Vector3(0, 0, 0))
    b = mesh.add_vertex(Vector3(1, 0, 0))
    c = mesh.add_vertex(Vector3(0, 1, 0))

    face = mesh.add_face([a, b, c])

    assert face.normal() == Vector3(0, 0, 1)
'@ | Set-Content "tests\test_geometry_core.py"

Write-Host "Commit 000002 geometry core files created."
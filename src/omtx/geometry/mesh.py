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

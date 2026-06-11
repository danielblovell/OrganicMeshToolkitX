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

"""Mesh topology and geometry analysis."""

from __future__ import annotations

from collections.abc import Sequence
from dataclasses import dataclass
from math import isfinite

from omtx.math import Vector3

Face = Sequence[int]
Edge = tuple[int, int]


@dataclass(frozen=True, slots=True)
class MeshBounds:
    minimum: Vector3
    maximum: Vector3


@dataclass(frozen=True, slots=True)
class MeshTopologyCounts:
    vertex_count: int
    face_count: int
    edge_count: int
    boundary_edge_count: int
    nonmanifold_edge_count: int
    isolated_vertex_count: int


@dataclass(frozen=True, slots=True)
class MeshAnalysis:
    bounds: MeshBounds | None
    topology: MeshTopologyCounts
    is_empty: bool
    is_closed: bool
    is_manifold: bool
    has_degenerate_faces: bool


class MeshAnalyzer:
    def analyze(self, vertices: Sequence[Vector3], faces: Sequence[Face]) -> MeshAnalysis:
        self._validate_vertices(vertices)
        self._validate_faces(vertices, faces)

        edge_use_counts = self._count_edges(faces)
        used_vertices = self._collect_used_vertices(faces)

        boundary_edge_count = sum(1 for count in edge_use_counts.values() if count == 1)
        nonmanifold_edge_count = sum(1 for count in edge_use_counts.values() if count > 2)

        topology = MeshTopologyCounts(
            vertex_count=len(vertices),
            face_count=len(faces),
            edge_count=len(edge_use_counts),
            boundary_edge_count=boundary_edge_count,
            nonmanifold_edge_count=nonmanifold_edge_count,
            isolated_vertex_count=len(vertices) - len(used_vertices),
        )

        return MeshAnalysis(
            bounds=self._calculate_bounds(vertices),
            topology=topology,
            is_empty=len(vertices) == 0 and len(faces) == 0,
            is_closed=len(edge_use_counts) > 0 and boundary_edge_count == 0,
            is_manifold=nonmanifold_edge_count == 0,
            has_degenerate_faces=self._has_degenerate_faces(faces),
        )

    def _validate_vertices(self, vertices: Sequence[Vector3]) -> None:
        for index, vertex in enumerate(vertices):
            if not all(isfinite(value) for value in (vertex.x, vertex.y, vertex.z)):
                raise ValueError(f"Vertex {index} contains a non-finite coordinate.")

    def _validate_faces(self, vertices: Sequence[Vector3], faces: Sequence[Face]) -> None:
        vertex_count = len(vertices)

        for face_index, face in enumerate(faces):
            if len(face) < 3:
                raise ValueError(f"Face {face_index} has fewer than three vertices.")

            for vertex_index in face:
                if vertex_index < 0 or vertex_index >= vertex_count:
                    raise IndexError(
                        f"Face {face_index} references invalid vertex index {vertex_index}."
                    )

    def _calculate_bounds(self, vertices: Sequence[Vector3]) -> MeshBounds | None:
        if not vertices:
            return None

        return MeshBounds(
            minimum=Vector3(
                min(vertex.x for vertex in vertices),
                min(vertex.y for vertex in vertices),
                min(vertex.z for vertex in vertices),
            ),
            maximum=Vector3(
                max(vertex.x for vertex in vertices),
                max(vertex.y for vertex in vertices),
                max(vertex.z for vertex in vertices),
            ),
        )

    def _count_edges(self, faces: Sequence[Face]) -> dict[Edge, int]:
        edge_use_counts: dict[Edge, int] = {}

        for face in faces:
            for index, start in enumerate(face):
                end = face[(index + 1) % len(face)]
                edge: Edge = (start, end) if start <= end else (end, start)
                edge_use_counts[edge] = edge_use_counts.get(edge, 0) + 1

        return edge_use_counts

    def _collect_used_vertices(self, faces: Sequence[Face]) -> set[int]:
        return {vertex_index for face in faces for vertex_index in face}

    def _has_degenerate_faces(self, faces: Sequence[Face]) -> bool:
        return any(len(set(face)) != len(face) for face in faces)

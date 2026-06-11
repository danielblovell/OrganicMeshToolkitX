$ErrorActionPreference = "Stop"

Remove-Item -Recurse -Force "src\organic_mesh_toolkit_x" -ErrorAction SilentlyContinue

New-Item -ItemType Directory -Force -Path "src\omtx\mesh" | Out-Null
New-Item -ItemType Directory -Force -Path "tests\mesh" | Out-Null

@'
from omtx.math.bounding_box import BoundingBox
from omtx.math.line_segment import LineSegment
from omtx.math.plane import Plane
from omtx.math.ray import Ray
from omtx.math.vector3 import Vector3

__all__ = [
    "BoundingBox",
    "LineSegment",
    "Plane",
    "Ray",
    "Vector3",
]
'@ | Set-Content -Encoding UTF8 "src\omtx\math\__init__.py"

@'
"""Mesh analysis tools."""

from omtx.mesh.analyzer import MeshAnalysis, MeshAnalyzer, MeshBounds, MeshTopologyCounts

__all__ = [
    "MeshAnalysis",
    "MeshAnalyzer",
    "MeshBounds",
    "MeshTopologyCounts",
]
'@ | Set-Content -Encoding UTF8 "src\omtx\mesh\__init__.py"

@'
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
'@ | Set-Content -Encoding UTF8 "src\omtx\mesh\analyzer.py"

@'
from __future__ import annotations

import pytest

from omtx.math import Vector3
from omtx.mesh import MeshAnalyzer


def test_empty_mesh_analysis() -> None:
    result = MeshAnalyzer().analyze([], [])

    assert result.is_empty is True
    assert result.bounds is None
    assert result.topology.vertex_count == 0
    assert result.topology.face_count == 0
    assert result.topology.edge_count == 0
    assert result.is_closed is False
    assert result.is_manifold is True


def test_single_triangle_analysis() -> None:
    vertices = [
        Vector3(0.0, 0.0, 0.0),
        Vector3(1.0, 0.0, 0.0),
        Vector3(0.0, 1.0, 0.0),
    ]

    result = MeshAnalyzer().analyze(vertices, [(0, 1, 2)])

    assert result.bounds is not None
    assert result.bounds.minimum == Vector3(0.0, 0.0, 0.0)
    assert result.bounds.maximum == Vector3(1.0, 1.0, 0.0)
    assert result.topology.vertex_count == 3
    assert result.topology.face_count == 1
    assert result.topology.edge_count == 3
    assert result.topology.boundary_edge_count == 3
    assert result.is_closed is False
    assert result.is_manifold is True


def test_closed_tetrahedron_analysis() -> None:
    vertices = [
        Vector3(0.0, 0.0, 0.0),
        Vector3(1.0, 0.0, 0.0),
        Vector3(0.0, 1.0, 0.0),
        Vector3(0.0, 0.0, 1.0),
    ]
    faces = [
        (0, 2, 1),
        (0, 1, 3),
        (1, 2, 3),
        (2, 0, 3),
    ]

    result = MeshAnalyzer().analyze(vertices, faces)

    assert result.topology.edge_count == 6
    assert result.topology.boundary_edge_count == 0
    assert result.topology.nonmanifold_edge_count == 0
    assert result.is_closed is True
    assert result.is_manifold is True


def test_isolated_vertex_is_counted() -> None:
    vertices = [
        Vector3(0.0, 0.0, 0.0),
        Vector3(1.0, 0.0, 0.0),
        Vector3(0.0, 1.0, 0.0),
        Vector3(9.0, 9.0, 9.0),
    ]

    result = MeshAnalyzer().analyze(vertices, [(0, 1, 2)])

    assert result.topology.isolated_vertex_count == 1


def test_degenerate_face_is_detected() -> None:
    vertices = [
        Vector3(0.0, 0.0, 0.0),
        Vector3(1.0, 0.0, 0.0),
        Vector3(0.0, 1.0, 0.0),
    ]

    result = MeshAnalyzer().analyze(vertices, [(0, 1, 1)])

    assert result.has_degenerate_faces is True


def test_face_with_too_few_vertices_raises() -> None:
    vertices = [
        Vector3(0.0, 0.0, 0.0),
        Vector3(1.0, 0.0, 0.0),
    ]

    with pytest.raises(ValueError):
        MeshAnalyzer().analyze(vertices, [(0, 1)])


def test_invalid_face_index_raises() -> None:
    vertices = [
        Vector3(0.0, 0.0, 0.0),
        Vector3(1.0, 0.0, 0.0),
        Vector3(0.0, 1.0, 0.0),
    ]

    with pytest.raises(IndexError):
        MeshAnalyzer().analyze(vertices, [(0, 1, 3)])
'@ | Set-Content -Encoding UTF8 "tests\mesh\test_analyzer.py"

$vectorPath = "src\omtx\math\vector3.py"
$vectorText = Get-Content $vectorPath -Raw
$vectorText = $vectorText.Replace("l = self.length", "vector_length = self.length")
$vectorText = $vectorText.Replace("if l == 0:", "if vector_length == 0:")
$vectorText = $vectorText.Replace(" / l", " / vector_length")
$vectorText = $vectorText.Replace("def as_tuple(self):", "def as_tuple(self) -> tuple[float, float, float]:")
$vectorText = $vectorText.Replace("def __iter__(self):", "def __iter__(self):  # type: ignore[no-untyped-def]")
Set-Content -Encoding UTF8 $vectorPath $vectorText

py -m ruff check . --fix
py -m black .
py -m mypy src
py -m pytest

Write-Host "Commit 000006 Mesh Analyzer files created."
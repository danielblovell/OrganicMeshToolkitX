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

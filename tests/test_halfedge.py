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

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

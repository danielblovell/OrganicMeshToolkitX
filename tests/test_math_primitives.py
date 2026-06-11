from omtx.math import BoundingBox, LineSegment, Plane, Ray, Vector3


def test_bounding_box_expand_and_contains():
    box = BoundingBox.empty()

    box.expand_to_include(Vector3(1, 2, 3))
    box.expand_to_include(Vector3(-1, 5, 0))

    assert box.minimum == Vector3(-1, 2, 0)
    assert box.maximum == Vector3(1, 5, 3)
    assert box.contains(Vector3(0, 3, 1))
    assert not box.contains(Vector3(3, 3, 1))


def test_ray_point_at():
    ray = Ray(origin=Vector3(1, 0, 0), direction=Vector3(2, 0, 0))

    assert ray.point_at(3) == Vector3(4, 0, 0)


def test_plane_signed_distance():
    plane = Plane.from_point_normal(Vector3(0, 0, 5), Vector3(0, 0, 1))

    assert plane.signed_distance_to(Vector3(0, 0, 8)) == 3
    assert plane.signed_distance_to(Vector3(0, 0, 2)) == -3


def test_line_segment():
    segment = LineSegment(Vector3(0, 0, 0), Vector3(2, 0, 0))

    assert segment.length == 2
    assert segment.midpoint == Vector3(1, 0, 0)

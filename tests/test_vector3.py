from omtx.math.vector3 import Vector3


def test_add():

    a = Vector3(1, 2, 3)
    b = Vector3(4, 5, 6)

    c = a + b

    assert c.x == 5
    assert c.y == 7
    assert c.z == 9


def test_dot():

    a = Vector3(1, 0, 0)
    b = Vector3(0, 1, 0)

    assert a.dot(b) == 0


def test_cross():

    a = Vector3(1, 0, 0)
    b = Vector3(0, 1, 0)

    c = a.cross(b)

    assert c == Vector3(0, 0, 1)

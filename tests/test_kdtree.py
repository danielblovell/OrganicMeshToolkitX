from omtx.math.vector3 import Vector3
from omtx.spatial import KDTree


def test_kdtree_count():
    tree = KDTree(
        [
            Vector3(0, 0, 0),
            Vector3(1, 0, 0),
            Vector3(0, 1, 0),
        ]
    )

    assert tree.count == 3


def test_kdtree_nearest():
    points = [
        Vector3(0, 0, 0),
        Vector3(10, 0, 0),
        Vector3(0, 10, 0),
    ]

    tree = KDTree(points)

    result = tree.nearest(Vector3(9, 0, 0))

    assert result is not None
    assert result.index == 1
    assert result.point == Vector3(10, 0, 0)


def test_kdtree_empty():
    tree = KDTree([])

    assert tree.count == 0
    assert tree.nearest(Vector3(0, 0, 0)) is None


def test_kdtree_nearest_n():
    points = [
        Vector3(0, 0, 0),
        Vector3(1, 0, 0),
        Vector3(2, 0, 0),
        Vector3(3, 0, 0),
    ]

    tree = KDTree(points)

    results = tree.nearest_n(Vector3(0, 0, 0), 2)

    assert len(results) == 2
    assert results[0].index == 0
    assert results[1].index == 1

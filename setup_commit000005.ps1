New-Item -ItemType Directory -Force -Path "src\omtx\spatial" | Out-Null
New-Item -ItemType Directory -Force -Path "tools" | Out-Null
New-Item -ItemType Directory -Force -Path "tests" | Out-Null

@'
"""Spatial data structures."""

from omtx.spatial.kdtree import KDTree, KDTreeResult

__all__ = ["KDTree", "KDTreeResult"]
'@ | Set-Content "src\omtx\spatial\__init__.py"

@'
"""KDTree spatial index.

This is a lightweight OMTX-native KDTree implementation.

It avoids Blender dependencies so it can be used in:
- Blender
- command-line processing
- tests
- future standalone tools
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable

from omtx.math.vector3 import Vector3


@dataclass(slots=True)
class KDTreeResult:
    """Nearest-neighbor query result."""

    index: int
    point: Vector3
    distance: float


@dataclass(slots=True)
class _KDNode:
    """Internal KDTree node."""

    index: int
    point: Vector3
    axis: int
    left: _KDNode | None = None
    right: _KDNode | None = None


class KDTree:
    """Simple 3D KDTree for nearest-neighbor queries."""

    def __init__(self, points: Iterable[Vector3]) -> None:
        self.points = list(points)
        indexed_points = list(enumerate(self.points))
        self.root = self._build(indexed_points, depth=0)

    @property
    def count(self) -> int:
        """Return number of stored points."""
        return len(self.points)

    def nearest(self, target: Vector3) -> KDTreeResult | None:
        """Return the nearest point to target."""
        if self.root is None:
            return None

        best: KDTreeResult | None = None

        def search(node: _KDNode | None) -> None:
            nonlocal best

            if node is None:
                return

            distance = target.distance(node.point)

            if best is None or distance < best.distance:
                best = KDTreeResult(
                    index=node.index,
                    point=node.point,
                    distance=distance,
                )

            axis_value_target = self._axis_value(target, node.axis)
            axis_value_node = self._axis_value(node.point, node.axis)

            near_branch = node.left if axis_value_target < axis_value_node else node.right
            far_branch = node.right if axis_value_target < axis_value_node else node.left

            search(near_branch)

            if best is not None:
                if abs(axis_value_target - axis_value_node) < best.distance:
                    search(far_branch)

        search(self.root)

        return best

    def nearest_n(self, target: Vector3, count: int) -> list[KDTreeResult]:
        """Return up to count nearest points to target.

        This first implementation is intentionally simple and robust.
        It will be optimized later.
        """
        if count <= 0:
            return []

        results = [
            KDTreeResult(
                index=i,
                point=point,
                distance=target.distance(point),
            )
            for i, point in enumerate(self.points)
        ]

        results.sort(key=lambda result: result.distance)

        return results[:count]

    def _build(
        self,
        indexed_points: list[tuple[int, Vector3]],
        depth: int,
    ) -> _KDNode | None:
        """Recursively build KDTree."""
        if not indexed_points:
            return None

        axis = depth % 3

        indexed_points.sort(
            key=lambda item: self._axis_value(item[1], axis)
        )

        median = len(indexed_points) // 2
        index, point = indexed_points[median]

        return _KDNode(
            index=index,
            point=point,
            axis=axis,
            left=self._build(indexed_points[:median], depth + 1),
            right=self._build(indexed_points[median + 1 :], depth + 1),
        )

    @staticmethod
    def _axis_value(point: Vector3, axis: int) -> float:
        if axis == 0:
            return point.x

        if axis == 1:
            return point.y

        return point.z
'@ | Set-Content "src\omtx\spatial\kdtree.py"

@'
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
'@ | Set-Content "tests\test_kdtree.py"

@'
pytest
'@ | Set-Content "tools\test.ps1"

@'
ruff check src tests
black --check src tests
mypy src
'@ | Set-Content "tools\lint.ps1"

Write-Host "Commit 000005 KDTree files created."
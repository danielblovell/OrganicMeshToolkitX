"""KDTree spatial index.

This is a lightweight OMTX-native KDTree implementation.

It avoids Blender dependencies so it can be used in:
- Blender
- command-line processing
- tests
- future standalone tools
"""

from __future__ import annotations

from collections.abc import Iterable
from dataclasses import dataclass

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

        indexed_points.sort(key=lambda item: self._axis_value(item[1], axis))

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

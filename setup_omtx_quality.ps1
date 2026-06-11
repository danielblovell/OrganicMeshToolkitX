# OMTX quality tooling setup

# Create folders
New-Item -ItemType Directory -Force -Path ".github\workflows" | Out-Null
New-Item -ItemType Directory -Force -Path "src\omtx" | Out-Null
New-Item -ItemType Directory -Force -Path "tests" | Out-Null

# requirements-dev.txt
@"
black
ruff
pytest
mypy
pre-commit
numpy
scipy
networkx
"@ | Set-Content "requirements-dev.txt"

# pyproject.toml
@"
[build-system]
requires = ["setuptools>=69"]
build-backend = "setuptools.build_meta"

[project]
name = "OrganicMeshToolkitX"
version = "0.0.1a1"
description = "Organic Mesh Toolkit X"
requires-python = ">=3.11"

[tool.black]
line-length = 100
target-version = ["py311"]

[tool.ruff]
line-length = 100
target-version = "py311"

[tool.ruff.lint]
select = ["E", "F", "I", "B", "UP"]

[tool.mypy]
python_version = "3.11"
strict = true
mypy_path = "src"

[tool.pytest.ini_options]
testpaths = ["tests"]
pythonpath = ["src"]
"@ | Set-Content "pyproject.toml"

# pre-commit config
@"
repos:
  - repo: https://github.com/psf/black
    rev: 24.10.0
    hooks:
      - id: black

  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.8.4
    hooks:
      - id: ruff
        args: ["--fix"]
      - id: ruff-format

  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.14.1
    hooks:
      - id: mypy
        args: ["--strict", "--python-version=3.11"]
"@ | Set-Content ".pre-commit-config.yaml"

# GitHub Actions workflow
@"
name: Python Quality Checks

on:
  push:
  pull_request:

jobs:
  quality:
    runs-on: ubuntu-latest

    steps:
      - name: Check out repository
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.11"

      - name: Install development dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements-dev.txt
          pip install -e .

      - name: Run Black
        run: black --check src tests

      - name: Run Ruff
        run: ruff check src tests

      - name: Run mypy
        run: mypy src

      - name: Run pytest
        run: pytest
"@ | Set-Content ".github\workflows\python.yml"

# Basic package files so tooling has something to test
@"
"""Organic Mesh Toolkit X."""
__version__ = "0.0.1a1"
"@ | Set-Content "src\omtx\__init__.py"

@"
def test_import_omtx():
    import omtx

    assert omtx.__version__ == "0.0.1a1"
"@ | Set-Content "tests\test_import.py"

Write-Host "OMTX quality tooling files created."
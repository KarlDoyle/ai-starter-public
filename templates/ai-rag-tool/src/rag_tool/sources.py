from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

ALLOWED_SUFFIXES = {".md", ".markdown", ".txt"}


@dataclass(frozen=True)
class SourceRecord:
    id: str
    title: str
    path: Path


def discover_sources(data_dir: Path) -> list[SourceRecord]:
    if not data_dir.exists():
        return []

    records: list[SourceRecord] = []
    for path in sorted(data_dir.rglob("*")):
        if not path.is_file() or path.suffix.lower() not in ALLOWED_SUFFIXES:
            continue
        records.append(
            SourceRecord(
                id=path.stem,
                title=path.name,
                path=path,
            )
        )
    return records

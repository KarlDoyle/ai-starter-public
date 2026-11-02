from __future__ import annotations

from pathlib import Path

from llama_index.core import SimpleDirectoryReader

from .sources import SourceRecord, discover_sources


def load_documents(data_dir: Path) -> list[object]:
    if not data_dir.exists():
        return []
    return SimpleDirectoryReader(
        input_dir=str(data_dir),
        recursive=True,
    ).load_data()


def load_source_registry(data_dir: Path) -> list[SourceRecord]:
    return discover_sources(data_dir)

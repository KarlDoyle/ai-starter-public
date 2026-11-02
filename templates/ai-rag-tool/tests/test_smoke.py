from pathlib import Path

from rag_tool.ingest import load_source_registry
from rag_tool.query import format_answer, retrieve


def read_jsonl(path: Path):
    lines = path.read_text(encoding="utf-8").strip().splitlines()
    return [line for line in lines if line]


def test_source_registry_detects_markdown(tmp_path: Path):
    notes = tmp_path / "notes.md"
    notes.write_text("# Notes\nLocal context only.\n", encoding="utf-8")

    registry = load_source_registry(tmp_path)
    assert len(registry) == 1
    assert registry[0].title == "notes.md"


def test_retrieval_returns_citations(tmp_path: Path):
    doc = tmp_path / "project.md"
    doc.write_text(
        "# Project\nThis local project uses data and citations.\n",
        encoding="utf-8",
    )

    hits = retrieve("project citations", tmp_path, limit=1)
    assert len(hits) == 1
    assert hits[0].source_id == "project"
    assert "project" in format_answer("project citations", hits)


def test_retrieval_smoke_fixture():
    lines = read_jsonl(Path("evals/retrieval-smoke.jsonl"))
    assert len(lines) == 2
    assert '"id":"sources"' in lines[0]

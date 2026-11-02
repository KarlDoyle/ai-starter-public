from __future__ import annotations

import argparse
import re
from collections import Counter
from collections.abc import Iterable
from dataclasses import dataclass
from pathlib import Path

from .ingest import load_documents, load_source_registry

TOKEN_PATTERN = re.compile(r"[A-Za-z0-9_]+")


@dataclass(frozen=True)
class RetrievalHit:
    source_id: str
    title: str
    path: str
    score: int
    excerpt: str


def _extract_text(document: object) -> str:
    text = getattr(document, "text", None)
    if isinstance(text, str) and text.strip():
        return text

    get_content = getattr(document, "get_content", None)
    if callable(get_content):
        content = get_content()
        if isinstance(content, str) and content.strip():
            return content

    return str(document)


def _tokenize(text: str) -> Counter[str]:
    return Counter(token.lower() for token in TOKEN_PATTERN.findall(text))


def _score_document(query_terms: Counter[str], document_text: str) -> int:
    document_terms = _tokenize(document_text)
    score = 0
    for token, count in query_terms.items():
        score += min(count, document_terms.get(token, 0))
    return score


def retrieve(query: str, data_dir: Path, limit: int = 3) -> list[RetrievalHit]:
    documents = load_documents(data_dir)
    registry = load_source_registry(data_dir)
    if not documents:
        return []

    query_terms = _tokenize(query)
    hits: list[RetrievalHit] = []
    for index, document in enumerate(documents):
        text = _extract_text(document)
        score = _score_document(query_terms, text)
        if score <= 0:
            continue

        source_record = registry[index] if index < len(registry) else None
        metadata = getattr(document, "metadata", {}) or {}
        title = (
            metadata.get("file_name")
            or metadata.get("filename")
            or (source_record.title if source_record else f"source-{index + 1}")
        )
        path = metadata.get("file_path") or (
            str(source_record.path) if source_record else str(title)
        )
        hits.append(
            RetrievalHit(
                source_id=source_record.id if source_record else f"source-{index + 1}",
                title=str(title),
                path=str(path),
                score=score,
                excerpt=text[:280].strip(),
            )
        )

    return sorted(hits, key=lambda item: item.score, reverse=True)[:limit]


def format_answer(query: str, hits: Iterable[RetrievalHit]) -> str:
    hits = list(hits)
    if not hits:
        return f"No local sources matched: {query}"

    lines = [f"Query: {query}", "Sources:"]
    for hit in hits:
        lines.append(f"- [{hit.source_id}] {hit.title} ({hit.path})")
        lines.append(f"  {hit.excerpt}")
    return "\n".join(lines)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(prog="rag-tool")
    parser.add_argument("query", nargs="*", help="Query text to run against local sources.")
    parser.add_argument(
        "--data-dir", default="data", help="Directory containing local source files."
    )
    parser.add_argument("--top-k", type=int, default=3, help="Maximum number of hits to show.")
    args = parser.parse_args(argv)

    query = " ".join(args.query).strip()
    if not query:
        parser.error("a query is required")

    hits = retrieve(query, Path(args.data_dir), limit=args.top_k)
    print(format_answer(query, hits))
    return 0

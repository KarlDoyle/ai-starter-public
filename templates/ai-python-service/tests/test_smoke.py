from pathlib import Path

from app.settings import get_settings, load_prompt_text


def read_jsonl(path: Path):
    lines = path.read_text(encoding="utf-8").strip().splitlines()
    return [line for line in lines if line]


def test_settings_defaults():
    settings = get_settings()
    assert settings.service_name == "ai-python-service"
    assert settings.model == "openai:gpt-4.1-mini"


def test_prompt_file_exists():
    text = load_prompt_text(Path("prompts/system.md"))
    assert "structured" in text


def test_smoke_eval_fixture():
    lines = read_jsonl(Path("evals/smoke.jsonl"))
    assert len(lines) == 2
    assert '"id":"hello"' in lines[0]

from functools import lru_cache
from pathlib import Path

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    service_name: str = "ai-python-service"
    model: str = "openai:gpt-4.1-mini"
    prompt_path: Path = Path("prompts/system.md")


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    return Settings()


def load_prompt_text(path: Path | None = None) -> str:
    prompt_path = path or get_settings().prompt_path
    return prompt_path.read_text(encoding="utf-8").strip()

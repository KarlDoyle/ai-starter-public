from pydantic_ai import Agent

from .settings import Settings, get_settings, load_prompt_text


def build_agent(settings: Settings | None = None) -> Agent:
    resolved = settings or get_settings()
    system_prompt = load_prompt_text(resolved.prompt_path)
    return Agent(
        model=resolved.model,
        system_prompt=system_prompt,
    )

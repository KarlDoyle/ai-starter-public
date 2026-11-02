from __future__ import annotations

import argparse
import sys

from .ai_client import build_agent


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        prog="ai-python-service",
        description="Run the starter Python AI CLI.",
    )
    parser.add_argument("prompt", nargs="*", help="Prompt text to send to the model.")
    args = parser.parse_args(argv)

    prompt = " ".join(args.prompt).strip()
    if not prompt:
        parser.error("a prompt is required")

    agent = build_agent()
    result = agent.run_sync(prompt)
    print(result.data)
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))

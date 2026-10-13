from pathlib import Path
import re


ROOT = Path(__file__).resolve().parents[1]


def test_hypridle_does_not_launch_a_second_session_locker():
    config = (ROOT / "home/dot_config/hypr/hypridle.conf").read_text()
    active_config = "\n".join(
        line for line in config.splitlines() if not line.lstrip().startswith("#")
    )
    actions = [
        line.strip().split("=", 1)[1].strip()
        for line in active_config.splitlines()
        if re.match(r"\s*(?:on-timeout|on-resume|lock_cmd|on_lock_cmd)\s*=", line)
    ]

    assert "Hornero Shell owns idle locking" in config
    assert re.search(r"^\s*listener\s*\{", active_config, re.MULTILINE)
    assert any("dpms off" in action for action in actions)
    assert any("systemctl suspend" in action for action in actions)
    for action in actions:
        assert "hyprlock" not in action
        assert "horneroctl lock" not in action
        assert "horneroctl power lock" not in action
        assert "qs ipc call lock lock" not in action
        assert "loginctl lock-session" not in action

#!/usr/bin/env python3
"""
Read-only usage miner for Claude Code session transcripts.

Scans ~/.claude/projects/*/ for *.jsonl session transcripts, focuses on
project directories whose name starts with the optional argv[1] prefix
(default: every project), and reports which Skills / subagent types /
slash commands / Agent-tool-driven questions are actually used.

A repo's project dir is its absolute path with "/" and "." replaced by "-",
so a repo's prefix also matches its worktrees under <repo>/.worktrees/ - and
any sibling whose name starts the same way (myrepo.Api -> myrepo-Api).

Read-only: never writes to the source data. Prints only aggregate counts -
no transcript excerpts, no user prompt text, no file paths from inside
transcripts, no personal data.

Usage:
    python3 mine_usage.py                            # all projects
    python3 mine_usage.py -Users-me-code-myrepo      # one repo + its worktrees
"""

from __future__ import annotations

import glob
import sys
import json
import os
import re
import statistics
from collections import Counter, defaultdict

HOME = os.path.expanduser("~")
PROJECTS_DIR = os.path.join(HOME, ".claude", "projects")
SCOPE_PREFIX = sys.argv[1] if len(sys.argv) > 1 else ""  # optional project-dir prefix, e.g. "-Users-me-code-myrepo"; empty = all projects

AGENT_TOOL_NAMES = {"Agent", "Task"}
COMMAND_TAG_RE = re.compile(r"<command-name>\s*(/[^\s<]+)")
PLAIN_SLASH_RE = re.compile(r"^\s*(/[A-Za-z][\w:-]*)")


def month_of(ts: str | None) -> str | None:
    """'2026-08-17T13:27:55.679Z' -> '2026-08'. None-safe."""
    if not ts or len(ts) < 7:
        return None
    return ts[:7]


def all_project_dirs() -> list[str]:
    return sorted(d for d in glob.glob(os.path.join(PROJECTS_DIR, "*")) if os.path.isdir(d))


def top_level_sessions(project_dir: str) -> list[str]:
    return sorted(glob.glob(os.path.join(project_dir, "*.jsonl")))


def subagent_sessions(project_dir: str) -> list[str]:
    return sorted(glob.glob(os.path.join(project_dir, "*", "subagents", "*.jsonl")))


def iter_json_lines(path: str):
    """Yield parsed JSON objects, skipping malformed / oversized lines."""
    try:
        with open(path, "r", errors="ignore") as fh:
            for line in fh:
                line = line.strip()
                if not line:
                    continue
                try:
                    yield json.loads(line)
                except (json.JSONDecodeError, ValueError):
                    continue
    except OSError:
        return


def extract_text_fragments(content) -> list[str]:
    """Pull every plain string worth regex-scanning out of a user message's
    content field, which may be a str or a list of content blocks."""
    fragments = []
    if isinstance(content, str):
        fragments.append(content)
    elif isinstance(content, list):
        for block in content:
            if isinstance(block, dict) and block.get("type") == "text":
                text = block.get("text")
                if isinstance(text, str):
                    fragments.append(text)
    return fragments


def extract_slash_commands(content) -> list[str]:
    found = []
    for frag in extract_text_fragments(content):
        tag_matches = COMMAND_TAG_RE.findall(frag)
        if tag_matches:
            found.extend(tag_matches)
            continue
        plain = PLAIN_SLASH_RE.match(frag)
        if plain:
            found.append(plain.group(1))
    return found


class Stats:
    def __init__(self):
        # Skill tool calls
        self.skill_total = Counter()
        self.skill_month = defaultdict(Counter)  # skill -> {month: count}

        # Agent/Task tool calls
        self.agent_total = Counter()
        self.agent_models = defaultdict(set)  # subagent_type -> {models}

        self.workflow_count = 0
        self.artifact_count = 0
        self.artifact_actions = Counter()
        self.askuserq_count = 0
        self.askuserq_month = Counter()
        self.enterworktree_count = 0
        self.enterplan_count = 0
        self.exitplan_count = 0

        self.total_tool_use_blocks = 0

        self.slash_commands = Counter()

        self.turns_per_session = []  # list[int]
        self.sessions_per_month = Counter()

        self.ts_min = None
        self.ts_max = None

        self.main_session_count = 0
        self.subagent_session_count = 0

    def note_ts(self, ts: str | None):
        if not ts:
            return
        if self.ts_min is None or ts < self.ts_min:
            self.ts_min = ts
        if self.ts_max is None or ts > self.ts_max:
            self.ts_max = ts


def process_main_session(path: str, stats: Stats):
    turns = 0
    session_ts_min = None

    for obj in iter_json_lines(path):
        ts = obj.get("timestamp")
        if ts:
            stats.note_ts(ts)
            if session_ts_min is None or ts < session_ts_min:
                session_ts_min = ts

        mtype = obj.get("type")

        if mtype == "assistant":
            turns += 1
            message = obj.get("message") or {}
            content = message.get("content")
            if not isinstance(content, list):
                continue
            for block in content:
                if not isinstance(block, dict) or block.get("type") != "tool_use":
                    continue
                name = block.get("name")
                if not name:
                    continue
                stats.total_tool_use_blocks += 1
                inp = block.get("input") or {}
                if not isinstance(inp, dict):
                    inp = {}
                month = month_of(ts)

                if name == "Skill":
                    skill_name = inp.get("skill") or "(unnamed)"
                    stats.skill_total[skill_name] += 1
                    if month:
                        stats.skill_month[skill_name][month] += 1
                elif name in AGENT_TOOL_NAMES:
                    subtype = inp.get("subagent_type") or "(unspecified)"
                    stats.agent_total[subtype] += 1
                    model = inp.get("model")
                    if model:
                        stats.agent_models[subtype].add(model)
                elif name == "Workflow":
                    stats.workflow_count += 1
                elif name == "Artifact":
                    stats.artifact_count += 1
                    action = inp.get("action") or "publish"
                    stats.artifact_actions[action] += 1
                elif name == "AskUserQuestion":
                    stats.askuserq_count += 1
                    if month:
                        stats.askuserq_month[month] += 1
                elif name == "EnterWorktree":
                    stats.enterworktree_count += 1
                elif name == "EnterPlanMode":
                    stats.enterplan_count += 1
                elif name == "ExitPlanMode":
                    stats.exitplan_count += 1

        elif mtype == "user":
            if obj.get("isSidechain"):
                continue
            message = obj.get("message") or {}
            content = message.get("content")
            for cmd in extract_slash_commands(content):
                stats.slash_commands[cmd] += 1

    stats.turns_per_session.append(turns)
    if session_ts_min:
        m = month_of(session_ts_min)
        if m:
            stats.sessions_per_month[m] += 1


def main():
    all_dirs = all_project_dirs()
    scope_dirs = [d for d in all_dirs if os.path.basename(d).startswith(SCOPE_PREFIX)]

    total_sessions_all_dirs = sum(len(top_level_sessions(d)) for d in all_dirs)

    stats = Stats()

    for d in scope_dirs:
        mains = top_level_sessions(d)
        subs = subagent_sessions(d)
        stats.main_session_count += len(mains)
        stats.subagent_session_count += len(subs)
        for path in mains:
            process_main_session(path, stats)

    # ---------------- report ----------------
    print("=" * 70)
    print("Claude Code usage report")
    print("=" * 70)
    scope = f"project dirs starting with {SCOPE_PREFIX!r}" if SCOPE_PREFIX else "all project dirs"
    print(f"Scope: {scope} ({len(scope_dirs)} of {len(all_dirs)})")
    print(
        f"Sessions analysed: {stats.main_session_count} main "
        f"+ {stats.subagent_session_count} subagent (sidechain, excluded from "
        f"AskUserQuestion/slash-command counts)"
    )
    print(f"Total sessions across ALL ~/.claude/projects dirs (any repo): {total_sessions_all_dirs}")
    date_range = f"{stats.ts_min[:10]} to {stats.ts_max[:10]}" if stats.ts_min and stats.ts_max else "n/a"
    print(f"Date range covered: {date_range}")
    print(f"Total tool_use blocks (main sessions only): {stats.total_tool_use_blocks}")
    print()

    # --- Skills table ---
    print("-" * 70)
    print("SKILLS (Skill tool calls)")
    print("-" * 70)
    print(f"{'skill':45} {'total':>6} {'last used':>10} {'months':>7}")
    for name, total in stats.skill_total.most_common():
        months = stats.skill_month[name]
        last_used = max(months) if months else "n/a"
        n_months = len(months)
        print(f"{name:45} {total:>6} {last_used:>10} {n_months:>7}")
    print()

    # --- Subagent types table ---
    print("-" * 70)
    print("SUBAGENT TYPES (Agent/Task tool calls) — top 30")
    print("-" * 70)
    print(f"{'subagent_type':35} {'total':>6}  models seen")
    for name, total in stats.agent_total.most_common(30):
        models = ", ".join(sorted(stats.agent_models[name])) if stats.agent_models[name] else "n/a"
        print(f"{name:35} {total:>6}  {models}")
    print()

    # --- Slash commands table ---
    print("-" * 70)
    print("SLASH COMMANDS (user-typed) — top 30")
    print("-" * 70)
    print(f"{'command':30} {'total':>6}")
    for name, total in stats.slash_commands.most_common(30):
        print(f"{name:30} {total:>6}")
    print()

    # --- AskUserQuestion per month ---
    print("-" * 70)
    print("ASKUSERQUESTION per month (agent-asked-human signal)")
    print("-" * 70)
    print(f"{'month':10} {'asks':>6} {'sessions':>9} {'asks/session':>13}")
    months_sorted = sorted(set(stats.askuserq_month) | set(stats.sessions_per_month))
    for m in months_sorted:
        asks = stats.askuserq_month.get(m, 0)
        sess = stats.sessions_per_month.get(m, 0)
        ratio = f"{asks / sess:.2f}" if sess else "n/a"
        print(f"{m:10} {asks:>6} {sess:>9} {ratio:>13}")
    print()

    # --- misc counts ---
    print("-" * 70)
    print("OTHER TOOL COUNTS")
    print("-" * 70)
    print(f"Workflow calls:        {stats.workflow_count}")
    print(f"Artifact calls:        {stats.artifact_count}  actions: {dict(stats.artifact_actions)}")
    print(f"EnterWorktree calls:   {stats.enterworktree_count}")
    print(f"EnterPlanMode calls:   {stats.enterplan_count}")
    print(f"ExitPlanMode calls:    {stats.exitplan_count}")
    print()

    median_turns = statistics.median(stats.turns_per_session) if stats.turns_per_session else 0
    print(f"Median assistant turns per session: {median_turns}")
    print()
    print("Sessions per month:")
    for m in sorted(stats.sessions_per_month):
        print(f"  {m}: {stats.sessions_per_month[m]}")
    print()

    # --- observations ---
    print("-" * 70)
    print("OBSERVATIONS")
    print("-" * 70)

    skill_calls_total = sum(stats.skill_total.values())
    top5_skill_calls = sum(c for _, c in stats.skill_total.most_common(5))
    top5_share = (top5_skill_calls / skill_calls_total * 100) if skill_calls_total else 0
    print(f"1. Top 5 skills account for {top5_share:.0f}% of all {skill_calls_total} Skill calls.")

    # "plugin:skill" names come from a plugin; bare names are personal or project skills.
    by_source = Counter()
    for n, c in stats.skill_total.items():
        by_source[n.split(":", 1)[0] if ":" in n else "(personal/project)"] += c
    breakdown = (
        ", ".join(f"{src} {c / skill_calls_total * 100:.0f}%" for src, c in by_source.most_common(5))
        if skill_calls_total
        else "n/a"
    )
    print(f"2. Skill calls by source, top 5: {breakdown}.")

    agent_calls_total = sum(stats.agent_total.values())
    top5_agent_calls = sum(c for _, c in stats.agent_total.most_common(5))
    top5_agent_share = (top5_agent_calls / agent_calls_total * 100) if agent_calls_total else 0
    print(
        f"3. Top 5 subagent types account for {top5_agent_share:.0f}% of all "
        f"{agent_calls_total} Agent/Task calls."
    )

    if len(months_sorted) >= 2:
        first_half = months_sorted[: len(months_sorted) // 2]
        second_half = months_sorted[len(months_sorted) // 2 :]
        first_rate = sum(stats.askuserq_month.get(m, 0) for m in first_half) / max(
            sum(stats.sessions_per_month.get(m, 0) for m in first_half), 1
        )
        second_rate = sum(stats.askuserq_month.get(m, 0) for m in second_half) / max(
            sum(stats.sessions_per_month.get(m, 0) for m in second_half), 1
        )
        trend = "up" if second_rate > first_rate else ("down" if second_rate < first_rate else "flat")
        print(
            f"4. AskUserQuestion rate per session trended {trend}: "
            f"{first_rate:.2f}/session (earlier half) -> {second_rate:.2f}/session (later half)."
        )
    else:
        print("4. Not enough distinct months to compute an AskUserQuestion trend.")

    shape = (
        "mostly direct single-agent dispatch"
        if agent_calls_total > stats.workflow_count
        else "mostly scripted workflows"
        if stats.workflow_count
        else "no orchestration recorded"
    )
    print(
        f"5. Workflow tool used {stats.workflow_count} time(s) vs {agent_calls_total} direct "
        f"Agent/Task calls — {shape}."
    )


if __name__ == "__main__":
    main()

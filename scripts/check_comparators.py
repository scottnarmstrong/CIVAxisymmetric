#!/usr/bin/env python3
# Copyright (c) 2026 Scott Armstrong and Vlad Vicol.
# Released under Apache 2.0 license.
"""Check the comparator Challenge/Solution pair under `comparators/`.

`comparators/AxisymmetricChallenge.lean` states the five main results from Mathlib alone,
with one intentional `sorry` each; `comparators/AxisymmetricSolution.lean` repeats the
same definitions and statements verbatim and proves each theorem by applying
the library's main-result statement. The Solution does not import the Challenge: they
are separate Lean environments, compared by Comparator (see
`scripts/verify_comparator.sh`). This script is the local, source-level
complement to that replay. It checks

  1. `comparator.json` selects exactly the five theorems, with the standard
     axioms and NanoDa enabled;
  2. the Challenge's size (target 500 lines, hard limit 1000 lines and
     100 KiB), that it imports only Mathlib, and that it has exactly one
     `sorry` per selected theorem, each the whole proof of that theorem;
  3. the Solution imports exactly the five statement modules plus the Challenge's
     Mathlib imports, and has no `sorry`, `admit` or `axiom`;
  4. after comments and imports are removed, the Solution is the Challenge
     with each `by sorry` replaced by a direct application of the library's
     main-result theorem: every definition, instance and statement is
     shared verbatim;
  5. each selected statement is byte-identical, after namespace stripping, to
     the library's statement under `CIV/Statements/`;
  6. hygiene: one namespace, no `private`, no `set_option` beyond
     `autoImplicit false`, no internal vocabulary;
  7. (unless --no-build) the Challenge's only diagnostics are the five
     intentional `sorry` warnings, the Solution elaborates silently under
     `-DwarningAsError=true`, and `#print axioms` of each Solution theorem is
     exactly [propext, Classical.choice, Quot.sound].

What this script does NOT check: that the Challenge's definitions are the
paper's. The Solution's proofs type-check only because each Challenge
definition unfolds to the library's, so the Challenge asks the question the
library answers; whether that is the paper's question is for a human reader.

Usage:  python3 scripts/check_comparators.py [--no-build] [--lake]
"""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile

sys.path.insert(0, str(Path(__file__).resolve().parent))
from check_axioms import imported_modules, strip_comments  # noqa: E402

ROOT = Path(__file__).resolve().parents[1]
CHALLENGE = Path("comparators/AxisymmetricChallenge.lean")
SOLUTION = Path("comparators/AxisymmetricSolution.lean")
NAMESPACE = "CIVChallenge"
AXIOMS = ["propext", "Classical.choice", "Quot.sound"]
TARGET_LINE_LIMIT = 500
HARD_LINE_LIMIT = 1000
BYTE_LIMIT = 100 * 1024

# Selected theorem and its statement module under CIV/Statements/.
THEOREMS = [
    ("mainTheorem", "MainTheorem"),
    ("axisymmetricTheorem", "AxisymmetricTheorem"),
    ("meridionalSmallness", "MeridionalSmallnessProp"),
    ("interiorAnalyticity", "InteriorAnalyticity"),
    ("forceUnderCore", "ForceUnderCore"),
]

# Namespace prefixes stripped before the byte comparison with the statements,
# longest first.
PREFIXES = [NAMESPACE + ".", "CKN.Foundation.Parabolic.", "CKN.Main.", "CKN.",
            "CIV."]

FORBIDDEN_WORDS = [
    "pack" + "et", "work" + "er", "camp" + "aign", "aud" + "it",
    "pan" + "ther", "min" + "ion", "br" + "ief",
    "orchestr" + "ator", "rul" + "ing",
]


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ValueError(message)


def read(path: Path) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def normalized(text: str) -> str:
    return " ".join(strip_comments(text).split())


def without_imports(text: str) -> str:
    return re.sub(r"^(?:public[ \t]+)?(?:meta[ \t]+)?import .+\n", "", text, flags=re.M)


def statement(text: str, name: str) -> str:
    """`theorem <name> ... :=`, without `:=`; comment lines dropped."""
    lines = text.splitlines()
    for start, line in enumerate(lines):
        if re.match(rf"^\s*theorem\s+{re.escape(name)}\b", line):
            break
    else:
        raise ValueError(f"statement of {name} not found")
    out: list[str] = []
    for line in lines[start:]:
        if line.lstrip().startswith("--"):
            continue
        out.append(line.rstrip())
        if out[-1].endswith(":="):
            out[-1] = out[-1][: -len(":=")].rstrip()
            return re.sub(r"^\s*theorem\s+", "theorem ", "\n".join(out))
    raise ValueError(f"statement of {name} is not terminated by `:=`")


def proof(text: str, name: str) -> str:
    """The proof term following the statement of `name`, up to the next blank line."""
    start = text.index(":=", text.index(f"theorem {name}")) + 2
    rest = text[start:]
    end = re.search(r"\n\s*\n", rest)
    return " ".join(strip_comments(rest[: end.start() if end else len(rest)]).split())


def strip_namespaces(text: str) -> str:
    for prefix in sorted(PREFIXES, key=len, reverse=True):
        text = text.replace(prefix, "")
    return text


def check_sources() -> None:
    names = [name for name, _ in THEOREMS]
    config = json.loads(read(Path("comparator.json")))
    require(config == {
        "challenge_module": "comparators.AxisymmetricChallenge",
        "solution_module": "comparators.AxisymmetricSolution",
        "theorem_names": [f"{NAMESPACE}.{name}" for name in names],
        "definition_names": [], "permitted_axioms": AXIOMS, "enable_nanoda": True,
    }, "comparator.json does not select exactly the five main theorems "
       "with the standard axioms and NanoDa")

    challenge, solution = read(CHALLENGE), read(SOLUTION)
    n_lines = len(challenge.splitlines())
    status = ("within target" if n_lines < TARGET_LINE_LIMIT else "over target")
    print(f"Challenge: {n_lines} lines, {len(challenge.encode())} bytes "
          f"(target < {TARGET_LINE_LIMIT}, hard <= {HARD_LINE_LIMIT} lines, "
          f"<= {BYTE_LIMIT} bytes) -- {status}")
    print(f"Solution:  {len(solution.splitlines())} lines")
    require(n_lines <= HARD_LINE_LIMIT and len(challenge.encode()) <= BYTE_LIMIT,
            "Challenge exceeds the 1000-line or 100-KiB limit")

    require(len(re.findall(r"\bsorry\b", strip_comments(challenge))) == len(names),
            f"Challenge must have exactly {len(names)} intentional `sorry`s")
    for name in names:
        require(proof(challenge, name) == "by sorry",
                f"Challenge proof of {name} is not exactly `by sorry`")
    require(not re.search(r"\b(?:sorry|admit|axiom|constant|sorryAx)\b",
                          strip_comments(solution)),
            "Solution contains a placeholder or axiom declaration")

    for text, label in [(challenge, "Challenge"), (solution, "Solution")]:
        require(re.findall(r"^namespace (\S+)", text, re.M) == [NAMESPACE],
                f"{label} must use the single namespace {NAMESPACE}")
        require(not re.search(r"^\s*private\b", strip_comments(text), re.M),
                f"{label} has private declaration names")
        require(all(option.strip() == "autoImplicit false" for option in
                    re.findall(r"^\s*set_option (.+)$", text, re.M)),
                f"{label} sets an unexpected Lean option")
        require(strip_comments(text).split()[:1] == ["module"],
                f"{label} must start with a `module` header")
        hits = sorted({w for w in FORBIDDEN_WORDS
                       if re.search(rf"\b{w}", text, flags=re.I)})
        require(not hits, f"{label} contains internal vocabulary: {hits}")

    imports = imported_modules(challenge)
    stray = re.findall(r"^[ \t]*(?:(?:public|meta)[ \t]+)*import\b",
                       strip_comments(challenge), re.M)
    require(len(stray) == len(imports), "Challenge has an unrecognized import form")
    require(imports and all(m == "Mathlib" or m.startswith("Mathlib.")
                            for m in imports),
            "Challenge must import only Mathlib")
    anchors = [f"CIV.Statements.{module}" for _, module in THEOREMS]
    require(imported_modules(solution) == anchors + imports,
            "Solution must import the five statement modules and the Challenge's "
            "Mathlib imports, never the Challenge")

    # Every definition, instance and statement is shared verbatim; the only
    # code differences are the imports and the five proof terms, each a direct
    # application of the library theorem to the statement's binders.
    expected = without_imports(challenge)
    for name in names:
        term = proof(solution, name)
        require(re.fullmatch(rf"CIV\.{name}(?: [^\s()]+)*", term) is not None,
                f"Solution proof of {name} is not a direct application of "
                f"CIV.{name}: {term!r}")
        start = expected.index(f"theorem {name} ")
        at = expected.index("by sorry", start)
        expected = expected[:at] + term + expected[at + len("by sorry"):]
    require(normalized(expected) == normalized(without_imports(solution)),
            "Challenge/Solution definitions, instances or statements differ")
    print("Solution = Challenge with the five placeholders replaced by the "
          "library theorems.")

    for name, module in THEOREMS:
        anchor = read(Path(f"CIV/Statements/{module}.lean"))
        a = strip_namespaces(statement(anchor, name))
        c = strip_namespaces(statement(challenge, name))
        s = strip_namespaces(statement(solution, name))
        require(c == a, f"Challenge statement of {name} differs from "
                        f"CIV/Statements/{module}.lean")
        require(s == a, f"Solution statement of {name} differs from "
                        f"CIV/Statements/{module}.lean")
        print(f"  {name}: byte-identical to CIV/Statements/{module}.lean "
              f"({len(a.encode())} bytes)")


def lean(path: Path, *args: str, extra_path: Path | None = None) -> tuple[int, str]:
    env = dict(os.environ)
    env.setdefault("CIV_LEAN_SLOTS", "3")
    if extra_path is not None:
        env["CIV_EXTRA_LEAN_PATH"] = str(extra_path)
    proc = subprocess.run([str(ROOT / "scripts/lean_direct.sh"), str(path),
                           "-DautoImplicit=false", *args], cwd=ROOT, env=env,
                          capture_output=True, text=True)
    return proc.returncode, (proc.stdout + proc.stderr).strip()


def check_proofs() -> None:
    names = [name for name, _ in THEOREMS]
    with tempfile.TemporaryDirectory(prefix="civ-comparator-") as tmp:
        staging = Path(tmp)
        (staging / "comparators").mkdir()

        rc, out = lean(CHALLENGE)
        lines = [ln for ln in out.splitlines() if ln.strip()]
        require(rc == 0 and len(lines) == len(names) and all(
            ln.startswith(f"{CHALLENGE}:")
            and ln.endswith("warning: declaration uses `sorry`") for ln in lines),
            f"Unexpected Challenge diagnostics (rc {rc}): {lines}")
        rc, out = lean(CHALLENGE, "-DwarningAsError=true")
        lines = [ln for ln in out.splitlines() if ln.strip()]
        require(len(lines) == len(names) and all(
            "declaration uses `sorry`" in ln for ln in lines),
            f"Unexpected Challenge diagnostics under warningAsError: {lines}")
        print(f"Challenge: the only diagnostics are the {len(names)} "
              "intentional `sorry`s.")

        rc, out = lean(SOLUTION, "-DwarningAsError=true",
                       "-o", str(staging / "comparators/AxisymmetricSolution.olean"))
        require(rc == 0 and not out, f"Unexpected Solution diagnostics (rc {rc}): {out}")
        print("Solution: elaborates silently under "
              "-DautoImplicit=false -DwarningAsError=true.")

        probe = staging / "Axioms.lean"
        probe.write_text("import comparators.AxisymmetricSolution\n" + "".join(
            f"#print axioms {NAMESPACE}.{name}\n" for name in names))
        rc, out = lean(probe, "-DwarningAsError=true", extra_path=staging)
        expected = [f"'{NAMESPACE}.{name}' depends on axioms: "
                    "[propext, Classical.choice, Quot.sound]" for name in names]
        require(rc == 0 and out.splitlines() == expected,
                f"Unexpected Solution axioms: {out}")
        for line in expected:
            print(f"  {line}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--no-build", action="store_true",
                        help="source checks only")
    parser.add_argument("--lake", action="store_true",
                        help="also build the Comparators target through "
                             "scripts/build.py")
    args = parser.parse_args()
    try:
        check_sources()
        if not args.no_build:
            if args.lake:
                subprocess.run([sys.executable, "scripts/build.py", "Comparators"],
                               cwd=ROOT, check=True)
            check_proofs()
    except (ValueError, OSError, subprocess.CalledProcessError) as error:
        print(f"Comparator check failed: {error}")
        return 1
    print("Not checked here: that the Challenge's definitions are the paper's.")
    print("All local comparator checks passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

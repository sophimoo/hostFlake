#!/usr/bin/env python3
"""
Nix System Cleanup Tool
A polished CLI tool for Nix garbage collection and optimization.
"""

import subprocess
import sys
import re
import argparse
import time
import threading
from typing import List, Tuple, Optional

# ANSI Color Codes
class Style:
    BLUE = "\033[94m"
    GREEN = "\033[92m"
    YELLOW = "\033[93m"
    RED = "\033[91m"
    BOLD = "\033[1m"
    DIM = "\033[2m"
    RESET = "\033[0m"
    CLEAR_LINE = "\033[K"

class Spinner:
    def __init__(self, message="Working..."):
        self.message = message
        self.frames = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
        self.finished = False
        self.thread = None

    def _spin(self):
        idx = 0
        while not self.finished:
            frame = self.frames[idx % len(self.frames)]
            sys.stdout.write(f"\r  {Style.BLUE}{frame}{Style.RESET} {self.message}")
            sys.stdout.flush()
            idx += 1
            time.sleep(0.1)

    def start(self):
        self.finished = False
        self.thread = threading.Thread(target=self._spin)
        self.thread.daemon = True
        self.thread.start()

    def stop(self, status_msg="done"):
        self.finished = True
        if self.thread:
            self.thread.join()
        sys.stdout.write(f"\r{Style.CLEAR_LINE}  {status_msg}\n")
        sys.stdout.flush()

class CommandResult:
    def __init__(self, description: str, freed_mib: float = 0.0, paths_deleted: int = 0,
                 hard_link_savings: float = 0.0, success: bool = True, error: str = ""):
        self.description = description
        self.freed_mib = freed_mib
        self.paths_deleted = paths_deleted
        self.hard_link_savings = hard_link_savings
        self.success = success
        self.error = error

def parse_output(output: str) -> Tuple[float, int, float]:
    freed_mib = 0.0
    paths_deleted = 0
    hard_link_savings = 0.0

    hl_match = re.search(r'note: currently hard linking saves ([\d.]+) MiB', output)
    if hl_match:
        hard_link_savings = float(hl_match.group(1))

    del_match = re.search(r'(\d+) store paths deleted, ([\d.]+) MiB freed', output)
    if del_match:
        paths_deleted = int(del_match.group(1))
        freed_mib = float(del_match.group(2))

    return freed_mib, paths_deleted, hard_link_savings

def run_task(cmd: List[str], description: str, verbose: bool = False) -> CommandResult:
    spinner = Spinner(f"{description}...")
    spinner.start()

    try:
        result = subprocess.run(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            check=False
        )

        if result.returncode == 0:
            status = f"{Style.GREEN}✔{Style.RESET} {description}"
        else:
            status = f"{Style.RED}✘{Style.RESET} {description} (Failed)"

        spinner.stop(status)

        if verbose and result.stdout:
            for line in result.stdout.splitlines():
                print(f"      {Style.DIM}{line}{Style.RESET}")

        freed_mib, paths_deleted, hard_link_savings = parse_output(result.stdout)

        return CommandResult(
            description=description,
            freed_mib=freed_mib,
            paths_deleted=paths_deleted,
            hard_link_savings=hard_link_savings,
            success=result.returncode == 0,
            error=result.stdout if result.returncode != 0 else ""
        )

    except Exception as e:
        spinner.stop(f"{Style.RED}✘{Style.RESET} {description} (Error)")
        return CommandResult(description=description, success=False, error=str(e))

def main():
    parser = argparse.ArgumentParser(description="Nix System Cleanup Tool")
    parser.add_argument('-v', '--verbose', action='store_true', help='Show full output')
    args = parser.parse_args()

    print(f"\n{Style.BOLD}Nix System Cleanup{Style.RESET}")
    print(f"{Style.DIM}Note: Sudo tasks may prompt for your password.{Style.RESET}\n")

    tasks = [
        (['nix-collect-garbage', '-d'], "User: Delete old generations"),
        (['sudo', 'nix-collect-garbage', '-d'], "System: Delete old generations"),
        (['nix-store', '--gc'], "User: Garbage collection"),
        (['sudo', 'nix-store', '--gc'], "System: Garbage collection"),
        (['nix-store', '--optimise'], "User: Optimise store"),
        (['sudo', 'nix-store', '--optimise'], "System: Optimise store"),
    ]

    results = []
    for cmd, desc in tasks:
        results.append(run_task(cmd, desc, args.verbose))

    # Totals
    total_freed = sum(r.freed_mib for r in results)
    total_paths = sum(r.paths_deleted for r in results)
    max_savings = max((r.hard_link_savings for r in results), default=0.0)

    # Pretty Summary Table
    print(f"\n{Style.BOLD}┌─ Cleanup Summary ──────────────────────────────────┐{Style.RESET}")

    fmt_row = "│ {:<36} {:>12}  │"

    print(fmt_row.format("Paths Deleted:", f"{total_paths}"))
    print(fmt_row.format("Space Recovered:", f"{total_freed:.2f} MiB"))

    if max_savings > 0:
        print(fmt_row.format("Currently hard linking", f"{max_savings:.2f} MiB"))

    print(f"{Style.BOLD}└────────────────────────────────────────────────────┘{Style.RESET}")

    errors = [r for r in results if not r.success]
    if errors:
        print(f"\n{Style.YELLOW}{Style.BOLD}Warnings/Errors:{Style.RESET}")
        for err in errors:
            print(f"  • {err.description}: {Style.DIM}{err.error.strip()[:100]}...{Style.RESET}")

    print(f"\n{Style.GREEN}{Style.BOLD}Done!{Style.RESET}\n")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print(f"\n\n{Style.RED}Cleanup cancelled by user.{Style.RESET}")
        sys.exit(1)

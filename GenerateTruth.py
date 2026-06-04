# GenerateTruth.py
# Created by AI

import json
import msgpack
import sys

from pathlib import Path

# Paths
TIMING_DIR = Path('Timings')
BASE_TIMING_FILE = TIMING_DIR / 'base.txt'
TRUTH_TIMING_FILE = TIMING_DIR / 'truth.txt'


def load_data(path: Path) -> dict:
    """Load msgpack data from a file, returning an empty dict if file is missing or invalid."""
    if not path.exists() or path.stat().st_size == 0:
        return {}

    try:
        with path.open('rb') as f:
            return msgpack.load(f, raw=False)
    except (msgpack.exceptions.UnpackException, FileNotFoundError):
        return {}


def save_data(data: dict, path: Path) -> None:
    """Save data as msgpack to a file."""
    with path.open('wb') as f:
        msgpack.dump(data, f)


def get_timing_key(timing: dict, container_name: str):
    """Get a unique key for a timing entry based on its container type."""
    if container_name == 'part':
        return timing.get('pname')
    # Animation, sound & effect use _id; fallback to name if missing
    return timing.get('_id') or timing.get('name')


def list_patches_sorted() -> list[tuple[str, dict]]:
    """Return all patch files in the timing directory, sorted chronologically."""
    patches = []

    for f in TIMING_DIR.glob('patch_*.json'):
        try:
            data = json.loads(f.read_text(encoding='utf-8'))
            ts = data.get('timestamp')
            if ts:
                patches.append((ts, data))
        except (json.JSONDecodeError, FileNotFoundError):
            continue

    patches.sort(key=lambda p: p[0])
    return patches


def apply_patch(base_data: dict, patch_data: dict) -> dict:
    """Applies a patch to the base data."""
    for container, timings in patch_data.get('diff', {}).items():
        if container not in base_data:
            base_data[container] = []

        timings_map = {get_timing_key(t, container): t for t in base_data[container]}

        for key, change in timings.items():
            status = change['status']

            if status == 'added':
                base_data[container].append(change['data'])
            elif status == 'removed':
                base_data[container] = [t for t in base_data[container] if get_timing_key(t, container) != key]
            elif status == 'modified':
                if key in timings_map:
                    for field, values in change.get('changes', {}).items():
                        timings_map[key][field] = values['to']

    return base_data


def generate_truth() -> None:
    """Generate truth.txt by applying all patches on top of base.txt."""
    if not BASE_TIMING_FILE.exists():
        print(f"Error: base file not found: {BASE_TIMING_FILE}", file=sys.stderr)
        sys.exit(1)

    base = load_data(BASE_TIMING_FILE)
    patches = list_patches_sorted()

    if not patches:
        print("Warning: no patch files found. truth.txt will mirror base.txt.")

    current = base
    for ts, patch in patches:
        current = apply_patch(current, patch)

    TIMING_DIR.mkdir(parents=True, exist_ok=True)
    save_data(current, TRUTH_TIMING_FILE)

    print(f"Applied {len(patches)} patch(es).")
    print(f"Wrote: {TRUTH_TIMING_FILE}")


# Only run if executed as a script
if __name__ == '__main__':
    generate_truth()
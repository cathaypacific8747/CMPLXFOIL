#!/usr/bin/env python3
"""Script to print the version from __init__.py, for use in Meson."""

import re
from pathlib import Path

with open(Path(__file__).parent / "__init__.py") as f:
    __version__ = re.findall(
        r"""__version__ = ["']+([0-9\.]*)["']+""",
        f.read(),
    )[0]

if __name__ == "__main__":
    print(__version__)

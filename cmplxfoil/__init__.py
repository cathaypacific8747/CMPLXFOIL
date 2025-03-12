from ._version import __version__
from .CMPLXFOIL import CMPLXFOIL

__all__ = ["__version__", "CMPLXFOIL"]

try:
    from .postprocess import AnimateAirfoilOpt
except ImportError:
    pass
else:
    __all__ += ["AnimateAirfoilOpt"]

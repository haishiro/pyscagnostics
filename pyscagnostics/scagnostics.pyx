#distutils: language=c++
#cython: language_level=3
#cython: binding=True

cimport pyscagnostics.scagnostics as scag
import numpy as np

MEASURE_NAMES = [
    "Outlying",
    "Skewed",
    "Clumpy",
    "Sparse",
    "Striated",
    "Convex",
    "Skinny",
    "Stringy",
    "Monotonic"
]

def scagnostics(*args, bins=50, remove_outliers=True):
    """Compute scatterplot diagnostic (scagnostic) measures

    Args:
        *args:
            x, y: Lists or numpy arrays
            df: A Pandas DataFrame
        bins: Max number of bins on the x-axis
        remove_outliers: If True, will remove outliers before calculations

    Returns:
        (measures, bins)

        measures is a dict with scores for each of 9 scagnostic measures
        bins is a 3 x n numpy array of x, y, and counts for the hex-bin grid
    """
    if len(args) == 2:
        x, y = args
        if not isinstance(x, (list, np.ndarray)):
            raise ValueError("Unsupported data type: {}".format(type(x)))
        elif not isinstance(y, (list, np.ndarray)):
            raise ValueError("Unsupported data type: {}".format(type(y)))
        else:
            x = np.fromiter(x, dtype=np.double)
            y = np.fromiter(y, dtype=np.double)
    elif len(args) == 1:
        raise NotImplementedError("Pandas DataFrames are not yet supported")
    else:
        raise ValueError("Accepted input formats are either a single Pandas DataFrame or 2 arrays")

    if x.shape != y.shape:
        raise ValueError("x and y must have the same shape")

    complete = (~np.isnan(x) & ~np.isnan(y))
    x = x[complete]
    y = y[complete]

    x = (x - x.min()) / (x.max() - x.min())
    y = (y - y.min()) / (y.max() - y.min())

    cdef double[:] c_x = x
    cdef double[:] c_y = y
    cdef int[:] c_length = np.array([x.shape[0]], dtype=np.int)
    cdef int[:] c_bins = np.array([bins], dtype=np.int)
    cdef int[:] c_outlierRmv = np.array([int(remove_outliers)], dtype=np.int)
    cdef double[:] c_results = np.zeros(9 + 3 * 1000, dtype=np.double)

    scag.c_scagnostics(c_x, c_y, c_length, c_bins, c_outlierRmv, c_results)
    result = np.asarray(c_results)

    n = int(result[9])
    s = result[:9]
    measures = {m[0]: m[1] for m in zip(MEASURE_NAMES, s)}
    bins = result[10:(10 + n * 3)].reshape((3, -1))
    
    return measures, bins

# distutils: language=c++
# cython: language_level=3
# cython: binding=True

from typing import Union, Tuple
from itertools import combinations

cimport pyscagnostics.scagnostics as scag
import numpy as np

measure_names = [
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


def scagnostics(
    *args,
    bins: int=50,
    remove_outliers: bool=True
) -> Tuple[dict, np.ndarray]:
    """Scatterplot diagnostic (scagnostic) measures

    Scagnostics describe various measures of interest for pairs of variables,
    based on their appearance on a scatterplot.  They are useful tool for
    discovering interesting or unusual scatterplots from a scatterplot matrix,
    without having to look at every individual plot.

    Example:
        `scagnostics` can take an x, y pair of iterables (e.g. lists or NumPy arrays):
        ```
            from pyscagnostics import scagnostics
            import numpy as np

            # Simulate data for example
            x = np.random.uniform(0, 1, 100)
            y = np.random.uniform(0, 1, 100)

            measures, bins = pyscagnostics.scagnostics(x, y)
        ```

        A Pandas DataFrame can also be passed as the singular required argument. The
        output will be a generator of results:
        ```
            from pyscagnostics import scagnostics
            import numpy as np
            import pandas as pd

            # Simulate data for example
            x = np.random.uniform(0, 1, 100)
            y = np.random.uniform(0, 1, 100)
            z = np.random.uniform(0, 1, 100)
            df = pd.DataFrame({
                'x': x,
                'y': y,
                'z': z
            })

            results = pyscagnostics.scagnostics(df)
            for measures, bins in results:
                print(measures)
        ```

    Args:
        *args:
            x, y: Lists or numpy arrays
            df: A Pandas DataFrame
        bins: Max number of bins for the hexagonal grid axis
            The data are internally binned starting with a (bins x bins) hexagonal grid
            and re-binned with smaller bin sizes until less than 250 empty bins remain.
        remove_outliers: If True, will remove outliers before calculations

    Returns:
        (measures, bins)
            measures is a dict with scores for each of 9 scagnostic measures.
                See pyscagnostics.measure_names for a list of measures

            bins is a 3 x n numpy array of x-coordinates, y-coordinates, and
                counts for the hex-bin grid. The x and y coordinates are re-scaled
                between 0 and 1000. This is returned for debugging and inspection purposes.

        If the input is a DataFrame, the output will be a generator yielding scagnostics
        for each combination of column pairs
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

            return _scagnostic_xy(
                x,
                y,
                bins=bins,
                remove_outliers=remove_outliers
            )
    elif len(args) == 1:
        df = args[0]
        try:
            col_pairs = combinations(df.columns, 2)

            return (
                _scagnostic_xy(
                    df[x].to_numpy(),
                    df[y].to_numpy(),
                    bins=bins,
                    remove_outliers=remove_outliers
                )
                for x, y in col_pairs
            )
        except AttributeError:
            raise ValueError(f"Expected a DataFrame object but couldn't find the .columns attribute in {type(df)}")
    else:
        raise ValueError("Accepted input formats are either a single Pandas DataFrame or 2 arrays")


def _scagnostic_xy(
    x: Union[list, np.ndarray],
    y: Union[list, np.ndarray],
    bins: int=50,
    remove_outliers: bool=True
) -> Tuple[dict, np.ndarray]:
    """Compute scagnostics for an x, y pair of numeric data

    Args:
        x: List or numpy array
        y: List or numpy array
        bins: Max number of bins for the hexagonal grid axis
            The data are internally binned starting with a (bins x bins) hexagonal grid
            and re-binned with smaller bin sizes until less than 250 empty bins remain.
        remove_outliers: If True, will remove outliers before calculations

    Returns:
        (measures, bins)
            measures is a dict with scores for each of 9 scagnostic measures.
                See pyscagnostics.measure_names for a list of measures

            bins is a 3 x n numpy array of x-coordinates, y-coordinates, and
                counts for the hex-bin grid. The x and y coordinates are re-scaled
                between 0 and 1000. This is returned for debugging and inspection purposes.
    """

    if x.shape != y.shape:
        raise ValueError("x and y must have the same shape")

    complete = (~np.isnan(x) & ~np.isnan(y))
    x = x[complete]
    y = y[complete]

    x = (x - x.min()) / (x.max() - x.min())
    y = (y - y.min()) / (y.max() - y.min())

    cdef double[:] c_x = x
    cdef double[:] c_y = y
    cdef int[:] c_length = np.array([x.shape[0]], dtype=np.int32)
    cdef int[:] c_bins = np.array([bins], dtype=np.int32)
    cdef int[:] c_outlierRmv = np.array([int(remove_outliers)], dtype=np.int32)
    cdef double[:] c_results = np.zeros(9 + 3 * 1000, dtype=np.double)

    scag.c_scagnostics(c_x, c_y, c_length, c_bins, c_outlierRmv, c_results)
    result = np.asarray(c_results)

    n = int(result[9])
    s = result[:9]
    measures = {m[0]: m[1] for m in zip(measure_names, s)}
    bins = result[10:(10 + n * 3)].reshape((3, -1))

    return measures, bins

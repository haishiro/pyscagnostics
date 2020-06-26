# pyscagnostics

Python wrapper for computing graph theoretic scatterplot diagnostics. 

>Scagnostics describe various measures of interest for pairs of variables, based on their appearance on a scatterplot.  They are useful tool for discovering interesting or unusual scatterplots from a scatterplot matrix, without having to look at every individual plot.

> Wilkinson L., Anand, A., and Grossman, R. (2006). High-Dimensional visual analytics: Interactive exploration guided by pairwise views of point distributions. IEEE Transactions on Visualization and Computer Graphics, November/December 2006 (Vol. 12, No. 6) pp. 1363-1372.

# Installation
```
pip install pyscagnostics
```

# Usage
```python
from pyscagnostics import scagnostics

# Using NumPy arrays or lists
measures, _ = scagnostics(x, y)
print(measures)

# Using Pandas DataFrame
all_measures = scagnostics(df)
for measures, _ in all_measures:
    print(measures)
```

# Documentation
```python
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
```
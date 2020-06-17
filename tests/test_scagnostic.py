import numpy as np
import pandas as pd
import pytest
import pyscagnostics


def test_numpy_arrays():
    np.random.seed(1)
    x = np.random.uniform(0, 1, 100)
    y = np.random.uniform(0, 1, 100)
    m, bins = pyscagnostics.scagnostics(x, y)
    assert isinstance(m, dict)
    assert len(m.keys()) == 9
    assert isinstance(bins, np.ndarray)


def test_keep_outliers():
    np.random.seed(1)
    x = np.random.uniform(0, 1, 100)
    y = np.random.uniform(0, 1, 100)
    m, bins = pyscagnostics.scagnostics(x, y, remove_outliers=False)
    assert isinstance(m, dict)
    assert len(m.keys()) == 9
    assert isinstance(bins, np.ndarray)


def test_pandas_dataframe():
    np.random.seed(1)
    x = np.random.uniform(0, 1, 100)
    y = np.random.uniform(0, 1, 100)
    with pytest.raises(NotImplementedError):
        pyscagnostics.scagnostics(pd.DataFrame({"x": x, "y": y}))


if __name__ == "__main__":
    test_numpy_arrays()

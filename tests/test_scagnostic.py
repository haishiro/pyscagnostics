from math import factorial

import pytest
import numpy as np
import pandas as pd

import pyscagnostics


def test_numpy_result_properties():
    np.random.seed(1)
    x = np.random.uniform(0, 1, 100)
    y = np.random.uniform(0, 1, 100)
    m, bins = pyscagnostics.scagnostics(x, y)
    assert isinstance(m, dict)
    assert len(m.keys()) == 9
    assert isinstance(bins, np.ndarray)


def test_numpy_keep_outliers():
    np.random.seed(1)
    x = np.random.uniform(0, 1, 100)
    y = np.random.uniform(0, 1, 100)
    m, bins = pyscagnostics.scagnostics(x, y, remove_outliers=False)
    assert isinstance(m, dict)
    assert len(m.keys()) == 9
    assert isinstance(bins, np.ndarray)


def test_list_result_properties():
    np.random.seed(1)
    x = list(np.random.uniform(0, 1, 100))
    y = list(np.random.uniform(0, 1, 100))
    m, bins = pyscagnostics.scagnostics(x, y)
    assert isinstance(m, dict), "metric scores is not a dictionary"
    assert len(m.keys()) == 9, "scores dict does not have exactly 9 metrics"
    assert isinstance(bins, np.ndarray), "binned data is not a numpy array"


@pytest.fixture
def test_pandas_input():
    np.random.seed(1)
    x = np.random.uniform(0, 1, 100)
    y = np.random.uniform(0, 1, 100)
    z = np.random.uniform(0, 1, 100)
    df = pd.DataFrame({"x": x, "y": y, "z": z})
    results = pyscagnostics.scagnostics(df)
    return results, df.shape[1]


def test_pandas_result_is_generator(test_pandas_input):
    results = test_pandas_input[0]
    # ???
    # assert isinstance(results, GeneratorType), "function did not yield a generator"
    assert results.__name__ == "genexpr", "function did not return a generator"


def test_pandas_result_shape(test_pandas_input):
    list_results = list(test_pandas_input[0])
    df_shape = test_pandas_input[1]

    # Python 3.8+: math.comb
    def nCr(n, r):
        f = factorial
        return f(n) // f(r) // f(n - r)

    assert len(list_results) == nCr(
        df_shape, 2
    ), "size did not match expected combinations of column pairs"


def test_pandas_result_properties(test_pandas_input):
    results = test_pandas_input[0]
    for result in results:
        m, bins = result
        assert isinstance(m, dict), "metric scores is not a dictionary"
        assert len(m.keys()) == 9, "scores dict does not have exactly 9 metrics"
        assert isinstance(bins, np.ndarray), "binned data is not a numpy array"

import glob
import os

try:
    from Cython.Build import cythonize

    USE_CYTHON = True
except ModuleNotFoundError:
    USE_CYTHON = False

import numpy as np
from setuptools import find_packages, setup
from setuptools.extension import Extension


NAME = "pyscagnostics"
DESCRIPTION = "Graph theoretic scatterplot diagnostics"
URL = "https://github.com/haishiro/pyscagnostics"
REQUIRES_PYTHON = ">=3.7.0"
VERSION = "0.1.0"

REQUIRED = [
    "numpy>=1.18.1",
]

package_dir = "pyscagnostics"
ext = ".pyx" if USE_CYTHON else ".cpp"
extensions = [
    Extension(
        name="scagnostics",
        language="c++",
        sources=[os.path.join(package_dir, "scagnostics" + ext),],
        include_dirs=[np.get_include(), *glob.glob(package_dir + "/lib/*/cpp")],
        define_macros=[("NPY_NO_DEPRECATED_API", "NPY_1_7_API_VERSION")],
    )
]
if USE_CYTHON:
    extensions = cythonize(extensions)

# Where the magic happens:
setup(
    name=NAME,
    version=VERSION,
    description=DESCRIPTION,
    python_requires=REQUIRES_PYTHON,
    url=URL,
    install_requires=REQUIRED,
    include_package_data=True,
    license="GPL",
    ext_modules=extensions,
    packages=find_packages(exclude=["tests", "*.tests", "*.tests.*", "tests.*"]),
    classifiers=[
        "Development Status :: 3 - Alpha",
        "License :: OSI Approved :: GNU General Public License (GPL)",
        "Topic :: Scientific/Engineering :: Information Analysis",
        "Programming Language :: Python",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.7",
        "Programming Language :: Python :: Implementation :: CPython",
        "Programming Language :: Python :: Implementation :: PyPy",
    ],
)

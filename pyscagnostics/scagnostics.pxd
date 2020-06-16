#distutils: language=c++
#cython: language_level=3

import numpy as np
cimport numpy as np

cdef extern from "lib/scag.cpp":
    void scagnostics(double* x, double* y, int* length, int* bins, int* outlierRmv, double* results)

cdef extern from "lib/Binner.cpp":
    cdef cppclass Binner:
        Binner() except +
        BinnedData binHex(int n, double *x, double *y, const int nBins)

cdef extern from "lib/Binner.cpp":
    cdef cppclass BinnedData:
        BinnedData(int n, double *x, double *y, int *counts) except +
        
cdef extern from "lib/GraphMeasures.cpp":
    cdef cppclass Triangulation:
        Triangulation() except +

cdef inline c_scagnostics(double[:] x, double[:] y, int[:] length, int[:] bins, int[:] outlierRmv, double[:] results):
    scagnostics(&x[0], &y[0], &length[0], &bins[0], &outlierRmv[0], &results[0])
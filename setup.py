from distutils.core import setup
from Cython.Build import cythonize

setup(
    ext_modules = cythonize("NBC_train.pyx")
)

setup(
    ext_modules = cythonize("NBC_test.pyx")
)

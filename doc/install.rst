************
Installation
************

Conda Installation
==================
If you use Anaconda/Conda, the simplest way to install CMPLXFOIL is through the `conda forge <https://anaconda.org/conda-forge/cmplxfoil>`_:

.. prompt:: bash

    conda install -c conda-forge cmplxfoil

Install From Source
===================

Pip Installation
----------------

Before you begin, ensure you have the following installed:

*   **Python 3.7 or later.**
*   **C compiler.** ``gcc`` or ``icx`` are recommended
*   **Fortran compiler.** ``gfortran`` or ``ifx`` are recommended
*   On Linux, Python header files (``python3-dev`` or similar) are required.

First, create a virtual environment and activate it. Clone the repository, navigate to the root
directory of ``cmplxfoil`` and run pip install:

.. prompt:: bash

    git clone https://github.com/mdolab/cmplxfoil.git
    cd cmplxfoil
    pip install .

This command will automatically handle the build process, including installing the Meson build
system, compiling the necessary Fortran library, installing the Python package and required
dependencies.

CMPLXFOIL has two optional dependency groups that can be installed:

* ``geometry``: includes `pyGeo`_ , for ``getTriangulatedMeshSurface`` method
* ``plotting``: includes ``matplotlib`` and `niceplots`_, for ``plotAirfoil`` method

.. _pyGeo: https://github.com/mdolab/pygeo
.. _niceplots: https://github.com/mdolab/niceplots

To install these optional dependencies:

.. prompt:: bash

    pip install ".[geometry,plotting]"

.. note:: **Specifying compilers and flags**

    To change the C and Fortran compilers used, set `certain environment variables recognized by
    Meson <https://mesonbuild.com/Reference-tables.html#compiler-and-linker-selection-variables>`_
    before running ``pip install .``:

    .. prompt:: bash

        FC=$(which ifx) CC=$(which icx) pip install .

    CMPLXFOIL is installed with optimization level ``-O3`` by default. We found that using
    ``-Ofast -march=native`` can make CMPLXFOIL almost 2x faster, but they are technically unsafe so
    we leave them out by default. To do enable it, add these flags to the
    `Meson setup args <https://mesonbuild.com/Reference-tables.html#language-arguments-parameter-names>`_:

    .. prompt:: bash

        pip install . \
            --config-settings=setup-args="-Dc_args=['-Ofast', '-march=native']" \
            --config-settings=setup-args="-Dfortran_args=['-Ofast', '-march=native']"

    More permanently, you can modify the ``pyproject.toml`` as explained in the `Meson documentation
    <https://mesonbuild.com/meson-python/how-to-guides/meson-args.html>`_

    

.. note:: **Editable Installs**

    To facilitate package development, the project can be installed in editable mode, allowing
    Python source files to be modified without needing to reinstall the package. However, note that
    by default, ``pip install --editable .`` creates a temporary isolated build environment and
    deletes it when the build is complete. This will cause further rebuilds to fail. 

    It is recommended to first have the build dependencies available in your virtual
    environment, then install the package with build isolation disabled:
    
    .. tabs::

        .. tab:: pip

            .. prompt:: bash

                pip install meson-python meson ninja numpy
                pip install --no-build-isolation --editable .

            You can also inspect the compilation log during a rebuild by setting the
            `MESONPY_EDITABLE_VERBOSE <https://mesonbuild.com/meson-python/reference/environment-variables.html#envvar-MESONPY_EDITABLE_VERBOSE>`_
            environment variable, or more permanently:

            .. prompt:: bash

                pip install --no-build-isolation --config-settings=editable-verbose=true --editable . 

        .. tab:: uv

            .. code-block:: console

                $ uv pip install meson-python ninja numpy
                Resolved 6 packages in 67ms
                Prepared 6 packages in 265ms
                Installed 6 packages in 6ms
                + meson==1.7.0
                + meson-python==0.17.1
                + ninja==1.11.1.3
                + numpy==2.2.3
                + packaging==24.2
                + pyproject-metadata==0.9.1        

            Add the following lines to your ``pyproject.toml``:

            .. code-block:: toml
                :emphasize-lines: 5, 7-8, 11, 14

                [project]
                name = "my-project"
                version = "0.1.0"
                requires-python = ">=3.7"
                dependencies = ["cmplxfoil[geometry,plotting]"]

                [dependency-groups]
                dev = ["meson-python", "ninja", "numpy"]

                [tool.uv]
                no-build-isolation-package = ["cmplxfoil"]

                [tool.uv.sources]
                cmplxfoil = { path = "path/to/your/local/cmplxfoil", editable = true }

            Run:

            .. code-block:: console

                $ uv sync
                Built cmplxfoil @ file:///path/to/your/local/CMPLXFOIL
                    Updated https://github.com/mdolab/pygeo.git (ba45e83cea3244fe7cff1f773daf321b56b0bc65)
                    Updated https://github.com/cathaypacific8747/pyspline.git (b64c56d139a5a7ff3bf13b8a16e6289edfae1653)
                    Built pyspline @ git+https://github.com/cathaypacific8747/pyspline.git
                Resolved 23 packages in 10.55s
                    Built pygeo @ git+https://github.com/mdolab/pygeo.git@ba45e83cea3244fe7cff1f773daf321b56b0bc65
                    Built pyspline @ git+https://github.com/cathaypacific8747/pyspline.git@b64c56d139a5a7ff3bf13b8a16e6289edfae1653
                    Built mpi4py==4.0.3
                Prepared 15 packages in 1m 14s
                Installed 16 packages in 8ms
                + cmplxfoil==2.1.2 (from file:///path/to/your/local/CMPLXFOIL)
                + contourpy==1.3.1
                + cycler==0.12.1
                + fonttools==4.56.0
                + kiwisolver==1.4.8
                + matplotlib==3.10.1
                + mdolab-baseclasses==1.8.2
                + mpi4py==4.0.3
                + niceplots==2.5.1
                + pillow==11.1.0
                + pygeo==1.15.0 (from git+https://github.com/mdolab/pygeo.git@ba45e83cea3244fe7cff1f773daf321b56b0bc65)
                + pyparsing==3.2.1
                + pyspline==1.5.3 (from git+https://github.com/cathaypacific8747/pyspline.git@b64c56d139a5a7ff3bf13b8a16e6289edfae1653)
                + python-dateutil==2.9.0.post0
                + scipy==1.15.2
                + six==1.17.0

Building with Make and setuptools
---------------------------------

While ``pip install .`` is the recommended method, the original build system based on Makefiles is
still available. This section provides instructions for building CMPLXFOIL using Makefiles,
which may be helpful for advanced users or for troubleshooting purposes.

Build and Installation
^^^^^^^^^^^^^^^^^^^^^^
Building CMPLXFOIL is handled automatically by a set of Makefiles which are distributed with the code.
These Makefiles require configuration files which specify machine-specific parameters, such as compiler locations and flags.
Default configuration files for Linux GCC and Linux Intel are included in the ``config/defaults`` directory.
Copy a configuration file to the main ``config/`` folder using the command below and modify its contents for your system and installation.

.. prompt:: bash

    cp config/defaults/config.<version>.mk config/config.mk

.. note::
    We have found that replacing ``-O2`` with ``-Ofast -march=native`` can make CMPLXFOIL almost 2x faster, but the ``Ofast`` optimizations are technically unsafe so we leave them out by default. 

Once the configuration file is adjusted as needed, CMPLXFOIL can be built by running ``make`` in the root directory:

.. prompt:: bash

    make

This will compile both the real and complex versions of CMPLXFOIL, generating Python libraries which reference the XFOIL Fortran modules.
These will be automatically copied to the ``cmplxfoil/`` directory.

Once the Python libraries are generated, install CMPLXFOIL by running pip install in the root directory:

.. prompt:: bash

    python3 setup_deprecated.py install

Verification
^^^^^^^^^^^^
Tests are located in the ``tests/`` directory and can be run with the command:

.. prompt:: bash

    testflo -v .

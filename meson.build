# derived from: https://github.com/scipy/scipy/blob/main/scipy/meson.build
project(
  'cmplxfoil', 'c',
  version: run_command(['cmplxfoil/_version.py'], check: true).stdout().strip(),
  license: 'Apache-2.0',
  meson_version: '>= 1.5.0',
  default_options: [
    'buildtype=debugoptimized',
    'b_ndebug=if-release',
    'c_std=c99'
  ]
)

add_languages('fortran', native: false)
ff = meson.get_compiler('fortran')

py3 = import('python').find_installation(pure: false)
py3_dep = py3.dependency()

incdir_numpy = run_command(py3,
  ['-c', 'import os; os.chdir(".."); import numpy; print(numpy.get_include())'],
  check: true
).stdout().strip()
inc_np = include_directories(incdir_numpy)

incdir_f2py = incdir_numpy / '..' / '..' / 'f2py' / 'src'
inc_f2py = include_directories(incdir_f2py)
fortranobject_c = incdir_f2py / 'fortranobject.c'

# share this object across multiple modules
fortranobject_lib = static_library('_fortranobject',
  fortranobject_c,
  dependencies: py3_dep,
  include_directories: [inc_np, inc_f2py],
  gnu_symbol_visibility: 'hidden',
)
fortranobject_dep = declare_dependency(
  link_with: fortranobject_lib,
  include_directories: [inc_np, inc_f2py],
)

f2py = find_program('f2py')
f2py_version = run_command([py3, '-m', 'numpy.f2py', '-v'], check: true).stdout().strip()
message(f'f2py version: @f2py_version@')

# ignore fortran warning flags
_fflag_Wno_maybe_uninitialized = ff.get_supported_arguments('-Wno-maybe-uninitialized')
_fflag_Wno_unused_dummy_argument = ff.get_supported_arguments('-Wno-unused-dummy-argument')
_fflag_Wno_unused_label = ff.get_supported_arguments('-Wno-unused-label')
_fflag_Wno_unused_variable = ff.get_supported_arguments('-Wno-unused-variable')
_fflag_Wno_tabs = ff.get_supported_arguments('-Wno-tabs')

fortran_ignore_warnings = ff.get_supported_arguments(
  _fflag_Wno_maybe_uninitialized,
  _fflag_Wno_unused_dummy_argument,
  _fflag_Wno_unused_label,
  _fflag_Wno_unused_variable,
  _fflag_Wno_tabs,
)
fortran_args = ff.get_supported_arguments(
  '-std=legacy',
  '-fPIC',
  '-O2',
  '-fdefault-real-8',
  '-r8', # intel ifx
)

#
# libcmplxfoil
# libcmplxfoil_cs
#

cmplxfoil_src = files(
  'src/xfoil.f',
  'src/xpanel.f',
  'src/xoper.f',
  'src/xsolve.f',
  'src/xgdes.f',
  'src/xbl.f',
  'src/xblsys.f',
  'src/xgeom.f',
  'src/xutils.f',
  'src/aread.f',
  'src/userio.f',
  'src/spline.f',
  'src/naca.f',
  'src/xdriver.f',
)

cmplxfoil_lib = static_library('cmplxfoil',
  cmplxfoil_src,
  fortran_args: fortran_ignore_warnings + fortran_args,
)

cmplxfoil_c_wrapper = custom_target('libcmplxfoilmodule.c', 
  input: 'src/f2py/libcmplxfoil.pyf',
  output: ['libcmplxfoilmodule.c', 'libcmplxfoil-f2pywrappers.f'],
  command: [f2py, '@INPUT@']
)

py3.extension_module('libcmplxfoil',
  cmplxfoil_c_wrapper,
  link_with: [cmplxfoil_lib],
  dependencies: [fortranobject_dep],
  link_language: 'fortran',
  subdir: 'cmplxfoil',
  install: true
)

cmplxfoil_cs_src = files(
  'src_cs/complexify.f90',
  'src_cs/c_xfoil.f',
  'src_cs/c_xpanel.f',
  'src_cs/c_xoper.f',
  'src_cs/c_xsolve.f',
  'src_cs/c_xgdes.f',
  'src_cs/c_xbl.f',
  'src_cs/c_xblsys.f',
  'src_cs/c_xgeom.f',
  'src_cs/c_xutils.f',
  'src_cs/c_aread.f',
  'src_cs/c_userio.f',
  'src_cs/c_spline.f',
  'src_cs/c_naca.f',
)

cmplxfoil_cs_lib = static_library('cmplxfoil_cs',
  cmplxfoil_cs_src,
  fortran_args: fortran_ignore_warnings + fortran_args,
)

cmplxfoil_cs_c_wrapper = custom_target('libcmplxfoil_csmodule.c', 
  input: 'src_cs/f2py/libcmplxfoil_cs.pyf',
  output: ['libcmplxfoil_csmodule.c', 'libcmplxfoil_cs-f2pywrappers.f'],
  command: [f2py, '@INPUT@']
)

py3.extension_module('libcmplxfoil_cs',
  cmplxfoil_cs_c_wrapper,
  link_with: [cmplxfoil_cs_lib],
  dependencies: [fortranobject_dep],
  link_language: 'fortran',
  subdir: 'cmplxfoil',
  install: true
)

py3.install_sources(
  [
    'cmplxfoil/__init__.py',
    'cmplxfoil/CMPLXFOIL.py',
    'cmplxfoil/postprocess.py',
  ],
  subdir: 'cmplxfoil'
)
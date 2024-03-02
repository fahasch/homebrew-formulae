class PythonKwant < Formula
  desc "Python library for tight binding calculations"
  homepage "https://kwant-project.org"
  url "https://downloads.kwant-project.org/kwant/kwant-1.4.3.tar.gz"
  sha256 "3219d2512fcee55fa225328360574897e9f6049cfbae921bda0640a3a79dbd9f"
  license "BSD-2-Clause"

  depends_on "gcc" => :build # for gfortran
  depends_on "libcython" => :build
  depends_on "python@3.12"
  depends_on "openblas"
  depends_on "numpy"
  depends_on "scipy"
  depends_on "metis"
  depends_on "scotch"
  depends_on "mumps"
  depends_on "python-tinyarray"

  def python3
    which("python3.12")
  end

  def install
    ENV.prepend_path "PATH", Formula["libcython"].opt_libexec/"bin"
    site_packages=Language::Python.site_packages(python3)
    ENV.prepend_path "PYTHONPATH", Formula["libcython"].opt_libexec/site_packages

    (buildpath/"build.conf").write <<~"EOS"
      [kwant.linalg.lapack]
      extra_link_args = -Wl,-framework -Wl,Accelerate

      [mumps]
      libraries = zmumps mumps_common pord metis esmumps scotch scotcherr mpiseq gfortran gomp
      include_dirs = #{Formula["mumps"].include}
      library_dirs = /usr/local/opt/mumps/lib /usr/local/opt/metis/lib /usr/local/opt/scotch/lib /usr/local/opt/gcc/lib/gcc/current
    EOS

    system python3, "setup.py", "build", "--cython"  # recythonize
    system python3, "-m", "pip", "install", *std_pip_args, "."
  end

  test do
    system python3, "-c", <<~EOS
      import numpy as np
      t = np.ones((3,3), int)
      assert t.sum() == 9
      assert np.dot(t, t).sum() == 27
    EOS
  end
end

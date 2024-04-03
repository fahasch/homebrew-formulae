class PythonKwant < Formula
  desc "Python library for tight binding calculations"
  homepage "https://kwant-project.org"
  url "https://downloads.kwant-project.org/kwant/kwant-1.4.3.tar.gz"
  sha256 "3219d2512fcee55fa225328360574897e9f6049cfbae921bda0640a3a79dbd9f"
  license "BSD-2-Clause"

  depends_on "cython" => :build
  depends_on "gcc" => :build # for gfortran
  depends_on "python-setuptools" => :build
  depends_on "metis"
  depends_on "mumps"
  depends_on "numpy"
  depends_on "openblas"
  depends_on "python-tinyarray"
  depends_on "python@3.12"
  depends_on "scipy"
  depends_on "scotch"

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
      library_dirs = #{Formula["gcc"].lib}/gcc/current
    EOS

    system python3, "setup.py", "build", "--cython" # recythonize
    system python3, "-m", "pip", "install", *std_pip_args, "."
  end

  test do
    system python3, "-c", <<~EOS
      import kwant
      assert kwant.digest.TWOPI == 6.283185307179586
    EOS
  end
end

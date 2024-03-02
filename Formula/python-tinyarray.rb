class PythonTinyarray < Formula
  desc "Arrays of numbers for Python, optimized for small sizes"
  homepage "https://pypi.org/project/tinyarray/"
  url "https://downloads.kwant-project.org/tinyarray/tinyarray-1.2.4.tar.gz"
  sha256 "3219d2512fcee55fa225328360574897e9f6049cfbae921bda0640a3a79dbd9f"
  license "BSD-2-Clause"

  depends_on "gcc" => :build # for gfortran
  depends_on "libcython" => :build
  depends_on "python@3.12"

  def python3
    which("python3.12")
  end

  def install
    ENV.prepend_path "PATH", Formula["libcython"].opt_libexec/"bin"
    site_packages=Language::Python.site_packages(python3)
    ENV.prepend_path "PYTHONPATH", Formula["libcython"].opt_libexec/site_packages

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

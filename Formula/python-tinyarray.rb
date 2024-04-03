class PythonTinyarray < Formula
  desc "Arrays of numbers for Python, optimized for small sizes"
  homepage "https://pypi.org/project/tinyarray/"
  url "https://downloads.kwant-project.org/tinyarray/tinyarray-1.2.4.tar.gz"
  sha256 "ecd3428fd8a48b61fc5f0a413ede03e27db3a1dd53fcd49e24a36d11a8a29aba"
  license "BSD-2-Clause"

  depends_on "cython" => :build
  depends_on "gcc" => :build # for gfortran
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
      import tinyarray as ta
      t = ta.ones(2)
      assert ta.dot(t, t) == 2
    EOS
  end
end

class PythonAdaptive < Formula
  desc "Parallel active learning of mathematical functions"
  homepage "https://adaptive.readthedocs.io"
  url "https://github.com/python-adaptive/adaptive/archive/refs/tags/v1.1.0.tar.gz"
  sha256 "ecd3428fd8a48b61fc5f0a413ede03e27db3a1dd53fcd49e24a36d11a8a29aba"
  license "BSD-2-Clause"

  depends_on "cython" => :build
  depends_on "python@3.12"

  def python3
    which("python3.12")
  end

  def install
    ENV.prepend_path "PATH", Formula["libcython"].opt_libexec/"bin"
    site_packages=Language::Python.site_packages(python3)
    ENV.prepend_path "PYTHONPATH", Formula["libcython"].opt_libexec/site_packages

    system python3, "-m", "pip", "install", *std_pip_args, ".[notebook]"
  end

  test do
    system python3, "-c", <<~EOS
      import adaptive as ad
      v = ad.__version__
      assert v == '1.1.0'
    EOS
  end
end

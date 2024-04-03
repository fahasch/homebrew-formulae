class PythonAdaptive < Formula
  desc "Parallel active learning of mathematical functions"
  homepage "https://adaptive.readthedocs.io"
  url "https://github.com/python-adaptive/adaptive/archive/refs/tags/v1.1.0.tar.gz"
  sha256 "9f73dc16608503d5f0f0d24deeb88e6b07352be43796ece84fac5f0caa9a981b"
  license "BSD-2-Clause"

  depends_on "cython" => :build
  depends_on "python@3.12"

  def python3
    which("python3.12")
  end

  def install
    ENV.prepend_path "PATH", Formula["cython"].opt_libexec/"bin"
    site_packages=Language::Python.site_packages(python3)
    ENV.prepend_path "PYTHONPATH", Formula["cython"].opt_libexec/site_packages

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

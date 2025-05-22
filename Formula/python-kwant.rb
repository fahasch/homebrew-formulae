class PythonKwant < Formula
  desc "Python library for tight binding calculations"
  homepage "https://kwant-project.org"
  url "https://downloads.kwant-project.org/kwant/kwant-1.5.0.tar.gz"
  head "https://gitlab.kwant-project.org/kwant/kwant.git", branch: "main"
  sha256 "9859451d0e20364ce30777a5dd7ecb7a06956822612935a408ed4d81e5c8321b"
  license "BSD-2-Clause"

  depends_on "cython" => :build
  depends_on "python-setuptools" => :build
  depends_on "mumps"
  depends_on "openblas"
  depends_on "python-tinyarray"
  depends_on "python@3"
  depends_on "scipy"

  def python3
    "python3"
  end

  def install
    ENV.prepend_path "PYTHONPATH", Formula["cython"].opt_libexec/Language::Python.site_packages(python3)

    (buildpath/"build.conf").write <<~EOS
      [kwant.linalg.lapack]
      extra_link_args = -lopenblas

      [kwant.linalg._mumps]
      libraries = zmumps
    EOS

    system python3, "setup.py", "build", "--cython" # recythonize
    system python3, "-m", "pip", "install", *std_pip_args(build_isolation: true), "."
  end

  test do
    system python3, "-c", <<~EOS
      import kwant
      assert kwant.digest.TWOPI == 6.283185307179586
    EOS
  end
end

class PythonTinyarray < Formula
  desc "Arrays of numbers for Python, optimized for small sizes"
  homepage "https://pypi.org/project/tinyarray/"
  url "https://downloads.kwant-project.org/tinyarray/tinyarray-1.2.5.tar.gz"
  sha256 "5d47b3d475a30478ee72d6afe238c3d3683b3a3f9d425bb2f6384270b2c8799b"
  license "BSD-2-Clause"

  depends_on "python-setuptools" => :build
  depends_on "python@3"

  def python3
    "python3"
  end

  def install
    system python3, "-m", "pip", "install", *std_pip_args(build_isolation: true), "."
  end

  test do
    system python3, "-c", <<~EOS
      import tinyarray as ta
      t = ta.ones(2)
      assert ta.dot(t, t) == 2
    EOS
  end
end

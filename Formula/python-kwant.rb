class PythonKwant < Formula
  desc "Python library for tight binding calculations"
  homepage "https://kwant-project.org"
  url "https://downloads.kwant-project.org/kwant/kwant-1.4.3.tar.gz"
  license "BSD 2-Clause"

  depends_on "gcc" => :build # for gfortran
  depends_on "libcython" => :build
  depends_on "python@3.12"
  depends_on "numpy"
  depends_on "scipy"
  depends_on "mumps"
  depends_on "openblas"

  def python3
    which("python3.12")
  end

  def install
    #ENV.prepend_path "PATH", Formula["libcython"].opt_libexec/"bin"

    (buildpath/"mplsetup.cfg").write <<~EOS
      [libs]
      system_freetype = true
      system_qhull = true
    EOS

    system python3, "-m", "pip", "install", *std_pip_args, "."

  end

  test do
    pythons.each do |python|
      python_exe = python.opt_libexec/"bin/python"
      system python_exe, "-c", <<~EOS
        import numpy as np
        t = np.ones((3,3), int)
        assert t.sum() == 9
        assert np.dot(t, t).sum() == 27
      EOS
    end
  end
end

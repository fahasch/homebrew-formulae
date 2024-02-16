class Fricas < Formula
  desc "Advanced computer algebra system"
  homepage "https://fricas.github.io"
  url "https://github.com/fricas/fricas/archive/refs/tags/1.3.10.tar.gz"
  sha256 "2c1a2daaf5ce7be86118bbd1bdc2d3bd052b3e1f0ce9257dbda82cd69d25c193"
  license "BSD-3-Clause"
  head "https://github.com/fricas/fricas.git", branch: "master"

  depends_on "libice"
  depends_on "libsm"
  depends_on "libx11"
  depends_on "libxau"
  depends_on "libxdmcp"
  depends_on "libxpm"
  depends_on "libxt"
  depends_on "hsbcl"
  depends_on "gmp"

  def install
    args = %W[
    --with-lisp=#{Formula["hsbcl"].bin},
    --enable-gmp
    ]

    Dir.mkdir("build")
    chdir "build" do
      ENV.deparallelize
      system "../configure", *std_configure_args, *args
      system "make"
      system "make", "install"
    end
  end
end

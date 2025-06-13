class Fricas < Formula
  desc "Advanced computer algebra system"
  homepage "https://fricas.github.io"
  url "https://github.com/fricas/fricas/archive/refs/tags/1.3.12.tar.gz"
  sha256 "f201cf62e3c971e8bafbc64349210fbdc8887fd1af07f09bdcb0190ed5880a90"
  license "BSD-3-Clause"
  head "https://github.com/fricas/fricas.git", branch: "master"

  depends_on "gmp"
  depends_on "hsbcl"
  depends_on "libice"
  depends_on "libsm"
  depends_on "libx11"
  depends_on "libxau"
  depends_on "libxdmcp"
  depends_on "libxpm"
  depends_on "libxt"

  def install
    args = [
      "--with-lisp=#{Formula["hsbcl"].bin}/hsbcl --dynamic-space-size 4096",
      "--enable-gmp",
    ]

    mkdir "build" do
      system "../configure", *std_configure_args, *args
      system "make"
      system "make", "install"
    end
  end

  test do
    assert_match %r{ \(/ \(pi\) 2\)\n},
      pipe_output(bin/"fricas -nosman", "integrate(sqrt(1-x^2),x=-1..1)::InputForm")
  end
end

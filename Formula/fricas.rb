class Fricas < Formula
  desc "Advanced computer algebra system"
  homepage "https://fricas.github.io"
  url "https://github.com/fricas/fricas/releases/download/1.4.0/fricas-1.4.0-full.tar.bz2"
    sha256 "e113c721aaba673226d0806076a12ec82c07562c2954479443047d4264172514"
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
  depends_on "zstd"

  def install
    args = [
      "--with-lisp=#{Formula["hsbcl"].bin}/hsbcl",
      "--enable-lisp-core",
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
      pipe_output("#{bin}/fricas -nosman",
                  "integrate(sqrt(1-x^2),x=-1..1)::InputForm")
  end
end

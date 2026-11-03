# FriCAS with the Hunchentoot webserver for jFriCAS, otherwise like
# the homebrew-core formula "fricas" (X11 HyperDoc and graphics).
# Tap: fahasch/homebrew-formulae, file Formula/fricas.rb;
# install with
#   brew install fahasch/formulae/fricas
# The stable version is the 1.4.0 release tarball; it carries the
# pre-generated pages (.pht).  --HEAD builds master of fahasch/fricas,
# which has to make them and needs Unix sockets in /tmp for that;
# Homebrew's build sandbox denies them, so --HEAD is not expected to
# build there.
class Fricas < Formula
  desc "Advanced computer algebra system (with Hunchentoot for jFriCAS)"
  homepage "https://fricas.github.io"
  url "https://github.com/fricas/fricas/releases/download/1.4.0/fricas-1.4.0-full.tar.bz2"
  sha256 "e113c721aaba673226d0806076a12ec82c07562c2954479443047d4264172514"
  license "BSD-3-Clause"
  head "https://github.com/fahasch/fricas.git", branch: "master"

  depends_on "gmp"
  depends_on "libice"
  depends_on "libsm"
  depends_on "libx11"
  depends_on "libxau"
  depends_on "libxdmcp"
  depends_on "libxpm"
  depends_on "libxt"
  depends_on "sbcl"
  depends_on "zstd"

  conflicts_with "fricas", because: "both install bin/fricas"
  conflicts_with "fricas_html", because: "both install bin/fricas"

  # Hunchentoot and its dependencies as tarballs, plus a script that
  # loads them into SBCL and saves the result as "hsbcl"; no network
  # access needed.
  resource "hsbcl" do
    url "https://downloads.sourceforge.net/project/fricas/fricas/1.3.9/hsbcl-1.3.9.tar"
    sha256 "dc69541993ae3b14e1912e3160ba7a1e0f044be4af6ea46caa98dc6d65b54b6a"
  end

  def install
    hsbcl = buildpath/"hsbcl-bin/hsbcl"
    resource("hsbcl").stage do
      system "sh", "./build_hsbcl"
      (buildpath/"hsbcl-bin").install "hsbcl"
    end

    args = %W[
      --with-lisp=#{hsbcl}
      --enable-lisp-core
      --enable-gmp
    ]

    mkdir "build" do
      system "../configure", *std_configure_args, *args
      system "make"
      system "make", "install"
    end

    # With --enable-lisp-core, FRICASsys is a wrapper that runs the
    # build Lisp on FRICASsys.core.  The core already contains
    # Hunchentoot, so point the wrapper at the plain sbcl that hsbcl
    # was built from instead of the temporary hsbcl.
    Dir[lib/"fricas/target/*/bin/FRICASsys"].each do |f|
      chmod 0755, f
      inreplace f, hsbcl.to_s, Formula["sbcl"].opt_bin/"sbcl"
    end
  end

  def caveats
    <<~EOS
      The image includes the Hunchentoot webserver for jFriCAS.  To
      get the Jupyter kernel files, run in FriCAS
        kernel()$JFriCAS
        fricaskernel()$JFriCAS
      which write kernel.json and fricaskernel.py to the current
      directory.
    EOS
  end

  test do
    assert_match %r{ \(/ \(pi\) 2\)\n},
      pipe_output("#{bin}/fricas -nosman", "integrate(sqrt(1-x^2),x=-1..1)::InputForm")
    assert_match "Value = (:HUNCHENTOOT",
      pipe_output("#{bin}/fricas -nosman", ")lisp (member :hunchentoot *features*)")
  end
end

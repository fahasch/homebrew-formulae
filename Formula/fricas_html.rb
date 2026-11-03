# FriCAS with HyperDoc in the web browser (branch html-hyperdoc of
# fahasch/fricas), built without X11.  The homebrew-core formula
# "fricas" with the X11 libraries dropped and two configure options
# added.  Tap: fahasch/homebrew-formulae, file Formula/fricas_html.rb;
# install with
#   brew install fahasch/formulae/fricas_html
# Like the release tarball of homebrew-core, the tarball carries the
# pre-generated pages (.pht): making them needs Unix sockets in /tmp,
# which Homebrew's build sandbox denies, so a --HEAD build fails there.
#
# FriCAS is built with "hsbcl", an SBCL with the Hunchentoot webserver
# preloaded, so that the image can serve jFriCAS (start(p)$JFriCAS).
class FricasHtml < Formula
  desc "Advanced computer algebra system (HyperDoc in the web browser)"
  homepage "https://fricas.github.io"
  url "https://github.com/fahasch/fricas/releases/download/browser-hyperdoc-2-actions/fricas-html-feb33ef.tar.bz2"
  version "2026.11.02-feb33ef"
  sha256 "6f715eecf020914dceae1c2b861dfa4163c2eac1e939c5a39cb4edbfe00edfba"
  license "BSD-3-Clause"

  depends_on "gmp"
  depends_on "sbcl"
  depends_on "zstd"

  conflicts_with "fricas", because: "both install bin/fricas"

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
      --with-hyperdoc=html
      --without-x
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
      HyperDoc runs in the web browser: when FriCAS starts, it opens
      in the default browser (or the one in $BROWSER) and prints its
      address "(HyperDoc) http://127.0.0.1:<port>/<token>/"; )hd
      opens it again.  Graphics are not available in this build yet.

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

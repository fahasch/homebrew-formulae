# FriCAS with HyperDoc in the web browser (branch html-hyperdoc of
# fahasch/fricas), built without X11.  The homebrew-core formula
# "fricas" with the X11 libraries dropped and two configure options
# added.  Tap: fahasch/homebrew-formulae, file Formula/fricas_html.rb;
# install with
#   brew install fahasch/formulae/fricas_html
# Like the release tarball of homebrew-core, the tarball carries the
# pre-generated pages (.pht): making them needs Unix sockets in /tmp,
# which Homebrew's build sandbox denies, so a --HEAD build fails there.
class FricasHtml < Formula
  desc "Advanced computer algebra system (HyperDoc in the web browser)"
  homepage "https://fricas.github.io"
  url "https://github.com/fahasch/fricas/releases/download/browser-hyperdoc-2-actions/fricas-html-e8106f0.tar.bz2"
  version "2026.11.06-e8106f0"
  sha256 "46b80fc29e80d82b8b5cebb9f57962b1cace826c2353ef553e6e6e17780ca1eb"
  license "BSD-3-Clause"

  depends_on "gmp"
  depends_on "sbcl"
  depends_on "zstd"

  conflicts_with "fricas", because: "both install bin/fricas"

  def install
    args = %w[
      --with-lisp=sbcl
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
  end

  def caveats
    <<~EOS
      HyperDoc runs in the web browser: when FriCAS starts, it opens
      in the default browser (or the one in $BROWSER) and prints its
      address "(HyperDoc) http://127.0.0.1:<port>/<token>/"; )hd
      opens it again.  Graphics are not available in this build yet.
    EOS
  end

  test do
    assert_match %r{ \(/ \(pi\) 2\)\n},
      pipe_output("#{bin}/fricas -nosman", "integrate(sqrt(1-x^2),x=-1..1)::InputForm")
  end
end

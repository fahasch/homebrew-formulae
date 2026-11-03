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

  # The Hunchentoot webserver and its dependencies, built into the
  # FriCAS image for jFriCAS (the Jupyter kernel, see JFriCAS).
  # Versions as in FriCAS upstream's hsbcl-1.3.9.tar.
  resource "alexandria" do
    url "https://beta.quicklisp.org/archive/alexandria/2022-07-07/alexandria-20220707-git.tgz"
    sha256 "8e6173120de8786c7ae0fefba8102d82620fac42e9aade954af9135e0870d6b1"
  end

  resource "bordeaux-threads" do
    url "https://beta.quicklisp.org/archive/bordeaux-threads/2022-07-07/bordeaux-threads-v0.8.8.tgz"
    sha256 "37ef6d10cc5bdb81e4ed44c2f996211459e629607a77fd465a8b1c730dbcb2d2"
  end

  resource "chunga" do
    url "https://beta.quicklisp.org/archive/chunga/2022-11-06/chunga-20221106-git.tgz"
    sha256 "4c45e2ba39d1c220913728f606048cb9bb374887a78e71e24476ae678b11a72f"
  end

  resource "cl-base64" do
    url "https://beta.quicklisp.org/archive/cl-base64/2020-10-16/cl-base64-20201016-git.tgz"
    sha256 "3ff50faf5ddccd409f8954eb70c2d4e76329cc916f070de95f79c7ecf6d3a2f1"
  end

  resource "cl-fad" do
    url "https://beta.quicklisp.org/archive/cl-fad/2022-02-20/cl-fad-20220220-git.tgz"
    sha256 "91faa900b70d369b8646d6d8b5b560d5fe10c10985132290278f8a9c094f4224"
  end

  resource "cl-ppcre" do
    url "https://beta.quicklisp.org/archive/cl-ppcre/2022-02-20/cl-ppcre-20220220-git.tgz"
    sha256 "bbef645603181b6aa0691d2755dd9d1f9a87659cc000a871313970400f344593"
  end

  resource "flexi-streams" do
    url "https://beta.quicklisp.org/archive/flexi-streams/2022-02-20/flexi-streams-20220220-git.tgz"
    sha256 "a179543ed582f8920eb5363c1b3b48c45a3300f063d85601a5d668dfe8cfe706"
  end

  resource "hunchentoot" do
    url "https://beta.quicklisp.org/archive/hunchentoot/2020-06-10/hunchentoot-v1.3.0.tgz"
    sha256 "280e82a9681d850c757d6692bd5a182fbf47f8984b6d58cd7eb0094c4bbcf623"
  end

  resource "md5" do
    url "https://beta.quicklisp.org/archive/md5/2021-06-30/md5-20210630-git.tgz"
    sha256 "9bfde89ed7e0464204b66b9b9f6699d4234aeabe1d00695d711d993bf8a2719a"
  end

  resource "rfc2388" do
    url "https://beta.quicklisp.org/archive/rfc2388/2018-08-31/rfc2388-20180831-git.tgz"
    sha256 "63fc3346a0bae5acd3c9d1cd658947f45a4f869b762a51d70882728169defbe4"
  end

  resource "split-sequence" do
    url "https://beta.quicklisp.org/archive/split-sequence/2021-05-31/split-sequence-v2.0.1.tgz"
    sha256 "ca47962ad1e2275e9c9092abedb392459c93b25b1f6f0565057e715bfa6dd274"
  end

  resource "trivial-backtrace" do
    url "https://beta.quicklisp.org/archive/trivial-backtrace/2023-02-14/trivial-backtrace-20230214-git.tgz"
    sha256 "e34a3355ca15c2e0ed84160046c2b16680a7e8b164d67d5a049656786af6c84f"
  end

  resource "trivial-gray-streams" do
    url "https://beta.quicklisp.org/archive/trivial-gray-streams/2021-01-24/trivial-gray-streams-20210124-git.tgz"
    sha256 "c68e05298ad46de2b48ac3c1d326617284f8701784d1623d4e4724620667986b"
  end

  resource "usocket" do
    url "https://beta.quicklisp.org/archive/usocket/2022-11-06/usocket-0.8.5.tgz"
    sha256 "aef6f5b4b9232cf422a05e3f958e1d85a6d9ad1a6f05b1833598a96f3c215c2c"
  end

  def install
    # Save an SBCL core with Hunchentoot preloaded and make it the
    # default core of the sbcl used for the build, so that FriCAS
    # includes Hunchentoot.  FRICASsys.core then contains it and the
    # plain sbcl suffices at runtime.
    sbcl_home = buildpath/"sbcl_home"
    sbcl_home.install_symlink formula_opt_lib("sbcl")/"sbcl/contrib"
    resources.each { |r| r.stage(buildpath/"hunchentoot"/r.name) }
    (buildpath/"hsbcl.lisp").write <<~LISP
      (require "asdf")
      (setf asdf:*central-registry* (directory "#{buildpath}/hunchentoot/*/"))
      (push :hunchentoot-no-ssl *features*)
      (asdf:load-system "hunchentoot")
      (sb-ext:save-lisp-and-die "#{sbcl_home}/sbcl.core")
    LISP
    system "sbcl", "--non-interactive", "--no-sysinit", "--no-userinit", "--load", "hsbcl.lisp"
    (buildpath/"bin/sbcl").write_env_script formula_opt_libexec("sbcl")/"bin/sbcl", SBCL_HOME: sbcl_home
    ENV.prepend_path "PATH", buildpath/"bin"

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

  test do
    assert_match %r{ \(/ \(pi\) 2\)\n},
      pipe_output("#{bin}/fricas -nosman", "integrate(sqrt(1-x^2),x=-1..1)::InputForm")
    assert_match "Value = (:HUNCHENTOOT",
      pipe_output("#{bin}/fricas -nosman", ")lisp (member :hunchentoot *features*)")
  end
end

class Hsbcl < Formula
  desc "Hunchentoot Steel Bank Common Lisp system"
  homepage "http://www.sbcl.org/"
  url "https://github.com/edicl/hunchentoot/archive/refs/tags/v1.3.1.tar.gz"
  sha256 "92243ca8cb369f0fae0fdd84dcef8329caa01cc4778e8f85942757bd1ef39460"
  license all_of: [:public_domain, "MIT", "Xerox", "BSD-3-Clause"]

  depends_on "sbcl" => :build

  resource "alexandria" do
    url "https://gitlab.common-lisp.net/alexandria/alexandria/-/archive/v1.4/alexandria-v1.4.tar.gz"
    sha256 "0512aec38d054a20daa66e9983cf8a98151582d7e2307e49e8c1b4a61bbb779a"
  end

  resource "bordeaux-threads" do
    url "https://github.com/sionescu/bordeaux-threads/archive/refs/tags/v0.9.3.tar.gz"
    sha256 "caa34284b6d5224c8907d256601a6f6341923842989fb3be58b3379b2674b229"
  end

  resource "chunga" do
    url "https://github.com/edicl/chunga/archive/refs/tags/v1.1.8.tar.gz"
    sha256 "9508090b1dfac6dec4e6a8eb9673d13539c9b468868cba46a3f7c213fd992786"
  end

  resource "cl-base64" do
    url "https://github.com/darabi/cl-base64.git"
  end

  resource "cl-fad" do
    url "https://github.com/edicl/cl-fad/archive/refs/tags/v0.7.6.tar.gz"
    sha256 "d6c567ced2b048fbd9ff4b28e1bb679a82f949d1e9e4ef17e138153220d708f2"
  end

  resource "cl-ppcre" do
    url "https://github.com/edicl/cl-ppcre/archive/refs/tags/v2.1.2.tar.gz"
    sha256 "2ddd99706fa2b442d3eb12ea36bb25f57613fc82e5eb91c4fcaec3b7ce4cfe85"
  end

  resource "flexi-streams" do
    url "https://github.com/edicl/flexi-streams/archive/refs/tags/v1.0.20.tar.gz"
    sha256 "8ebb0226e3748529564bc564e4012912b7dc2326d73c06eb41b5d0d07a60b538"
  end

  resource "global-vars" do
    url "https://github.com/lmj/global-vars.git"
  end

  resource "md5" do
    url "https://github.com/pmai/md5/archive/refs/tags/release-2.0.5.tar.gz"
    sha256 "f4264f895d004a1234c68bb4569b2f05f33eb3b19b0a6bd693db394052223de4"
  end

  resource "rfc2388" do
    url "https://github.com/jdz/rfc2388.git"
  end

  resource "split-sequence" do
    url "https://github.com/sharplispers/split-sequence/archive/refs/tags/v2.0.1.tar.gz"
    sha256 "e5d0efe5bebc9566ad9f84f2c247fc5f6e5bd06e05ac0127b04654da8a7da59b"
  end

  resource "trivial-backtrace" do
    url "https://github.com/hraban/trivial-backtrace.git"
  end

  resource "trivial-features" do
    url "https://github.com/trivial-features/trivial-features/archive/refs/tags/v1.0.tar.gz"
    sha256 "d25f8d3d31f33a547913d361cf0c6f46dcf3f98a4da6b169aa1739fcdadd5ca0"
  end

  resource "trivial-garbage" do
    url "https://github.com/trivial-garbage/trivial-garbage/archive/refs/tags/v0.21.tar.gz"
    sha256 "dea471b00736f122ccf9eba9b5aadcb58bd12d65c8946b355738cfafa925442c"
  end

  resource "trivial-gray-streams" do
    url "https://github.com/trivial-gray-streams/trivial-gray-streams.git"
  end

  resource "usocket" do
    url "https://github.com/usocket/usocket/archive/refs/tags/v0.8.7.tar.gz"
    sha256 "cc7d412f122a9ae31ee94b919d459ddebbb2952c8b7c864e772d8e271f7952a5"
  end

  def install
    dependencies = %w[alexandria
                      bordeaux-threads
                      chunga
                      cl-base64
                      cl-fad
                      cl-ppcre
                      flexi-streams
                      global-vars
                      md5
                      rfc2388
                      split-sequence
                      trivial-backtrace
                      trivial-features
                      trivial-garbage
                      trivial-gray-streams
                      usocket ]

    dependencies.each { |d| resource(d).stage buildpath/d }

    (buildpath/"la.lisp").write <<~EOS
      (require "asdf")
      (setf |$base_dir| "#{buildpath}/")
      (defun do_asd (dir n)
          (let ((asdf:*central-registry*
                 (list (concatenate 'string |$base_dir| dir))))
          (asdf:load-system n))
      )

      (do_asd "split-sequence/" "split-sequence")
      (do_asd "usocket/" "usocket")
      (do_asd "trivial-backtrace/" "trivial-backtrace")
      (do_asd "md5/" "md5")
      (do_asd "rfc2388/" "rfc2388")
      (do_asd "trivial-gray-streams/" "trivial-gray-streams")
      (do_asd "flexi-streams/" "flexi-streams")
      (do_asd "cl-ppcre/" "cl-ppcre")
      (do_asd "trivial-garbage/" "trivial-garbage")
      (do_asd "trivial-features/" "trivial-features")
      (do_asd "global-vars/" "global-vars")
      (do_asd "alexandria/" "alexandria")
      (do_asd "bordeaux-threads/" "bordeaux-threads")
      (do_asd "cl-fad/" "cl-fad")
      (do_asd "cl-base64/" "cl-base64")
      (do_asd "chunga/" "chunga")
      (push :HUNCHENTOOT-NO-SSL *FEATURES*)
      (do_asd "" "hunchentoot")
      (require "SB-POSIX")
      (require "SB-SPROF")
      (sb-ext::save-lisp-and-die "./hsbcl" :executable t)
    EOS

    system "sbcl --eval '(load \"la.lisp\")' --quit"
    bin.install("hsbcl")
  end

  test do
    (testpath/"simple.sbcl").write <<~EOS
      (write-line (write-to-string (+ 2 2)))
    EOS
    output = shell_output("#{bin}/hsbcl --script #{testpath}/simple.sbcl")
    assert_equal "4", output.strip
  end
end

class Hsbcl < Formula
  desc "Hunchentoot Steel Bank Common Lisp system"
  homepage "https://edicl.github.io/hunchentoot/"
  url "https://github.com/edicl/hunchentoot/archive/refs/tags/v1.3.1.tar.gz"
  sha256 "92243ca8cb369f0fae0fdd84dcef8329caa01cc4778e8f85942757bd1ef39460"
  license all_of: [:public_domain, "MIT", "Xerox", "BSD-3-Clause"]

  depends_on "sbcl"

  resource "alexandria" do
    url "https://github.com/kmx-io/alexandria.git"
    sha256 "8f6fe04e314660086ea11685d8a6a3fc648c5643305002adf4e5c45460b8533e"
  end

  resource "bordeaux-threads" do
    url "https://github.com/sionescu/bordeaux-threads/archive/refs/tags/v0.9.4.tar.gz"
    sha256 "88a8d2130e31644f606e905abddc481b35954f9bad231a53b0f4cf2181c46d98"
  end

  resource "chunga" do
    url "https://github.com/edicl/chunga/archive/refs/tags/v1.1.9.tar.gz"
    sha256 "7b5c7e3a7d99b936281aac7322a3f6087ccf656de0ce7e4a11340e0e2da1b2f3"
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
    url "https://github.com/usocket/usocket/archive/refs/tags/v0.8.9.tar.gz"
    sha256 "36759258e392359aa88fb026009949dadd2d46b108492dece1b90d937cf873e7"
  end

  def install
    dependencies = %w[split-sequence
                      usocket
                      trivial-backtrace
                      md5
                      rfc2388
                      trivial-gray-streams
                      flexi-streams
                      cl-ppcre
                      trivial-garbage
                      trivial-features
                      global-vars
                      alexandria
                      bordeaux-threads
                      cl-fad
                      cl-base64
                      chunga ]

    dependencies.each { |d| resource(d).stage buildpath/d }

    ENV["CL_SOURCE_REGISTRY"] = "#{buildpath}//"

    (buildpath/"init.lisp").write <<~LISP
      (require "asdf")
      (setf asdf:*central-registry* nil)
      (pushnew :hunchentoot-no-ssl *features*)
      (asdf:load-system :hunchentoot)
      (require "sb-posix")
      (require "sb-sprof")
      (sb-ext::save-lisp-and-die "./hsbcl" :executable t)
    LISP

    system "sbcl --eval '(load \"init.lisp\")' --quit"
    bin.install("hsbcl")

  end


  test do
    output = shell_output("#{bin}/hsbcl --noinform --disable-debugger \
                          --eval '(print (find-package :hunchentoot))' --quit")
    assert_equal "#<PACKAGE \"HUNCHENTOOT\">", output.strip
  end
end

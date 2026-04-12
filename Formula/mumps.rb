class Mumps < Formula
  desc "MUltifrontal Massively Parallel sparse direct Solver"
  homepage "https://mumps-solver.org/"
  url "https://mumps-solver.org/MUMPS_5.8.2.tar.gz"
  sha256 "eb515aa688e6dbab414bb6e889ff4c8b23f1691a843c68da5230a33ac4db7039"
  license "CECILL-C"

  # Core dependencies
  depends_on "gcc"
  depends_on "metis"
  depends_on "openblas"
  depends_on "scotch"
  fails_with :clang

  def install
    makefile = "Makefile.debian.SEQ"
    cp "Make.inc/" + makefile, "Makefile.inc"
    inreplace "Makefile.inc", "-soname", "-install_name" unless OS.linux?
    inreplace "Makefile.inc", ".so", ".dylib" unless OS.linux?
    make_args = ["RPATH_OPT=-Wl,-rpath,#{lib}",
                 "ISCOTCH=-I#{Formula["scotch"].opt_include}"]
    system "make", "allshared", *make_args

    # Makefile provides no install target, perform as needed install
    # Install libraries
    lib.install Dir["lib/#{shared_library("*")}"]
    lib.install Dir["libseq/libmpiseq#{shared_library("*")}"]
    # Install headers
    libexec.install "include"
    rm "libseq/mpi.h"
    rm "libseq/mpif.h"
    (libexec/"include").install Dir["libseq/*.h"]
    include.install_symlink Dir[libexec/"include/*"]
    # Install docs and examples
    doc.install Dir["doc/*.pdf"]
    pkgshare.install "examples"
  end

  test do
    cd testpath do
      mumps_path = Formula["mumps"].pkgshare/"examples"
      system "#{mumps_path}/c_example"
      system "#{mumps_path}/ssimpletest < #{mumps_path}/input_simpletest_real"
      system "#{mumps_path}/dsimpletest < #{mumps_path}/input_simpletest_real"
      system "#{mumps_path}/csimpletest < #{mumps_path}/input_simpletest_cmplx"
      system "#{mumps_path}/zsimpletest < #{mumps_path}/input_simpletest_cmplx"
    end
  end
end

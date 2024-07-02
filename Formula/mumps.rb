class Mumps < Formula
  desc "MUltifrontal Massively Parallel sparse direct Solver"
  homepage "https://mumps-solver.org/"
  url "https://mumps-solver.org/MUMPS_5.7.2.tar.gz"
  sha256 "1362d377ce7422fc886c55212b4a4d2c381918b5ca4478f682a22d0627a8fbf8"
  license "CECILL-C"

  # Core dependencies
  depends_on "gcc"
  depends_on "openblas"
  fails_with :clang

  def install
    makefile = "Makefile.G95.SEQ"
    cp "Make.inc/" + makefile, "Makefile.inc"
    inreplace "Makefile.inc", "-soname", "-install_name" unless OS.linux?
    inreplace "Makefile.inc", ".so", ".dylib" unless OS.linux?
    make_args = ["RPATH_OPT=-Wl,-rpath,#{lib}"]
    make_args += ["CDEFS=-DAdd_",
                  "OPTF=-fallow-argument-mismatch",
                  "SHARED_OPT=-dynamiclib"]
    make_args += ["CC=#{ENV.cc} -fPIC",
                  "FC=gfortran -fPIC -fopenmp",
                  "FL=gfortran -fPIC -fopenmp"]
    # Default lib args
    # Note: MUMPS link cannot find LAPACK without these
    # lines
    blas_lib = "-L#{Formula["openblas"].opt_lib} -lopenblas"
    make_args << "LIBBLAS=#{blas_lib}"
    make_args << "LAPACK=#{blas_lib}"

    ENV.deparallelize
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

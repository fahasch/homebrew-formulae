class Hsbcl < Formula
  desc "Hunchentoot Steel Bank Common Lisp system"
  homepage "http://www.sbcl.org/"
  url "https://sourceforge.net/projects/fricas/files/fricas/1.3.9/hsbcl-1.3.9.tar"
  sha256 "dc69541993ae3b14e1912e3160ba7a1e0f044be4af6ea46caa98dc6d65b54b6a"
  license all_of: [:public_domain, "MIT", "Xerox", "BSD-3-Clause"]
  
  depends_on "sbcl" => :build

  def install
    system "./build_hsbcl"
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

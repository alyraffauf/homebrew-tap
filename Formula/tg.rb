class Tg < Formula
  desc "Command-line client for Tangled, the git forge built on atproto"
  homepage "https://github.com/alyraffauf/tg"
  url "https://github.com/alyraffauf/tg/archive/refs/tags/v0.6.0.tar.gz"
  sha256 "08347a478458c39c94275798534d95f990eda70de7923e8ab5fa2d328fde79bc"
  license "GPL-3.0-or-later"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w"), "./cmd/tg"
  end

  test do
    assert_match "Tangled", shell_output("#{bin}/tg --help")
  end
end

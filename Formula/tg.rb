class Tg < Formula
  desc "Command-line client for Tangled, the git forge built on atproto"
  homepage "https://github.com/alyraffauf/tg"
  url "https://github.com/alyraffauf/tg/archive/refs/tags/v0.4.0.tar.gz"
  sha256 "bd9a051017805b930edf8ab56b9e696da82f02acc9eca294366544a8c39fb2cf"
  license "GPL-3.0-or-later"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w"), "./cmd/tg"
  end

  test do
    assert_match "Tangled", shell_output("#{bin}/tg --help")
  end
end

class Tg < Formula
  desc "Command-line client for Tangled, the git forge built on atproto"
  homepage "https://github.com/alyraffauf/tg"
  url "https://github.com/alyraffauf/tg/archive/refs/tags/v0.5.0.tar.gz"
  sha256 "e5aa5b69bdfa07f35e96c0c4c23f512d736750d1cd87f9fa508ffb85febfa249"
  license "GPL-3.0-or-later"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w"), "./cmd/tg"
  end

  test do
    assert_match "Tangled", shell_output("#{bin}/tg --help")
  end
end

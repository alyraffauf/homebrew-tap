class Tg < Formula
  desc "Command-line client for Tangled, the git forge built on atproto"
  homepage "https://github.com/alyraffauf/tg"
  url "https://github.com/alyraffauf/tg/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "bf07ffee919da5c8e7dd49d7081dc835efb41df001a2b88817607aa597c54932"
  license "GPL-3.0-or-later"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w"), "./cmd/tg"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/tg --version 2>&1", 0)
  end
end
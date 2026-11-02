class Tg < Formula
  desc "Command-line client for Tangled, the git forge built on atproto"
  homepage "https://github.com/alyraffauf/tg"
  url "https://github.com/alyraffauf/tg/archive/refs/tags/v0.8.0.tar.gz"
  sha256 "0cea39d1d586f305f0756535e307333a03d48e1b67c5dd6a06c4edbc7ae22d75"
  license "GPL-3.0-or-later"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w"), "./cmd/tg"
  end

  test do
    assert_match "Tangled", shell_output("#{bin}/tg --help")
  end
end

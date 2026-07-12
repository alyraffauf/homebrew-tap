class Tg < Formula
  desc "Command-line client for Tangled, the git forge built on atproto"
  homepage "https://github.com/alyraffauf/tg"
  url "https://github.com/alyraffauf/tg/archive/451de824d8ad65faa13bb36cef1f9243bb4234ed.tar.gz"
  version "20260710"
  sha256 "665243662045ebf449adf0f4113d7f8c810897f194a5bf1ce4062d6f7612bf88"
  license "GPL-3.0-or-later"

  livecheck do
    url "https://api.github.com/repos/alyraffauf/tg/commits/master"
    strategy :json do |json|
      json["commit"]["author"]["date"][0..9].tr("-", "")
    end
  end

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w"), "./cmd/tg"
  end

  test do
    assert_match "Tangled", shell_output("#{bin}/tg --help")
  end
end

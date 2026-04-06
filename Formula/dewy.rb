class Dewy < Formula
  desc "Minimal terminal UI for Todoist"
  homepage "https://github.com/alyraffauf/dewy"
  url "https://github.com/alyraffauf/dewy/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "f8c10c75e0ded404c61acb3274ca49c90ddc517b85829ebceb1d1f2026a39cb1"
  license "GPL-3.0-or-later"

  depends_on "node"

  def install
    system "npm", "ci"
    system "npm", "run", "build"
    system "npm", "install", *std_npm_args
    bin.install_symlink libexec/"bin/dewy"
  end

  test do
    assert_match "dewy", shell_output("#{bin}/dewy --help 2>&1", 1)
  end
end

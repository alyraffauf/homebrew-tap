class ObsidianHeadless < Formula
  desc "Headless client for Obsidian Sync and Publish"
  homepage "https://github.com/obsidianmd/obsidian-headless"
  url "https://registry.npmjs.org/obsidian-headless/-/obsidian-headless-0.0.13.tgz"
  sha256 "9b8e1ad3917a65d53c5ab74d06acf5ec8d941e3b02bd9bd5d035d6800e533198"
  license "UNLICENSED"

  depends_on "node"

  on_linux do
    depends_on "python@3.13" => :build
    depends_on "gcc" => :build
  end

  livecheck do
    url "https://registry.npmjs.org/obsidian-headless/latest"
    strategy :json do |json|
      json["version"]
    end
  end

  def install
    ENV["npm_config_python"] = Formula["python@3.13"].opt_bin/"python3" if OS.linux?
    system "npm", "install", *std_npm_args
    bin.install_symlink libexec/"bin/ob"
  end

  test do
    assert_match "0.0.13", shell_output("#{bin}/ob --version")
  end
end

class ObsidianHeadless < Formula
  desc "Headless client for Obsidian Sync and Publish"
  homepage "https://github.com/obsidianmd/obsidian-headless"
  url "https://registry.npmjs.org/obsidian-headless/-/obsidian-headless-0.0.13.tgz"
  sha256 "9b8e1ad3917a65d53c5ab74d06acf5ec8d941e3b02bd9bd5d035d6800e533198"
  license "UNLICENSED"
  revision 1

  livecheck do
    url "https://registry.npmjs.org/obsidian-headless/latest"
    strategy :json do |json|
      json["version"]
    end
  end

  depends_on "node"

  on_linux do
    depends_on "gcc" => :build
    depends_on "python@3.14" => :build
  end

  def install
    ENV["npm_config_python"] = formula_opt_bin("python@3.14")/"python3" if OS.linux?
    # `--dangerously-allow-all-scripts` is needed for npm 11+ which blocks
    # install scripts by default. better-sqlite3 needs its install script to
    # compile native bindings via prebuild-install/node-gyp.
    system "npm", "install", *std_npm_args(ignore_scripts: false), "--dangerously-allow-all-scripts"
    bin.install_symlink libexec/"bin/ob"
  end

  test do
    assert_match "0.0.13", shell_output("#{bin}/ob --version")
  end
end

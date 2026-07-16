cask "helium-linux" do
  os linux: "linux"

  version "0.14.6.1"
  sha256 "2717a5b827bac7d785d61a783d1208e52d1d97849c556f681c96a835b571bfb0"

  url "https://github.com/imputnet/helium-linux/releases/download/#{version}/helium-#{version}-x86_64_linux.tar.xz",
      verified: "github.com/imputnet/helium-linux/"
  name "Helium"
  desc "Private, fast, and honest web browser"
  homepage "https://github.com/imputnet/helium"

  livecheck do
    url :url
    strategy :github_latest
  end

  binary "helium-#{version}-x86_64_linux/helium"

  preflight do
    xdg_data = ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")
    FileUtils.mkdir_p "#{xdg_data}/applications"
    FileUtils.mkdir_p "#{xdg_data}/icons/hicolor/256x256/apps"
  end

  postflight do
    xdg_data = ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")
    desktop_content = File.read("#{staged_path}/helium-#{version}-x86_64_linux/helium.desktop")
    desktop_content.gsub!(/^Exec=helium/, "Exec=#{HOMEBREW_PREFIX}/bin/helium")
    File.write("#{xdg_data}/applications/helium.desktop", desktop_content)
    FileUtils.cp("#{staged_path}/helium-#{version}-x86_64_linux/product_logo_256.png",
                 "#{xdg_data}/icons/hicolor/256x256/apps/helium.png")
  end

  uninstall_postflight do
    xdg_data = ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")
    FileUtils.rm("#{xdg_data}/applications/helium.desktop")
    FileUtils.rm("#{xdg_data}/icons/hicolor/256x256/apps/helium.png")
  end

  zap trash: [
    "#{ENV.fetch("XDG_CACHE_HOME", "#{Dir.home}/.cache")}/helium",
    "#{ENV.fetch("XDG_CONFIG_HOME", "#{Dir.home}/.config")}/helium",
    "#{ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")}/helium",
  ]
end

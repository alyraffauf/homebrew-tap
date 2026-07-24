cask "helium-linux" do
  os linux: "linux"

  version "0.14.8.2"
  sha256 "dd7530070f6c49080f8d3557de8046c0af4f41780de49fa4b5d2027b2ebbc001"

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

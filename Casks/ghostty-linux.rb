cask "ghostty-linux" do
  os linux: "linux"

  version "1.3.1"
  arch arm: "aarch64", intel: "x86_64"

  sha256 x86_64_linux: "fde48d2b716afd1978766879bbf1aae30dd305e8ad86a1037a2614a14d82dc28",
         arm64_linux:  "55b7d1e2073b80954e23167a70f9e5994189d81e954d36dad4d2dc2d2fe6c121"

  url "https://github.com/pkgforge-dev/ghostty-appimage/releases/download/v#{version}/Ghostty-#{version}-#{arch}.AppImage",
      verified: "github.com/pkgforge-dev/"
  name "Ghostty"
  desc "Fast, feature-rich, and cross-platform terminal emulator"
  homepage "https://ghostty.org/"

  livecheck do
    url :stable
    strategy :github_latest
  end

  binary "Ghostty-#{version}-#{arch}.AppImage", target: "ghostty"

  preflight do
    appimage = "#{staged_path}/Ghostty-#{version}-#{arch}.AppImage"
    FileUtils.chmod "+x", appimage
    raise "ghostty-linux: AppImage extraction failed" unless system appimage, "--appimage-extract", chdir: staged_path
  end

  postflight do
    xdg_data = ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")
    FileUtils.mkdir_p "#{xdg_data}/applications"

    desktop_path = "#{staged_path}/squashfs-root/com.mitchellh.ghostty.desktop"
    desktop_content = File.read(desktop_path)
    desktop_content.gsub!(/^Exec=.*/, "Exec=#{HOMEBREW_PREFIX}/bin/ghostty")
    desktop_content.gsub!(/^TryExec=.*/, "TryExec=#{HOMEBREW_PREFIX}/bin/ghostty")
    desktop_content.gsub!(/^Icon=.*/, "Icon=ghostty")
    desktop_content.gsub!(/^DBusActivatable=.*/, "DBusActivatable=false")
    File.write("#{xdg_data}/applications/com.mitchellh.ghostty.desktop", desktop_content)

    Dir.glob("#{staged_path}/squashfs-root/share/icons/hicolor/*/apps/com.mitchellh.ghostty.png").each do |icon|
      size_dir = File.basename(File.dirname(icon, 2))
      target_dir = "#{xdg_data}/icons/hicolor/#{size_dir}/apps"
      FileUtils.mkdir_p target_dir
      FileUtils.cp(icon, "#{target_dir}/ghostty.png")
    end
  end

  uninstall_postflight do
    xdg_data = ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")
    FileUtils.rm("#{xdg_data}/applications/com.mitchellh.ghostty.desktop")
    Dir.glob("#{xdg_data}/icons/hicolor/*/apps/ghostty.png").each do |icon|
      FileUtils.rm(icon)
    end
  end

  zap trash: [
    "#{ENV.fetch("XDG_CONFIG_HOME", "#{Dir.home}/.config")}/ghostty",
    "#{ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")}/ghostty",
  ]
end

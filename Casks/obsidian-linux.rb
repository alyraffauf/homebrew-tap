cask "obsidian-linux" do
  os linux: "linux"

  version "1.12.7"
  sha256 "f6d8b96fe685a8632c819cc093a248ace0f6bab410f44a6c929a2611b1ebb17c"

  url "https://github.com/obsidianmd/obsidian-releases/releases/download/v#{version}/Obsidian-#{version}.AppImage",
      verified: "github.com/obsidianmd/"
  name "Obsidian"
  desc "Knowledge base that works on top of a local folder of plain text Markdown files"
  homepage "https://obsidian.md/"

  livecheck do
    url "https://raw.githubusercontent.com/obsidianmd/obsidian-releases/master/desktop-releases.json"
    strategy :json do |json|
      json["latestVersion"]
    end
  end

  binary "Obsidian-#{version}.AppImage", target: "obsidian"

  preflight do
    appimage = "#{staged_path}/Obsidian-#{version}.AppImage"
    FileUtils.chmod "+x", appimage
    unless system appimage, "--appimage-extract", chdir: staged_path
      raise "obsidian-linux: AppImage extraction failed"
    end
  end

  postflight do
    xdg_data = ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")
    FileUtils.mkdir_p "#{xdg_data}/applications"

    desktop_path = "#{staged_path}/squashfs-root/obsidian.desktop"
    desktop_content = File.read(desktop_path)
    desktop_content.gsub!(/^Exec=.*/, "Exec=#{HOMEBREW_PREFIX}/bin/obsidian %U")
    desktop_content.gsub!(/^Icon=.*/, "Icon=obsidian")
    File.write("#{xdg_data}/applications/obsidian.desktop", desktop_content)

    Dir.glob("#{staged_path}/squashfs-root/usr/share/icons/hicolor/*/apps/obsidian.png").each do |icon|
      size_dir = File.basename(File.dirname(File.dirname(icon)))
      target_dir = "#{xdg_data}/icons/hicolor/#{size_dir}/apps"
      FileUtils.mkdir_p target_dir
      FileUtils.cp(icon, "#{target_dir}/obsidian.png")
    end
  end

  uninstall_postflight do
    xdg_data = ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")
    FileUtils.rm_f "#{xdg_data}/applications/obsidian.desktop"
    Dir.glob("#{xdg_data}/icons/hicolor/*/apps/obsidian.png").each do |icon|
      FileUtils.rm_f icon
    end
  end

  zap trash: [
    "#{ENV.fetch("XDG_CONFIG_HOME", "#{Dir.home}/.config")}/obsidian",
    "#{ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")}/obsidian",
  ]
end

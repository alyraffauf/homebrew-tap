cask "todoist-linux" do
  os linux: "linux"

  version "9.30.0"
  sha256 "21ec180a3daee7398d3b1ec1217fdd0c7078ab66db0e5cb23c82ac10aa734c9e"

  url "https://electron-dl.todoist.net/linux/Todoist-linux-#{version}-x86_64-latest.AppImage"
  name "Todoist"
  desc "To-do list and task manager"
  homepage "https://todoist.com/"

  livecheck do
    url "https://todoist.com/linux_app/appimage"
    strategy :header_match do |headers|
      headers["location"][/Todoist-linux-(.+?)-x86_64-latest\.AppImage/, 1]
    end
  end

  binary "Todoist-linux-#{version}-x86_64-latest.AppImage", target: "todoist"

  preflight do
    appimage = "#{staged_path}/Todoist-linux-#{version}-x86_64-latest.AppImage"
    FileUtils.chmod "+x", appimage
    raise "todoist-linux: AppImage extraction failed" unless system appimage, "--appimage-extract", chdir: staged_path
  end

  postflight do
    xdg_data = ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")
    FileUtils.mkdir_p "#{xdg_data}/applications"

    desktop_content = File.read("#{staged_path}/squashfs-root/todoist.desktop")
    desktop_content.gsub!(/^Exec=AppRun/, "Exec=#{HOMEBREW_PREFIX}/bin/todoist")
    desktop_content.gsub!(/^Exec=todoist --new-window/, "Exec=#{HOMEBREW_PREFIX}/bin/todoist --new-window")
    File.write("#{xdg_data}/applications/todoist.desktop", desktop_content)

    Dir.glob("#{staged_path}/squashfs-root/usr/share/icons/hicolor/*/apps/todoist.png").each do |icon|
      size_dir = File.basename(File.dirname(icon, 2))
      target_dir = "#{xdg_data}/icons/hicolor/#{size_dir}/apps"
      FileUtils.mkdir_p target_dir
      FileUtils.cp(icon, "#{target_dir}/todoist.png")
    end
  end

  uninstall_postflight do
    xdg_data = ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")
    FileUtils.rm("#{xdg_data}/applications/todoist.desktop")
    Dir.glob("#{xdg_data}/icons/hicolor/*/apps/todoist.png").each do |icon|
      FileUtils.rm(icon)
    end
  end

  zap trash: [
    "#{ENV.fetch("XDG_CACHE_HOME", "#{Dir.home}/.cache")}/Todoist",
    "#{ENV.fetch("XDG_CONFIG_HOME", "#{Dir.home}/.config")}/Todoist",
    "#{ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")}/Todoist",
  ]
end

cask "opencode-desktop-linux" do
  version "1.15.11"
  sha256 "a2805908a6f71a574a4a253301e19395443c8c9318d3a7dcbb67257e7e3f07f0"

  url "https://github.com/anomalyco/opencode/releases/download/v#{version}/opencode-desktop-linux-x86_64.rpm",
      verified: "github.com/anomalyco/opencode/"
  name "OpenCode"
  desc "Open source AI coding agent desktop client"
  homepage "https://opencode.ai/"

  livecheck do
    url "https://github.com/anomalyco/opencode/releases/latest/download/latest.json"
    strategy :json do |json|
      json["version"]
    end
  end

  depends_on formula: "rpm2cpio"
  depends_on formula: "cpio"

  # The RPM ships an Electron app under /opt/OpenCode. Its main binary is named
  # after the app id, which changes between releases (e.g. @opencode-aidesktop ->
  # ai.opencode.desktop), so we launch it through a stable wrapper (created in
  # preflight) that resolves its own location and execs the real binary.
  binary "opt/OpenCode/opencode-desktop"

  preflight do
    rpm2cpio = Formula["rpm2cpio"].bin/"rpm2cpio"
    cpio = Formula["cpio"].bin/"cpio"
    system "sh", "-c", "'#{rpm2cpio}' '#{staged_path}/opencode-desktop-linux-x86_64.rpm' | '#{cpio}' -idm --quiet",
           chdir: staged_path

    app_dir = "#{staged_path}/opt/OpenCode"

    # The Electron entrypoint is the lone executable that isn't a Chromium helper.
    exe = Dir.children(app_dir).sort.find do |f|
      path = "#{app_dir}/#{f}"
      next false unless File.file?(path) && File.executable?(path)
      next false if ["chrome-sandbox", "chrome_crashpad_handler"].include?(f)

      f !~ /\.(so|pak|bin|dat|json|html|txt)$/ && f !~ /\.so\./
    end
    raise "opencode-desktop-linux: no Electron binary found in #{app_dir}" if exe.nil?

    File.write("#{app_dir}/opencode-desktop", <<~SH)
      #!/bin/sh
      # Resolve this script's real directory (it is symlinked into the Homebrew bin).
      dir="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
      # --no-sandbox: Homebrew cannot install the setuid-root chrome-sandbox helper.
      exec "$dir/#{exe}" --no-sandbox "$@"
    SH
    FileUtils.chmod "+x", "#{app_dir}/opencode-desktop"

    # Stash the largest app icon next to the binary; icons live under usr/share in
    # the payload and would otherwise be discarded.
    icon = Dir.glob("#{staged_path}/usr/share/icons/hicolor/*/apps/*.png").max_by { |p| File.size(p) }
    FileUtils.cp(icon, "#{app_dir}/opencode.png") if icon
  end

  postflight do
    apps = "#{Dir.home}/.local/share/applications"
    icon_dir = "#{Dir.home}/.local/share/icons/hicolor/128x128/apps"
    FileUtils.mkdir_p apps
    FileUtils.mkdir_p icon_dir

    icon_src = "#{staged_path}/opt/OpenCode/opencode.png"
    FileUtils.cp(icon_src, "#{icon_dir}/opencode-desktop.png") if File.exist?(icon_src)

    File.write("#{apps}/opencode-desktop.desktop", <<~EOS)
      [Desktop Entry]
      Name=OpenCode
      Comment=Open source AI coding agent desktop client
      Exec=#{HOMEBREW_PREFIX}/bin/opencode-desktop %U
      Icon=opencode-desktop
      Terminal=false
      Type=Application
      StartupWMClass=OpenCode
      MimeType=x-scheme-handler/opencode;
      Categories=Development;
    EOS
  end

  uninstall_postflight do
    FileUtils.rm_f "#{Dir.home}/.local/share/applications/opencode-desktop.desktop"
    FileUtils.rm_f "#{Dir.home}/.local/share/icons/hicolor/128x128/apps/opencode-desktop.png"
  end

  zap trash: [
    "~/.cache/ai.opencode.desktop",
    "~/.config/ai.opencode.desktop",
    "~/.local/share/ai.opencode.desktop",
  ]
end

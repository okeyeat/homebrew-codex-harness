class CodexHarness < Formula
  desc "Shared session policy and startup guide for Codex"
  homepage "https://github.com/okeyeat/homebrew-codex-harness"
  version "0.3.0"
  depends_on "python@3.14"
  on_macos do
    on_arm do
      url "https://github.com/okeyeat/homebrew-codex-harness/releases/download/v0.3.0/codex-harness-0.3.0-darwin-arm64.tar.gz"
      sha256 "f08051ff8b21fda45bc811049cfdc10ab5ebfbc1a3715d380a6fb7735fa29d15"
    end
    on_intel do
      url "https://github.com/okeyeat/homebrew-codex-harness/releases/download/v0.3.0/codex-harness-0.3.0-darwin-amd64.tar.gz"
      sha256 "c7e3b0f3d67af29b339542c0745e52baba815f4a714f7f13fb23a864761e88de"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/okeyeat/homebrew-codex-harness/releases/download/v0.3.0/codex-harness-0.3.0-linux-arm64.tar.gz"
      sha256 "342905a16f3b7cf6f7dc91e8660be453a365b800b449637dffd74582fb192888"
    end
    on_intel do
      url "https://github.com/okeyeat/homebrew-codex-harness/releases/download/v0.3.0/codex-harness-0.3.0-linux-amd64.tar.gz"
      sha256 "d2c8c86ac2a53d9317eea8b40b364567c037393de19bcfc20035880ed8cf44cd"
    end
  end
  def install
    libexec.install Dir["*", ".[^.]*"]
    bin.install_symlink libexec/"bin/harness"
    { "codex-harness-setup" => "setup.py", "codex-harness" => "distribution/launch.py" }.each do |name, script|
      (bin/name).write <<~SH
        #!/bin/sh
        exec "#{Formula["python@3.14"].opt_bin}/python3.14" "#{libexec}/#{script}" "$@"
      SH
      (bin/name).chmod 0755
    end
  end

  def caveats
    <<~EOS
      Connect your Codex profile:
        codex-harness-setup
      Start with a policy notice:
        codex-harness
      Review the hook in /hooks if Codex asks. Model and login settings are preserved.
    EOS
  end

  test do
    assert_match "role-routing-2026-09-13", shell_output("#{bin}/harness session --cwd #{testpath} --format json")
    system bin/"codex-harness-setup", "--codex-home", testpath/"profile", "--runtime-home", testpath/"state/runtime"
    assert_path_exists testpath/"state/runtime/POLICY.md"
    assert_path_exists testpath/"profile/hooks.json"
  end
end

class CodexHarness < Formula
  desc "Shared session policy and startup guide for Codex"
  homepage "https://github.com/okeyeat/homebrew-codex-harness"
  version "0.4.0"
  depends_on "python@3.14"
  on_macos do
    on_arm do
      url "https://github.com/okeyeat/homebrew-codex-harness/releases/download/v0.4.0/codex-harness-0.4.0-darwin-arm64.tar.gz"
      sha256 "00977831373b4b86d908c6c82c5b6044e8c083496bd0370e6791a2950b378105"
    end
    on_intel do
      url "https://github.com/okeyeat/homebrew-codex-harness/releases/download/v0.4.0/codex-harness-0.4.0-darwin-amd64.tar.gz"
      sha256 "145f296483b8ac75013b31b757fc8469c9a45c3dda5550040067cadfed1755a3"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/okeyeat/homebrew-codex-harness/releases/download/v0.4.0/codex-harness-0.4.0-linux-arm64.tar.gz"
      sha256 "794a192efe2c45f97b9b0684b1c64fb3839fd65d22b63c6990024e1b5c4cf938"
    end
    on_intel do
      url "https://github.com/okeyeat/homebrew-codex-harness/releases/download/v0.4.0/codex-harness-0.4.0-linux-amd64.tar.gz"
      sha256 "4001800d3717c6f0bd3dfe349db96f42ae6fe9af9676d1bb56534dc94c328781"
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
    assert_match "direct-session-2026-09-13", shell_output("#{bin}/harness session --cwd #{testpath} --format json")
    system bin/"codex-harness-setup", "--codex-home", testpath/"profile", "--runtime-home", testpath/"state/runtime"
    assert_path_exists testpath/"state/runtime/POLICY.md"
    assert_path_exists testpath/"profile/hooks.json"
  end
end

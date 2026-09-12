class CodexHarness < Formula
  desc "Shared session policy and startup guide for Codex"
  homepage "https://github.com/okeyeat/homebrew-codex-harness"
  version "0.2.0"
  depends_on "python@3.14"
  on_macos do
    on_arm do
      url "https://github.com/okeyeat/homebrew-codex-harness/releases/download/v0.2.0/codex-harness-0.2.0-darwin-arm64.tar.gz"
      sha256 "e68a8e2dbcd2a6f021e5a170288fafc12b6fbc68834e2a8c4934af24db211ee2"
    end
    on_intel do
      url "https://github.com/okeyeat/homebrew-codex-harness/releases/download/v0.2.0/codex-harness-0.2.0-darwin-amd64.tar.gz"
      sha256 "a17efd6f33f26d21532bed29708d76f728a66085eef41f3284a343db62323185"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/okeyeat/homebrew-codex-harness/releases/download/v0.2.0/codex-harness-0.2.0-linux-arm64.tar.gz"
      sha256 "b894fe9c33e5a14dc74f1764ddfe7a4edc613532ee64cc061b42c55b62c37ed3"
    end
    on_intel do
      url "https://github.com/okeyeat/homebrew-codex-harness/releases/download/v0.2.0/codex-harness-0.2.0-linux-amd64.tar.gz"
      sha256 "2c3a1af865c0f3e3a9f7caaa28f7ebae3dfdfec3ee4eadcc025dde30de586d83"
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
    assert_match "usage-aware-2026-09-12", shell_output("#{bin}/harness session --cwd #{testpath} --format json")
    system bin/"codex-harness-setup", "--codex-home", testpath/"profile", "--runtime-home", testpath/"state/runtime"
    assert_path_exists testpath/"state/runtime/POLICY.md"
    assert_path_exists testpath/"profile/hooks.json"
  end
end

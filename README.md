# Codex Harness

Codex의 작업 지속성, 사용량 점검, 모델 선택과 검증 기준을 맞추는 공통 세션 정책입니다. 개발·디자인·Figma·마케팅 작업에서 사용할 수 있습니다. 이 저장소는 **배포 전용 Homebrew tap**이며 원본 개발 저장소의 이력·개인 설정·인증 정보는 포함하지 않습니다.

## 가장 쉬운 설치: Homebrew

Codex CLI에 먼저 로그인한 뒤 터미널에서 실행하세요.

```bash
brew install okeyeat/codex-harness/codex-harness
codex-harness-setup
codex-harness
```

- 첫 명령은 실행 파일과 Python을 설치합니다. Go나 GitHub 계정은 필요 없습니다.
- 두 번째 명령은 현재 Codex 프로필에 공통 지침과 SessionStart 훅을 연결합니다. 변경 전에 확인하려면 `codex-harness-setup --dry-run`을 사용하세요.
- 세 번째 명령은 정책 버전과 안내 링크를 먼저 표시한 다음 원래 Codex를 실행합니다. 기존 옵션도 전달할 수 있습니다. 안내는 실행 시 한 번이며 이후 질문·명령·첫 응답에 반복하지 않습니다.
- Codex에서 `/hooks`에 신뢰 확인이 나오면 하네스 훅을 검토하고 승인하세요. 설치기는 이 승인을 우회하지 않습니다.

기존 `codex` 명령으로 실행해도 정책은 연결됩니다. 다만 Codex 0.153.4의 SessionStart 훅은 첫 턴에 실행되므로 **질문 전 안내**는 `codex-harness` 실행 명령을 사용하세요. 일반 `codex`에서도 같은 실행 경로를 쓰고 싶다면 본인의 셸 설정에 `alias codex=codex-harness`를 추가할 수 있습니다. 설치기가 셸 설정을 임의로 수정하지는 않습니다.

`codex-harness`는 안내를 보존하기 위해 대화형 실행에 `--no-alt-screen`을 추가합니다. 링크를 지원하는 터미널에서는 ‘이곳’을 클릭할 수 있고, 지원하지 않는 터미널에서는 함께 표시한 URL을 여세요. `--help`, `--version`, `exec` 등 비대화형 사용에는 안내를 끼워 넣지 않습니다.

## Homebrew 없이 설치

macOS 또는 Linux에서 Python 3.9 이상과 curl만 있으면 됩니다. Windows는 WSL에서 Linux 방법을 사용하세요. 네이티브 Windows는 지원하지 않습니다.

```bash
curl -fsSL https://raw.githubusercontent.com/okeyeat/homebrew-codex-harness/main/install.py -o codex-harness-install.py
python3 codex-harness-install.py
```

설치기는 OS·CPU에 맞는 실행 파일을 다운로드하고 배포본에 고정된 SHA-256을 대조합니다. 기본 위치는 사용자 홈의 `.local/share/codex-harness/session-runtime`이고 Codex 프로필은 `CODEX_HOME` 또는 `~/.codex`입니다. 기존 하네스 연결이 있으면 그 runtime을 재사용합니다. 다운로드 임시 파일은 기본 또는 지정 저장 위치에 만들고 종료 시 정리합니다. `--dry-run`은 프로필을 수정하지 않지만 다운로드용 상위 폴더는 만들 수 있습니다.

Homebrew 없이 설치한 경우 `codex`를 그대로 사용하세요. 질문 전 안내가 필요하면 다음으로 실행합니다.

```bash
python3 ~/.local/share/codex-harness/session-runtime/launch.py
```

별도 Codex 프로필이나 외장 저장소는 다음처럼 지정합니다. 꺾쇠 괄호 대신 실제 경로를 사용하세요.

```bash
python3 codex-harness-install.py --codex-home '<Codex 프로필 경로>' --runtime-home '<저장 경로>/session-runtime'
```

## 업데이트

새 릴리스 게시만으로 기존 사용자에게 자동 알림이나 업데이트 요청이 뜨지 않습니다. 아래 명령으로 직접 업데이트하세요. 진행 중인 세션의 초기 지침과 모델은 자동 교체되지 않으며, 작업을 강제로 인계하거나 다시 열지 않습니다.

```bash
brew update
brew upgrade okeyeat/codex-harness/codex-harness
codex-harness-setup
```

Homebrew 없이 설치했다면 위 설치 스크립트를 다시 다운로드해 실행하세요. 설치와 업데이트 모두 기존 사용자 지침·다른 훅·모델·로그인·권한 설정을 보존합니다. 프로필마다 연결은 한 번씩 해야 하며 기존 대화의 초기 지침은 자동 교체되지 않습니다. 새 초기 지침은 이후 사용자가 시작하는 세션에서 읽습니다. 현재 작업은 그대로 진행하세요.

## 기본 작업 방식과 문서 위치

현재 세션에서 직접 끝내는 것이 기본입니다. 새 일반 작업 모델은 Astra/medium이며, 범위·완료 기준이 확정된 반복 작업이고 미해결 설계·복잡한 판단이 없을 때만 Luna/max를 선택합니다. 사용자·프로젝트의 명시 선택과 진행 중인 모델을 보존합니다. 작은 작업이나 단계 변경만으로 모델·워커를 바꾸지 않습니다.

독립 리뷰가 필요하면 네이티브 서브에이전트를 우선합니다. 별도 자식 워크스페이스는 동시 수정의 파일시스템·브랜치 격리 또는 실행 환경 격리가 필요한 경우에만 만듭니다. 컨텍스트 비율·토큰 수·호출 횟수로 정기 점검·자동 인계·새 탭을 요구하지 않습니다. 실제 반복 읽기·과도한 출력이 나타날 때만 정리하고 필수 검증은 유지합니다.

공통 기준은 [POLICY.md](POLICY.md), 상세 조건은 [업무별 예시](docs/use-cases.md)에 있습니다. AGENTS.md에는 짧은 연결 안내만 넣으며 전체 정책·사례를 복제하지 않습니다. 이 배포는 Codex용이며 기존 OMP adapter의 별도 routing·quota 구현은 변경하지 않습니다.

## 확인과 복구

시작 안내의 정책은 `direct-session-2026-09-13`입니다. [정책 전문](POLICY.md)과 [업무별 예시](docs/use-cases.md)를 확인하세요. 모델 이름은 계정에서 지원하는지 확인한 뒤 선택하세요. 이 정책은 자동 모델 전환기, 사용량 강제 차단기 또는 사용량 절감 보증이 아닙니다.

설치 완료 시 백업 경로가 출력됩니다. 설치 직후 되돌리려면 다음을 사용합니다. 이후 직접 수정한 파일은 덮어쓰지 않고 복구를 거부합니다.

```bash
codex-harness-setup --rollback '<출력된 백업 경로>' --dry-run
codex-harness-setup --rollback '<출력된 백업 경로>'
```

Homebrew 없이 설치한 경우 `python3 <runtime 경로>/rollback.py --rollback '<백업 경로>' --apply`를 사용합니다. 원상 복구 후 Homebrew 패키지는 `brew uninstall codex-harness`로 제거합니다. 여러 차례 업데이트했다면 최신 백업부터 역순으로 복구합니다. 개인 백업은 공개 저장소에 올리지 마세요.

## Codex 플러그인과의 차이

Codex 플러그인은 훅과 스킬을 묶어 repository marketplace로 공유할 수 있습니다. 하지만 웹에서 플러그인을 설치하는 것만으로 로컬 실행 파일이 배포되지는 않으며, 훅 신뢰 확인도 필요합니다. 이번 배포는 Homebrew와 직접 설치 경로를 제공합니다. OpenAI 공식 플러그인 카탈로그에 등록된 제품은 아닙니다. [공식 플러그인 문서](https://learn.chatgpt.com/docs/plugins)

## 포함 범위와 개인정보

배포 파일은 명시적으로 선택한 정책, 설치기, 어댑터, 실행 파일, 가이드로 구성됩니다. 개인 사용자 경로·계정 프로필·인증 파일·세션 기록·개인 이메일·원본 Git 이력을 배포하지 않습니다. GitHub의 공개 소유자 이름과 릴리스 버전은 배포 식별자로 남습니다. 설치기가 만든 절대 경로와 백업은 각 사용자의 PC에만 저장됩니다.

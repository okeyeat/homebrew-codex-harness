# Orca 세션 갱신과 위임

실행 직전 설치된 Orca의 CLI 가이드를 읽는다. 명령 실행은 해당 작업의 권한 범위에서만 한다.

## 갱신

1. 현재 workspace ID, terminal ID, 실제 모델과 추론을 읽는다. 기본 launcher 모델을 상속 모델로 추정하지 않는다.
2. 목표, 사용자 결정, 담당 경로, 변경 revision, 검증 결과, 미완료 작업, 기존 child ID를 짧게 인계한다.
3. `orca terminal create --worktree <same-workspace> --title <role-and-model> --command <launcher-with-explicit-model-and-effort> --json`으로 새 탭을 만든다. resume으로 이전 문맥을 복구하는 대신 인계문으로 새 세션을 시작한다.
4. readiness와 입력 수신, 가능하면 실제 turn 시작을 확인한다. 모델/추론 적용 증거를 기록한다.
5. 인계가 확인되면 기존 세션은 수정과 감독을 멈춘다. 기존 탭과 기록은 보존한다. 실패하면 새 세션의 상태를 먼저 조회하고 중복 생성하지 않는다.

## 위임

조정자는 Astra/medium으로 실행한다. 작업자는 역할에 따라 Astra 또는 Luna/max를 명시한다.

1. 부모 작업의 저장된 child ID를 조회하고 존재 및 소유권을 확인한다.
2. 없을 때만 `orca worktree create --parent-worktree <parent> --name <workstream> --json`으로 하나 만든다. 기준 branch와 setup 동작을 먼저 확인한다.
3. 모델/추론을 명시할 수 있는 launcher로 child 내부 터미널 탭에 작업자를 시작한다. 기본 shell이 생겼다면 미사용 여부를 확인한 경우에만 정리한다.
4. 추가 세션은 같은 child에 terminal create를 사용한다. child 안에서 worktree create를 재귀적으로 호출하지 않는다.
5. 조정자 1명과 작업자 최대 2명. 같은 파일 수정과 Git index/branch 변경은 한 명씩 한다. 리뷰 전에 검토 revision을 고정한다.
6. 역할, 실제 모델/추론, workspace/terminal ID, 소유 경로, 결과를 기록한다.

## 구현 경계

현재 확인된 인터페이스는 터미널 탭이다. native chat 탭이나 모델 자동 감지는 지원을 확인한 경우에만 사용한다.
문서 규칙은 강제 실행기가 아니다. 모델이나 세션 제어가 없으면 제한을 정확히 보고한다.

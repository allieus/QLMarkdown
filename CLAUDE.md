# QLMarkdown (fork)

## 원격 저장소 규칙 (절대 준수)

- 이 저장소는 https://github.com/sbarex/QLMarkdown 의 포크다.
- **upstream(sbarex/QLMarkdown)에는 절대 PR·이슈·코멘트 등 어떤 피드백도 보내지 않는다.**
- PR·푸시는 항상 **https://github.com/allieus/QLMarkdown (origin)** 으로만 보낸다.
- upstream과의 관계는 **주기적 pull(변경 가져오기)만** 허용한다.

## 이슈 관리 규칙

- 작업 이슈는 **allieus/QLMarkdown 저장소의 GitHub 이슈**로 남긴다 (upstream에는 절대 만들지 않는다).
- 이슈 처리 중에는 **진행 상황을 해당 이슈에 댓글로 계속 기록**한다 (착수·중간 경과·해결 내용).

## 로컬 빌드·설치 규칙

- 로컬 빌드는 반드시 **`scripts/build-local.sh`** 를 사용한다 (`--install` 옵션으로 /Applications 교체 + Quick Look 재등록까지).
- 일반 `xcodebuild`는 upstream 팀 ID 서명 설정 때문에 인증서 오류로 실패한다 — 직접 xcodebuild로 서명 문제를 다시 풀려고 하지 말 것. 우회 원리와 절차는 스크립트 주석에 있다.
- 사전 요구: `brew install autoconf automake` (pcre2 autogen이 aclocal을 요구).
- Quick Look 익스텐션 설정은 호스트 앱(`/Applications/QLMarkdown.app`)에서 하며, 앱 그룹 `group.org.sbarex.qlmarkdown` UserDefaults로 공유된다. 설정 변경 후 미리보기 반영이 안 되면 `qlmanage -r`.

## 회고 규칙 (이슈 해결 후 필수)

- **모든 이슈를 해결한 뒤에는 반드시 자동으로 회고를 수행**하고, 산출물을 `docs/retrospectives.md`에 남긴다.
- 회고 산출물은 **단순 append 금지** — 매번 문서 전체를 다시 읽고 중복 제거·구조 정리·일반화하여, 고품질의 일관된 단일 문서로 유지한다.
- 회고에 담을 내용: 무엇이 문제였나, 원인, 해결 방법, 재발 방지책(하네스·문서화), 다음에 재활용할 교훈.
- 다음 작업 시작 전 `docs/retrospectives.md`를 먼저 참조하여 과거 교훈을 활용한다.

#!/bin/bash
# 로컬 개발용 빌드 + ad-hoc 서명 + 설치 스크립트
#
# upstream(sbarex)의 팀 ID(D5VMCLD3ZK) 서명 설정 때문에 일반 xcodebuild는
# 인증서/프로비저닝 오류로 실패한다. 서명 없이 빌드한 뒤 ad-hoc(-)으로
# 안쪽(dylib/framework/xpc/appex) → 바깥(app) 순서로 수동 서명한다.
#
# 사전 요구: brew install autoconf automake  (pcre2 autogen에 aclocal 필요)
#
# 사용법:
#   scripts/build-local.sh            # 빌드 + 서명만
#   scripts/build-local.sh --install  # 빌드 + 서명 + /Applications 교체 + QL 재등록
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

echo "==> 빌드 (서명 비활성)"
xcodebuild -project QLMarkdown.xcodeproj -scheme QLMarkdown -configuration Release build \
    CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO ENABLE_HARDENED_RUNTIME=NO -quiet

APP="$(xcodebuild -project QLMarkdown.xcodeproj -scheme QLMarkdown -configuration Release \
    -showBuildSettings 2>/dev/null | awk '/ BUILT_PRODUCTS_DIR =/{print $3}')/QLMarkdown.app"
[ -d "$APP" ] || { echo "빌드 산출물을 찾을 수 없음: $APP" >&2; exit 1; }
echo "==> 산출물: $APP"

echo "==> ad-hoc 서명 (안쪽 → 바깥)"
# 1) 프레임워크 내 실행파일·dylib
find "$APP/Contents" \( -name "*.dylib" -o -perm +111 -type f \) -path "*Frameworks*" \
    -exec codesign --force -s - {} \;
# 2) XPC 서비스·앱 익스텐션
find "$APP/Contents" \( -name "*.xpc" -o -name "*.appex" \) -print0 |
    while IFS= read -r -d '' b; do codesign --force --deep -s - "$b"; done
# 3) Quick Look 익스텐션은 앱 그룹 entitlements를 유지해야 설정 공유가 동작
codesign --force -s - --entitlements "$REPO_ROOT/QLExtension/QLExtension.entitlements" \
    "$APP/Contents/PlugIns/Markdown QL Extension.appex"
# 4) 앱 본체 — entitlements의 빌드 변수를 실제 번들 ID로 치환해 사용
ENT="$(mktemp -t qlmarkdown-entitlements).plist"
sed 's/\$(PRODUCT_BUNDLE_IDENTIFIER)/org.sbarex.QLMarkdown/g' \
    "$REPO_ROOT/QLMarkdown/QLMarkdown.entitlements" > "$ENT"
codesign --force -s - --entitlements "$ENT" "$APP"
rm -f "$ENT"

codesign --verify --deep --strict "$APP"
echo "==> 서명 검증 OK"

if [ "${1:-}" = "--install" ]; then
    echo "==> /Applications 교체 및 Quick Look 재등록"
    osascript -e 'quit app "QLMarkdown"' 2>/dev/null || true
    rm -rf /Applications/QLMarkdown.app
    cp -R "$APP" /Applications/
    xattr -dr com.apple.quarantine /Applications/QLMarkdown.app 2>/dev/null || true
    open /Applications/QLMarkdown.app
    sleep 3
    qlmanage -r
    pluginkit -m -i org.sbarex.QLMarkdown.QLExtension
    echo "==> 설치 완료"
fi

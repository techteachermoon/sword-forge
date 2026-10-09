#!/bin/sh
# tools/test.html = index.html 에서 즉시실행 함수 껍데기 두 줄만 뺀 사본 (게임 전역 변수에 테스트 코드가 접근할 수 있게)
cd "$(dirname "$0")/.." || exit 1
a=$(grep -n '^(() => {$' index.html | cut -d: -f1); b=$(grep -n '^})();$' index.html | cut -d: -f1)
sed "${a}d;${b}d" index.html > tools/test.html && echo "tools/test.html ok"

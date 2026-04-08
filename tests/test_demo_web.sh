#!/bin/sh

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)

cd "$REPO_ROOT"
./scripts/run_demo_samples.sh >/dev/null

test -f "$REPO_ROOT/manual_runs/latest/web_demo/index.html"
test -f "$REPO_ROOT/manual_runs/latest/web_demo/demo_data.js"
test -f "$REPO_ROOT/manual_runs/latest/web_demo/styles.css"
test -f "$REPO_ROOT/manual_runs/latest/web_demo/app.js"

grep -q "SQL 처리기 발표 데모" "$REPO_ROOT/manual_runs/latest/web_demo/index.html"
grep -q "테이블 구조와 현재 상태" "$REPO_ROOT/manual_runs/latest/web_demo/index.html"
grep -q "테이블 정의" "$REPO_ROOT/manual_runs/latest/web_demo/app.js"
grep -q "현재 테이블 상태" "$REPO_ROOT/manual_runs/latest/web_demo/app.js"
grep -q '"id": "01_happy_path"' "$REPO_ROOT/manual_runs/latest/web_demo/demo_data.js"
grep -q '"id": "03_duplicate_student_id"' "$REPO_ROOT/manual_runs/latest/web_demo/demo_data.js"
grep -q '"id": "04_unsupported_sql"' "$REPO_ROOT/manual_runs/latest/web_demo/demo_data.js"
grep -q '"id": "05_missing_semicolon"' "$REPO_ROOT/manual_runs/latest/web_demo/demo_data.js"
grep -q '"id": "06_unterminated_string"' "$REPO_ROOT/manual_runs/latest/web_demo/demo_data.js"
grep -q '"id": "07_entry_log_unauthorized"' "$REPO_ROOT/manual_runs/latest/web_demo/demo_data.js"
grep -q '"id": "08_entry_log_missing_student"' "$REPO_ROOT/manual_runs/latest/web_demo/demo_data.js"
grep -q '"id": "09_stop_after_middle_error"' "$REPO_ROOT/manual_runs/latest/web_demo/demo_data.js"
grep -q '"authorization": "T"' "$REPO_ROOT/manual_runs/latest/web_demo/demo_data.js"
grep -q '"entered_at": "2026-04-08 09:00:00"' "$REPO_ROOT/manual_runs/latest/web_demo/demo_data.js"
grep -q "failed to insert student: duplicate id 302" "$REPO_ROOT/manual_runs/latest/web_demo/demo_data.js"
grep -q "failed to parse statement" "$REPO_ROOT/manual_runs/latest/web_demo/demo_data.js"
grep -q "failed to split statements: every statement must end with ';'" "$REPO_ROOT/manual_runs/latest/web_demo/demo_data.js"
grep -q "failed to tokenize statement" "$REPO_ROOT/manual_runs/latest/web_demo/demo_data.js"
grep -q "failed to insert entry log: unauthorized student id 303" "$REPO_ROOT/manual_runs/latest/web_demo/demo_data.js"

printf '%s\n' "demo web tests passed"

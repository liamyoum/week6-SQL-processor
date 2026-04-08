#!/bin/sh

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
OUTPUT_ROOT="$REPO_ROOT/manual_runs/latest"

purpose_for_case() {
    case "$1" in
    01_happy_path)
        printf '%s\n' "students + entry logs full happy path"
        ;;
    02_select_student_by_id)
        printf '%s\n' "SELECT student by id returns one row"
        ;;
    03_select_missing_student)
        printf '%s\n' "missing student SELECT returns no rows"
        ;;
    04_entry_log_invalid_datetime)
        printf '%s\n' "invalid datetime is rejected"
        ;;
    05_entry_log_unauthorized)
        printf '%s\n' "unauthorized student cannot enter"
        ;;
    06_entry_log_missing_student)
        printf '%s\n' "missing student id blocks entry log insert"
        ;;
    07_stop_after_middle_error)
        printf '%s\n' "execution stops after a middle statement error"
        ;;
    *)
        printf '%s\n' "unknown case"
        ;;
    esac
}

first_line_or_empty() {
    file_path=$1

    if [ -s "$file_path" ]; then
        sed -n '1p' "$file_path"
    else
        printf '%s\n' "(empty)"
    fi
}

student_csv_status() {
    case_dir=$1

    if [ -f "$case_dir/data/student.csv" ]; then
        printf '%s\n' "present"
    else
        printf '%s\n' "absent"
    fi
}

entry_log_status() {
    case_dir=$1

    if [ -f "$case_dir/data/entry_log.bin" ]; then
        printf '%s bytes\n' "$(wc -c < "$case_dir/data/entry_log.bin" | tr -d ' ')"
    else
        printf '%s\n' "absent"
    fi
}

rm -rf "$OUTPUT_ROOT"
mkdir -p "$OUTPUT_ROOT"

for case_name in \
    01_happy_path \
    02_select_student_by_id \
    03_select_missing_student \
    04_entry_log_invalid_datetime \
    05_entry_log_unauthorized \
    06_entry_log_missing_student \
    07_stop_after_middle_error
do
    case_dir="$OUTPUT_ROOT/$case_name"

    mkdir -p "$case_dir"
    cp "$REPO_ROOT/manual_samples/$case_name.sql" "$case_dir/query.sql"

    (
        cd "$case_dir"
        if "$REPO_ROOT/sql_processor" query.sql > stdout.txt 2> stderr.txt; then
            exit_code=0
        else
            exit_code=$?
        fi
        printf '%s\n' "$exit_code" > exit_code.txt

        if [ ! -f data/student.csv ]; then
            printf '%s\n' "absent" > student_csv.absent.txt
        fi

        if [ -f data/entry_log.bin ]; then
            wc -c < data/entry_log.bin | tr -d ' ' > entry_log.bin.size.txt
            if command -v xxd >/dev/null 2>&1; then
                xxd -g 1 data/entry_log.bin > entry_log.bin.hex.txt
            else
                hexdump -C data/entry_log.bin > entry_log.bin.hex.txt
            fi
        else
            printf '%s\n' "absent" > entry_log.bin.absent.txt
        fi
    )
done

OVERVIEW_PATH="$OUTPUT_ROOT/DEMO_OVERVIEW.md"

cat > "$OVERVIEW_PATH" <<EOF
# Demo Overview

이 파일은 \`manual_samples/\` 아래 샘플 SQL 7개를 실제로 실행한 결과를 한 번에 보기 위한 요약판이다.

- 재생성 명령: \`make demo\`
- 샘플 SQL 원본 설명: [$REPO_ROOT/manual_samples/README.md]($REPO_ROOT/manual_samples/README.md)
- 전체 결과 루트: [$OUTPUT_ROOT]($OUTPUT_ROOT)

## Summary

| Case | Purpose | Exit | stdout gist | stderr gist | student.csv | entry_log.bin |
| --- | --- | --- | --- | --- | --- | --- |
EOF

for case_name in \
    01_happy_path \
    02_select_student_by_id \
    03_select_missing_student \
    04_entry_log_invalid_datetime \
    05_entry_log_unauthorized \
    06_entry_log_missing_student \
    07_stop_after_middle_error
do
    case_dir="$OUTPUT_ROOT/$case_name"
    purpose=$(purpose_for_case "$case_name")
    exit_code=$(cat "$case_dir/exit_code.txt")
    stdout_gist=$(first_line_or_empty "$case_dir/stdout.txt")
    stderr_gist=$(first_line_or_empty "$case_dir/stderr.txt")
    student_status=$(student_csv_status "$case_dir")
    entry_status=$(entry_log_status "$case_dir")

    printf '| %s | %s | %s | %s | %s | %s | %s |\n' \
        "$case_name" \
        "$purpose" \
        "$exit_code" \
        "$stdout_gist" \
        "$stderr_gist" \
        "$student_status" \
        "$entry_status" >> "$OVERVIEW_PATH"
done

cat >> "$OVERVIEW_PATH" <<EOF

## Quick Start

발표 때 가장 먼저 열 파일:

- [$OVERVIEW_PATH]($OVERVIEW_PATH)

그 다음 필요하면 각 케이스 폴더 안의 아래 파일만 보면 된다.

- \`query.sql\`: 입력 SQL
- \`stdout.txt\`: SELECT 결과
- \`stderr.txt\`: 에러 메시지
- \`data/student.csv\`: 학생 CSV 실제 저장 결과
- \`data/entry_log.bin\`: 실제 binary 파일
- \`entry_log.bin.hex.txt\`: binary를 사람이 읽기 쉬운 hex dump로 변환한 파일

## Details
EOF

for case_name in \
    01_happy_path \
    02_select_student_by_id \
    03_select_missing_student \
    04_entry_log_invalid_datetime \
    05_entry_log_unauthorized \
    06_entry_log_missing_student \
    07_stop_after_middle_error
do
    case_dir="$OUTPUT_ROOT/$case_name"
    purpose=$(purpose_for_case "$case_name")
    exit_code=$(cat "$case_dir/exit_code.txt")
    student_status=$(student_csv_status "$case_dir")
    entry_status=$(entry_log_status "$case_dir")

    {
        printf '### %s\n\n' "$case_name"
        printf '%s\n' "- purpose: $purpose"
        printf '%s\n' "- exit_code: $exit_code"
        printf '%s\n' "- student.csv: $student_status"
        printf '%s\n' "- entry_log.bin: $entry_status"
        printf '%s\n' "- files:"
        printf '  - [%s/query.sql](%s/query.sql)\n' "$case_dir" "$case_dir"
        printf '  - [%s/stdout.txt](%s/stdout.txt)\n' "$case_dir" "$case_dir"
        printf '  - [%s/stderr.txt](%s/stderr.txt)\n' "$case_dir" "$case_dir"
        if [ -f "$case_dir/data/student.csv" ]; then
            printf '  - [%s/data/student.csv](%s/data/student.csv)\n' "$case_dir" "$case_dir"
        fi
        if [ -f "$case_dir/data/entry_log.bin" ]; then
            printf '  - [%s/data/entry_log.bin](%s/data/entry_log.bin)\n' "$case_dir" "$case_dir"
            printf '  - [%s/entry_log.bin.hex.txt](%s/entry_log.bin.hex.txt)\n' "$case_dir" "$case_dir"
        fi
        printf '\n'
        printf '**stdout**\n\n'
        printf '```text\n'
        cat "$case_dir/stdout.txt"
        printf '```\n\n'
        printf '**stderr**\n\n'
        printf '```text\n'
        cat "$case_dir/stderr.txt"
        printf '```\n\n'
        if [ -f "$case_dir/data/student.csv" ]; then
            printf '**student.csv**\n\n'
            printf '```text\n'
            cat "$case_dir/data/student.csv"
            printf '```\n\n'
        fi
        if [ -f "$case_dir/entry_log.bin.hex.txt" ]; then
            printf '**entry_log.bin hex**\n\n'
            printf '```text\n'
            cat "$case_dir/entry_log.bin.hex.txt"
            printf '```\n\n'
        fi
    } >> "$OVERVIEW_PATH"
done

printf '%s\n' "$OVERVIEW_PATH"

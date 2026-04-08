# Manual SQL Samples

이 디렉터리는 `sql_processor`를 사람이 직접 실행해 보면서 결과를 확인할 수 있도록 만든 샘플 SQL 파일 모음이다.

중요:
- 프로그램은 **현재 작업 디렉터리 기준**으로 `data/student.csv`, `data/entry_log.bin` 을 만든다.
- 따라서 리포지토리 루트에서 바로 실행하지 말고, **빈 임시 디렉터리**에서 실행하는 편이 안전하다.
- 발표용 `make demo` 는 아래 9개 샘플을 순서대로 실행해서 웹 데모와 요약 파일을 만든다.

## 준비

```bash
cd /path/to/week6-SQL-processor
make
REPO_ROOT="$(pwd)"
```

각 샘플은 아래처럼 실행하면 된다.

```bash
WORK_DIR=/tmp/sql_processor_manual
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

"$REPO_ROOT/sql_processor" "$REPO_ROOT/manual_samples/01_happy_path.sql" > stdout.txt 2> stderr.txt
echo $?
```

실행 뒤에는 보통 아래 파일만 보면 된다.

```bash
cat stdout.txt
cat stderr.txt
cat data/student.csv
wc -c < data/entry_log.bin
```

## 샘플 목록

### 01. `01_happy_path.sql`
- 학생 등록, 학생 전체 조회, 입장 기록 등록, 입장 기록 조회까지 모두 성공하는 정상 케이스

### 02. `02_select_student_by_id.sql`
- `SELECT * FROM STUDENT_CSV WHERE id = 303;` 로 학생 한 줄만 조회하는 성공 케이스

### 03. `03_duplicate_student_id.sql`
- 같은 학생 id를 두 번 넣어서 `failed to insert student: duplicate id ...` 를 만드는 실패 케이스

### 04. `04_unsupported_sql.sql`
- 지원하지 않는 SQL 문법(`DELETE`)을 넣어서 `failed to parse statement` 를 만드는 실패 케이스

### 05. `05_missing_semicolon.sql`
- 문장 끝 세미콜론을 빼서 `failed to split statements: every statement must end with ';'` 를 만드는 실패 케이스

### 06. `06_unterminated_string.sql`
- 따옴표가 닫히지 않은 문자열을 넣어서 `failed to tokenize statement` 를 만드는 실패 케이스

### 07. `07_entry_log_unauthorized.sql`
- 권한 없는 학생(`authorization=F`)이 입장 기록을 남기려 할 때 실패하는 케이스

### 08. `08_entry_log_missing_student.sql`
- 학생 테이블에 없는 id로 입장 기록을 남기려 할 때 실패하는 케이스

### 09. `09_stop_after_middle_error.sql`
- 중간 문장에서 실패가 나면 뒤 문장이 더 실행되지 않는다는 것을 보여 주는 케이스

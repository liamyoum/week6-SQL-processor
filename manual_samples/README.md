# Manual SQL Samples

이 디렉터리는 `sql_processor`를 사람이 직접 실행해 보면서
결과를 확인할 수 있도록 만든 샘플 SQL 파일 모음이다.

중요:
- 프로그램은 **현재 작업 디렉터리 기준**으로 `data/student.csv`, `data/entry_log.bin` 을 만든다.
- 따라서 리포지토리 루트에서 바로 실행하지 말고, **빈 임시 디렉터리**에서 실행하는 편이 안전하다.

## 1. 준비

먼저 리포지토리 루트에서 빌드한다.

```bash
cd /path/to/week6-SQL-processor
make
REPO_ROOT="$(pwd)"
```

이후 각 샘플은 아래 순서로 실행한다.

```bash
WORK_DIR=/tmp/sql_processor_manual
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

"$REPO_ROOT/sql_processor" "$REPO_ROOT/manual_samples/01_happy_path.sql" > stdout.txt 2> stderr.txt
echo $?
```

실행 뒤에는 보통 아래 4가지를 확인하면 된다.

```bash
cat stdout.txt
cat stderr.txt
cat data/student.csv
wc -c < data/entry_log.bin
```

참고:
- 성공 케이스는 보통 exit code `0`
- 실패 케이스는 보통 exit code `1`
- `wc -c` 출력 앞쪽 공백은 정상이다. 중요한 값은 숫자다.

`entry_log.bin` 이 없는 경우는 아래처럼 확인한다.

```bash
test ! -f data/entry_log.bin && echo "entry_log.bin absent"
```

## 2. 샘플 파일 목록

### 01. `01_happy_path.sql`

목적:
- 학생 3명 INSERT
- 전체 학생 SELECT
- 권한 있는 학생의 입장 기록 2건 INSERT
- 입장 기록 SELECT

실행:

```bash
WORK_DIR=/tmp/sql_processor_manual_01
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"
"$REPO_ROOT/sql_processor" "$REPO_ROOT/manual_samples/01_happy_path.sql" > stdout.txt 2> stderr.txt
echo $?
```

기대 `stdout.txt`

```text
id,name,class,authorization
302,Kim,302,T
303,Lee,303,F
100,Coach,100,T
entered_at,id
2026-04-08 09:00:00,302
2026-04-08 18:30:00,302
```

기대 `stderr.txt`

```text
```

기대 `data/student.csv`

```text
id,name,class,authorization
302,Kim,302,T
303,Lee,303,F
100,Coach,100,T
```

기대 `entry_log.bin` 크기

```text
24
```

### 02. `02_select_student_by_id.sql`

목적:
- 학생 2명 INSERT
- `WHERE id = 303` 으로 단건 조회

실행:

```bash
WORK_DIR=/tmp/sql_processor_manual_02
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"
"$REPO_ROOT/sql_processor" "$REPO_ROOT/manual_samples/02_select_student_by_id.sql" > stdout.txt 2> stderr.txt
echo $?
```

기대 `stdout.txt`

```text
id,name,class,authorization
303,Lee,303,F
```

기대 `stderr.txt`

```text
```

기대 `data/student.csv`

```text
id,name,class,authorization
302,Kim,302,T
303,Lee,303,F
```

### 03. `03_select_missing_student.sql`

목적:
- 존재하지 않는 학생 id 조회 시 `no rows found` 확인

실행:

```bash
WORK_DIR=/tmp/sql_processor_manual_03
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"
"$REPO_ROOT/sql_processor" "$REPO_ROOT/manual_samples/03_select_missing_student.sql" > stdout.txt 2> stderr.txt
echo $?
```

기대 `stdout.txt`

```text
no rows found
```

기대 `stderr.txt`

```text
```

기대 `data/student.csv`

```text
id,name,class,authorization
302,Kim,302,T
```

### 04. `04_entry_log_invalid_datetime.sql`

목적:
- 잘못된 datetime 형식 거부 확인

실행:

```bash
WORK_DIR=/tmp/sql_processor_manual_04
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"
"$REPO_ROOT/sql_processor" "$REPO_ROOT/manual_samples/04_entry_log_invalid_datetime.sql" > stdout.txt 2> stderr.txt
echo $?
```

기대 `stdout.txt`

```text
```

기대 `stderr.txt`

```text
failed to insert entry log: invalid datetime
```

기대 사항:
- `data/student.csv` 는 생성되지 않을 수도 있다. 이 케이스에서는 학생 파일을 건드리지 않는다.
- `data/entry_log.bin` 은 생성되면 안 된다.

확인 명령:

```bash
test ! -f data/entry_log.bin && echo "entry_log.bin absent"
```

### 05. `05_entry_log_unauthorized.sql`

목적:
- 권한 없는 학생(`class = 303`)의 입장 기록 INSERT 실패 확인

실행:

```bash
WORK_DIR=/tmp/sql_processor_manual_05
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"
"$REPO_ROOT/sql_processor" "$REPO_ROOT/manual_samples/05_entry_log_unauthorized.sql" > stdout.txt 2> stderr.txt
echo $?
```

기대 `stdout.txt`

```text
```

기대 `stderr.txt`

```text
failed to insert entry log: unauthorized student id 303
```

기대 `data/student.csv`

```text
id,name,class,authorization
303,Lee,303,F
```

기대 사항:
- `entry_log.bin` 은 생성되면 안 된다.

### 06. `06_entry_log_missing_student.sql`

목적:
- 존재하지 않는 학생 id로 입장 기록 INSERT 시 실패 확인

실행:

```bash
WORK_DIR=/tmp/sql_processor_manual_06
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"
"$REPO_ROOT/sql_processor" "$REPO_ROOT/manual_samples/06_entry_log_missing_student.sql" > stdout.txt 2> stderr.txt
echo $?
```

기대 `stdout.txt`

```text
```

기대 `stderr.txt`

```text
failed to insert entry log: student id 999 not found
```

기대 `data/student.csv`

```text
id,name,class,authorization
```

기대 사항:
- `entry_log.bin` 은 생성되면 안 된다.

### 07. `07_stop_after_middle_error.sql`

목적:
- 중간 문장에서 에러가 나면 이후 문장이 실행되지 않는지 확인

실행:

```bash
WORK_DIR=/tmp/sql_processor_manual_07
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"
"$REPO_ROOT/sql_processor" "$REPO_ROOT/manual_samples/07_stop_after_middle_error.sql" > stdout.txt 2> stderr.txt
echo $?
```

기대 `stdout.txt`

```text
```

기대 `stderr.txt`

```text
failed to insert entry log: unauthorized student id 303
```

기대 `data/student.csv`

```text
id,name,class,authorization
302,Kim,302,T
303,Lee,303,F
```

여기서 중요한 확인 포인트:
- 뒤에 있던 `INSERT INTO STUDENT_CSV VALUES (100, 'Coach', 100);` 는 실행되면 안 된다.
- 따라서 `student.csv` 에 `Coach` row가 없어야 한다.
- 첫 번째 성공한 입장 기록 1건만 남으므로 `entry_log.bin` 크기는 `12` 여야 한다.

## 3. 빠른 체크 포인트

- `stderr.txt` 가 비어 있으면 보통 정상 경로다.
- `class == 302` 또는 `100` 이면 `authorization = T`
- `class == 303` 같은 경우는 `authorization = F`
- `entry_log.bin` 은 레코드 1건당 12바이트다.
- 에러가 발생하면 그 뒤 문장은 실행되지 않아야 한다.

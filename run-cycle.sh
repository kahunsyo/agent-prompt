#!/bin/bash

set -e

# デフォルト値
SAMPLE_NAME="all"
CYCLES=1
MODE="both"

# 色定義
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 使い方を表示
usage() {
  cat <<EOF
Usage: $0 [options]

Better Agent Prompt Cycleを実行するスクリプト

Options:
  -s, --sample <name>     Sample project name (default: all)
                          Use "all" to run all sample projects
  -c, --cycles <number>   Number of cycles to run (default: 1)
  -w, --working-only      Run Working AI only
  -e, --checking-only     Run Checking AI only
  -h, --help              Show this help message

Examples:
  # 全サンプルを1サイクル実行（デフォルト）
  $0

  # 特定のサンプルを3サイクル実行
  $0 --sample testing-ansible-host --cycles 3

  # Working AIのみ実行
  $0 --working-only

  # Checking AIのみ実行
  $0 --checking-only
EOF
  exit 0
}

# 引数解析
while [[ $# -gt 0 ]]; do
  case $1 in
    -s|--sample)
      SAMPLE_NAME="$2"
      shift 2
      ;;
    -c|--cycles)
      CYCLES="$2"
      shift 2
      ;;
    -w|--working-only)
      MODE="working"
      shift
      ;;
    -e|--checking-only)
      MODE="checking"
      shift
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo "Unknown option: $1"
      usage
      ;;
  esac
done

# スクリプトのディレクトリに移動
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# サンプルプロジェクトのリストを取得
if [ "$SAMPLE_NAME" = "all" ]; then
  # working-ai/配下の全ディレクトリを取得（AGENT.mdとENTRYPOINT.mdを除く）
  SAMPLE_LIST=($(find working-ai -mindepth 1 -maxdepth 1 -type d -exec basename {} \;))
  if [ ${#SAMPLE_LIST[@]} -eq 0 ]; then
    echo "Error: No sample projects found in working-ai/"
    exit 1
  fi
else
  # 単一サンプルの存在確認
  if [ ! -d "working-ai/$SAMPLE_NAME" ]; then
    echo "Error: Sample project 'working-ai/$SAMPLE_NAME' not found"
    exit 1
  fi
  SAMPLE_LIST=("$SAMPLE_NAME")
fi

# Working AIを実行
run_working_ai() {
  echo -e "${GREEN}========================================${NC}"
  echo -e "${GREEN}Running Working AI for: $SAMPLE_NAME${NC}"
  echo -e "${GREEN}========================================${NC}"

  cd "working-ai/$SAMPLE_NAME"

  # ENTRYPOINTの内容を読み込んで実行
  PROMPT=$(sed -n '/```txt/,/```/p' ../ENTRYPOINT.md | sed '1d;$d')

  echo "$PROMPT" | claude -p --permission-mode acceptEdits --verbose --output-format stream-json --max-turns 100 --dangerously-skip-permissions | yq --input-format json -P -C 'del(.message.usage, .uuid, .session_id, .message.id)'
  #echo "$PROMPT" | claude -p --permission-mode acceptEdits --verbose --output-format stream-json --max-turns 100 --add-dir .. | yq --input-format json -P -C 'del(.message.usage, .uuid, .session_id, .message.id)'

  cd "$SCRIPT_DIR"

  echo -e "${GREEN}Working AI completed${NC}\n"
}

# Checking AIを実行
run_checking_ai() {
  echo -e "${BLUE}========================================${NC}"
  echo -e "${BLUE}Running Checking AI for: $SAMPLE_NAME${NC}"
  echo -e "${BLUE}========================================${NC}"

  cd checking-ai

  # 環境変数を設定
  export SAMPLE_WORK=$SAMPLE_NAME

  # ENTRYPOINTの内容を読み込んで実行
  PROMPT=$(sed -n '/```txt/,/```/p' ENTRYPOINT.md | sed '1d;$d')

  echo "$PROMPT" | claude -p --permission-mode acceptEdits --verbose --output-format stream-json --max-turns 100 --dangerously-skip-permissions | yq --input-format json -P -C 'del(.message.usage, .uuid, .session_id, .message.id)'
  #echo "$PROMPT" | claude -p --permission-mode acceptEdits --verbose --output-format stream-json --max-turns 100 --add-dir .. | yq --input-format json -P -C 'del(.message.usage, .uuid, .session_id, .message.id)'

  cd "$SCRIPT_DIR"

  echo -e "${BLUE}Checking AI completed${NC}\n"
}

# Git commit function
commit_changes() {
  local cycle=$1
  local stage=$2  # "working-ai" or "checking-ai"
  local sample=$3

  # Check if there are changes to commit
  if ! git diff --quiet || ! git diff --cached --quiet || [ -n "$(git ls-files --others --exclude-standard)" ]; then
    echo -e "${YELLOW}Committing changes...${NC}"

    # Stage all changes
    git add .

    # Create commit message
    if [ "$stage" = "working-ai" ]; then
      COMMIT_MSG="wip: cycle $cycle working-ai for $sample"
    else
      COMMIT_MSG="cycle $cycle: completed for $sample"
    fi

    # Commit
    git commit -m "$COMMIT_MSG"
    echo -e "${GREEN}Changes committed: $COMMIT_MSG${NC}\n"
  else
    echo -e "${YELLOW}No changes to commit${NC}\n"
  fi
}

# メイン処理
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Better Agent Prompt Cycle${NC}"
echo -e "${YELLOW}========================================${NC}"
echo -e "Samples: ${YELLOW}${SAMPLE_LIST[@]}${NC}"
echo -e "Cycles: ${YELLOW}$CYCLES${NC}"
echo -e "Mode: ${YELLOW}$MODE${NC}"
echo -e "${YELLOW}========================================${NC}\n"

# 各サンプルに対してループ
for SAMPLE_NAME in "${SAMPLE_LIST[@]}"; do
  echo -e "${YELLOW}=======================================${NC}"
  echo -e "${YELLOW}Processing sample: $SAMPLE_NAME${NC}"
  echo -e "${YELLOW}=======================================${NC}\n"

  for i in $(seq 1 $CYCLES); do
    echo -e "${YELLOW}=== Cycle $i/$CYCLES for $SAMPLE_NAME ===${NC}\n"

    if [ "$MODE" = "both" ] || [ "$MODE" = "working" ]; then
      run_working_ai
      commit_changes "$i" "working-ai" "$SAMPLE_NAME"
    fi

    if [ "$MODE" = "both" ] || [ "$MODE" = "checking" ]; then
      run_checking_ai
      commit_changes "$i" "checking-ai" "$SAMPLE_NAME"
    fi

    echo -e "${YELLOW}=== Cycle $i/$CYCLES for $SAMPLE_NAME completed ===${NC}\n"
  done

  echo -e "${GREEN}All cycles for $SAMPLE_NAME completed!${NC}\n"
done

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}All samples and cycles completed!${NC}"
echo -e "${GREEN}========================================${NC}"

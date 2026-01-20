# agent-prompt

## 概要

このリポジトリは、AIエージェント向けの**普遍的なAGENT.mdプロンプト**を作成・改善するための実験的なフレームワークです。

Working AIとChecking AIの2つのAIエージェントが協力し、Better Agent Prompt Cycleを繰り返すことで、より汎用的で効果的なAGENT.mdを生成します。複数のサンプルプロジェクトでこのサイクルを回すことで、プロジェクト固有の要素を除外し、どのようなプロジェクトでも適用できる普遍的なAGENT.mdを抽出することが目標です。

## 使い方

```bash
# 1サイクル実行（Working AI → Checking AI）
./run-cycle.sh

# 3サイクル実行
./run-cycle.sh --cycles 3

# Working AIのみ実行
./run-cycle.sh --working-only

# Checking AIのみ実行
./run-cycle.sh --checking-only
```

## Architecture

```mermaid
---
title: Better Agent Prompt Cycle
---
flowchart TD



Start@{ shape: circle} --> a[Read AGENT.md]
subgraph Working AI
comment@{ shape: comment, label: "More Working AI,\nmore geneal AGENT.md"}
a --> b[Read BLUEPRINT.md]
b --> c[Generate Artifact]
end

subgraph Checking AI
c --> d[Read EVALUATE.md]
d --> f[Compare and evalueate Artifact & AGENT.md]
f --> g[Generate better AGENT.md and EVALUATE.md]

g --> a
end
```


# EVALUATE

Working AIとChecking AIがあり、これを読んでいるあなたはChecking AIです。

Working AIは`../working-ai/$SAMPLE_WORK/BLUEPRINT.md`および`../working-ai/$SAMPLE_WORK/AGENT.md`に基づいて`working-ai/$SAMPLE_WORK/artifact/*`を作成します。

Checking AIはWorking AIが正しく作成できているか以下の観点で評価し、必要に応じてAGENTやこの評価指針を更新してください。

## 評価の進め方

1. BLUEPRINTとAGENTに書かれたゴール・Deliverableを把握する。
2. Artifactの内容とREADMEの手順が一致しているかを確認する。
3. Ansibleの検証手順を実際に実行できるか(理論上)をチェックし、欠けているものがあれば指摘する。
4. 評価結果を反映したフィードバックをAGENTに記録し、このファイルの評価項目も最新化する。

## 評価項目

- BLUEPRINTの目標が要件を満たして達成されている
  - docker composeでUbuntu 24.04 + systemdコンテナが起動できる前提が整っている（privileged/cgroupマウント/tmpfsなど）
  - SSH/Ansible接続情報がREADME・inventory・compose設定で矛盾なく揃っている
- 検証用PlaybookとHealthcheckが整備されている
  - `playbooks/`に接続テスト、特権昇格確認、systemdサービスの管理までカバーするPlaybookがあり、READMEに実行手順が説明されている
  - systemdが安定稼働しているかを確認する方法（健康チェックや`systemctl is-system-running`など）が示されている
- ドキュメントの正確性と使いやすさ
  - READMEのコマンド、サービス名、ポート、ユーザー、パスワード、後片付け手順が実装と一致し、そのまま利用できる
  - テスト用途のためセキュリティを緩めている旨と注意事項が明記されている
  - イメージ削除などの片付けコマンドが実際のタグ/設定（例: docker compose の自動命名か `image:` で指定した名前）と一致している
- シンプルさと冗長性の排除
  - 目的達成に不要なパッケージ・設定が追加されていない
  - Playbookは冪等性を保ち、利用者が繰り返し試せる

次回以降の評価では、今回のフィードバックで追加・変更されたポイントが反映されているかも確認すること。

# Ansible テストホスト構築用コンテナ

このディレクトリには、Ansible の playbook をすぐに試すための Ubuntu 24.04 ベースのコンテナ環境を構成するファイルが含まれています。`docker compose` で起動すると systemd が PID 1 として稼働し、SSH 経由で Ansible から操作できます。

## 前提条件

- Docker および docker compose plugin (v2 以降)
- Linux または Docker Desktop が動作する環境
- systemd をコンテナ内で起動できるように root 権限（もしくは同等の権限）を保持していること

## セットアップ

1. 作業ディレクトリへ移動します。

   ```bash
   cd artifact
   ```

2. コンテナをビルドして起動します。

   ```bash
   docker compose up -d
   ```

3. systemd の状態を確認します。

   ```bash
   docker compose exec test-host systemctl is-system-running --wait
   ```

   `running` もしくは `degraded` が表示されれば systemd の起動は完了しています。初回起動直後は `starting` が表示される場合があります。

## Ansible での検証

1. 同ディレクトリにある `ansible.cfg` と `inventory.ini` が自動で読み込まれるため、追加設定は不要です。
2. 用意されている playbook `playbooks/ping.yml` を実行します。

   ```bash
   ansible-playbook playbooks/ping.yml
   ```

   この playbook では以下を検証します。
   - `ansible.builtin.ping` による接続確認
   - `sudo` を用いた特権昇格（root UID の確認）
   - systemd 管理下の `cron` サービスを停止 → 状態確認 → 再起動し、サービス制御が行えることを実証

3. 追加で systemd の状態やサービスのログを確認したい場合は、以下のように `docker compose exec` を利用します。

   ```bash
   docker compose exec test-host systemctl status cron
   ```

## 接続情報

| 項目 | 値 |
| --- | --- |
| ホスト | 127.0.0.1 |
| SSH ポート | 2222 |
| ユーザー | ansible |
| パスワード | ansible |
| sudo / become | パスワード不要 (NOPASSWD) |
| root パスワード | root |

> ⚠️ テスト用途のため、SSH 設定やパスワードは意図的に緩くしています。本番用途では利用しないでください。

## コンテナの仕組み

- ベースイメージは `ubuntu:24.04`
- `systemd`, `openssh-server`, `cron`, `python3` など Ansible が必要とする最小限のパッケージをインストール
- `/sys/fs/cgroup` をホストから bind マウントし、`/run` と `/tmp` は `tmpfs` で割り当てて systemd が動作可能な状態を確保
- `docker-compose.yml` のヘルスチェックでは systemd が `running` または `degraded` になるまで待機して状態を確認

## 片付け

コンテナとネットワーク、ボリュームを削除するには以下を実行します。

```bash
docker compose down --volumes
```

ビルドしたイメージも削除する場合は次を実行してください。

```bash
docker image rm ansible-test-host
```

## トラブルシューティング

- systemd が `failed` になる場合: ホスト側で cgroup v2 が有効か、`/sys/fs/cgroup` のバインドマウントが許可されているかを確認してください。
- SSH 接続エラー: `docker compose ps` でポートの割り当て状況を確認し、ホストのファイアウォール設定を見直してください。
- Ansible 実行時に Python が見つからないと表示される場合: `inventory.ini` で `ansible_python_interpreter=/usr/bin/python3` が設定されているかを確認してください。

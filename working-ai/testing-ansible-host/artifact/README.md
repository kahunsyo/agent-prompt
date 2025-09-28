# Ansible テストホスト構築用コンテナ

このディレクトリには、Ansible の playbook を手軽に試すための Ubuntu 24.04 ベースのコンテナ環境を用意するための設定ファイルが含まれています。docker compose で起動すると、systemd を利用できるテスト用ホストが立ち上がり、SSH (パスワード認証) を通じて Ansible から操作できます。

## 前提条件

- Docker および docker compose plugin (v2 以降)
- Linux もしくは Docker Desktop が動作する環境
- コンテナ内で systemd を動かすため root 権限または同等の権限

## セットアップ手順

1. このディレクトリに移動します。

   ```bash
   cd artifact
   ```

2. コンテナをビルドして起動します。

   ```bash
   docker compose up -d
   ```

   - コンテナ名: `ansible-test-host`
   - SSH ポート: `2222`
   - Ansible 用ユーザー: `ansible` / パスワード: `ansible`
   - root ユーザー パスワード: `root`

3. systemd が動作しているか確認します。

   ```bash
   docker compose exec test-host systemctl is-system-running
   ```

   `running` または `degraded` が表示されれば起動しています。初期起動直後は `starting` と表示される場合があります。

4. SSH でログインして動作確認ができます。

   ```bash
   ssh ansible@127.0.0.1 -p 2222
   # パスワード: ansible
   ```

## Ansible での利用方法

1. Ansible の設定ファイル (`ansible.cfg`) とインベントリ (`inventory.ini`) はこのディレクトリに用意済みです。
2. 接続確認 (ping) と特権昇格テストを行う playbook `playbooks/ping.yml` を実行します。

   ```bash
   ansible-playbook playbooks/ping.yml
   ```

   - `ansible.cfg` で `inventory.ini` が自動的に読み込まれ、ホストキー検証は無効化されています。
   - playbook 内で `ansible.builtin.ping` により接続テストを実施し、`sudo` での特権昇格が機能するか確認します。

## systemd を利用するためのポイント

- コンテナは `privileged: true`、`cgroup_ns: host` の設定で起動します。
- `/sys/fs/cgroup` をホストから読み取り専用でマウントし、`/run` と `/tmp` は `tmpfs` を割り当てています。
- `CMD ["/sbin/init"]` により PID 1 が systemd になります。

## 片付け

コンテナを停止・削除するには以下を実行します。

```bash
docker compose down --volumes
```

必要に応じてイメージも削除する場合は `docker image rm ansible-test-host` を実行してください。

## トラブルシューティング

- systemd が `running` にならない場合: ホスト側が cgroup v2 に対応しているか、Docker デーモンの設定を確認してください。
- SSH 接続時に拒否される場合: ファイアウォール設定と `docker compose ps` でポートが開いているか確認してください。

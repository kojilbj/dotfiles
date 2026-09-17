# dotfiles

シェル・Git・エディタ類の設定ファイルを管理するリポジトリ。

## 仕組み

このリポジトリ内のファイルが「実体」で、`$HOME` 以下には `install.sh` が
シンボリックリンクを張るだけ。設定を編集するときは `$HOME` 側のファイルを
直接触ってもリポジトリ側の実体が変わるので、そのまま `git commit` できる。

## 管理しているもの

| リポジトリ内 | リンク先 |
|---|---|
| `zshrc` | `~/.zshrc` |
| `zshenv` | `~/.zshenv` |
| `zprofile` | `~/.zprofile` |
| `p10k.zsh` | `~/.p10k.zsh`（Powerlevel10k） |
| `vimrc` | `~/.vimrc` |
| `yarnrc` | `~/.yarnrc` |
| `gitconfig` | `~/.gitconfig` |
| `gitignore` | `~/.gitignore` |
| `config/git/ignore` | `~/.config/git/ignore`（グローバルgitignore） |
| `config/nvim/` | `~/.config/nvim/`（LazyVim） |
| `config/wezterm/` | `~/.config/wezterm/` |
| `config/aerospace/` | `~/.config/aerospace/`（AeroSpace） |
| `config/borders/` | `~/.config/borders/`（JankyBorders、フォーカス枠線） |

秘密鍵・トークン・履歴ファイル・キャッシュの類は意図的に含めていない。

## セットアップ

```bash
git clone git@github.com:kojilbj/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

`install.sh` は冪等で、何度実行しても安全。`$HOME` に既存のファイルが
あった場合は削除せず `~/dotfiles_backup_<timestamp>/` へ退避してから
シンボリックリンクを張る。

## CI

`.github/workflows/ci.yml` で以下を自動チェック:

- `install.sh` の shellcheck
- `zshrc` / `zshenv` / `zprofile` の構文チェック
- クリーンな環境で `install.sh` を実行し、リンクが正しく張られるかのスモークテスト（冪等性も確認）

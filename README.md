# RemoteDesctop

iOS用のリモートデスクトップクライアントアプリケーション。シンクライアントを含む様々なリモートデスクトップ接続をサポートします。

## 機能

- リモートデスクトップ接続の設定と管理
- 接続先の設定を保存し、一覧表示
- 過去に接続したPCへの簡単な再接続
- 複数の接続プロトコルをサポート:
  - RDP (Remote Desktop Protocol)
  - VNC (Virtual Network Computing)
  - SSH (Secure Shell)
- 接続情報の安全な保存
- 直感的なユーザーインターフェース

## 技術仕様

- SwiftとSwiftUIを使用して開発
- SwiftData（iOS 17の新機能）を使用してローカルデータを永続化
- iOS 17以上をターゲット
- Swift Package Manager (SPM) による依存関係管理
- 接続ライブラリ:
  - RDP: シミュレーション実装（適切なSPM対応ライブラリがないため）
  - VNC: EasyVNC（SPM経由）
  - SSH: Citadel（NIOSSHベース、SPM経由）

## 使用方法

1. アプリを起動する
2. 「+」ボタンをタップして新しい接続を追加
3. 接続情報を入力:
   - 名前: 接続の識別名
   - ホスト名/IPアドレス: 接続先のサーバー
   - ポート: 接続プロトコルのポート（デフォルト値が自動入力されます）
   - ユーザー名: 認証用のユーザー名
   - パスワード: 認証用のパスワード
   - 接続タイプ: RDP、VNC、SSHから選択
4. 保存後、接続リストから選択して接続を開始
5. 接続画面では以下の操作が可能:
   - キーボード入力の送信
   - マウス操作
   - 接続の切断

## 開発情報

- Xcode 15以上が必要
- iOS 17以上をターゲット
- 使用フレームワーク:
  - SwiftUI: ユーザーインターフェース
  - SwiftData: データ永続化
  - Combine: 非同期処理
  - CocoaAsyncSocket: ネットワーク通信（SPM経由）
  - Citadel: SSH接続（SPM経由）
  - EasyVNC: VNC接続（SPM経由）
  - NIO: 非同期ネットワーク処理（SPM経由）

### プロジェクト構造

- `RemoteConnection.swift`: 接続情報のデータモデル
- `ContentView.swift`: メインビュー（接続リスト）
- `AddConnectionView.swift`: 新しい接続を追加するためのフォーム
- `ConnectionDetailView.swift`: 接続の詳細と接続ボタン
- `EditConnectionView.swift`: 既存の接続を編集するためのフォーム
- `RemoteDesktopView.swift`: リモートデスクトップ表示画面
- `RemoteConnectionService.swift`: 接続処理を行うサービスクラス
- クライアント実装:
  - `RDPClient.swift`: RDP接続のインターフェース
  - `RDPClientImplementation.swift`: RDP接続の実装
  - `VNCClient.swift`: VNC接続のインターフェース
  - `VNCClientImplementation.swift`: VNC接続の実装
  - `SSHClient.swift`: SSH接続のインターフェース
  - `SSHClientImplementation.swift`: SSH接続の実装

### ビルド手順

1. リポジトリをクローンする
2. Xcodeでプロジェクトを開く（.xcodeproj）
3. Swift Package Managerが自動的に依存関係をダウンロード
4. ビルドして実行する

## 今後の開発予定

- 接続プロファイルのグループ化
- 接続履歴の詳細表示
- パスワードの安全な保存（キーチェーン統合）
- 追加の認証方法（公開鍵認証など）
- 画面キャプチャ機能
- ファイル転送機能

## ライセンス

このプロジェクトは独自ライセンスの下で提供されています。詳細については開発者にお問い合わせください。

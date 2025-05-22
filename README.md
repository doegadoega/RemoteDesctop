# Remote Desktop Client

リモートデスクトップに接続するためのmacOSアプリケーション。RDP、VNC、SSHプロトコルをサポートしています。

## 機能

- リモートデスクトップ接続の管理（追加、編集、削除）
- 複数のプロトコルをサポート：
  - RDP (Remote Desktop Protocol)
  - VNC (Virtual Network Computing)
  - SSH (Secure Shell)
- 接続情報の保存と管理
- リモート画面の表示とインタラクション

## 現在の実装状況

現在のバージョンでは、各プロトコルの基本的なシミュレーション実装が含まれています。実際のリモート接続を行うには、以下のライブラリを使用した実装が必要です。

### SSH接続

SSH接続には[Citadel](https://github.com/orlandos-nl/Citadel.git)ライブラリを使用しています。`SSHClientImplementation.swift`ファイルに実装されていますが、実際に使用するには以下の手順が必要です：

1. Xcodeプロジェクトに正しくCitadelライブラリが統合されていることを確認
2. `import Citadel`と`import NIO`が正しく解決されることを確認
3. 必要に応じて実装を調整

### VNC接続

VNC接続には[CocoaAsyncSocket](https://github.com/robbiehanson/CocoaAsyncSocket.git)と[EasyVNC](https://github.com/iOmega8561/EasyVNC.git)ライブラリを使用する予定です。現在は基本的なシミュレーション実装のみが含まれています。実際のVNC接続を実装するには：

1. Xcodeプロジェクトに正しくEasyVNCライブラリが統合されていることを確認
2. `VNCClientImplementation.swift`ファイルを更新して、EasyVNCを使用した実際のVNC接続を実装

### RDP接続

RDP接続の実装には、適切なRDPクライアントライブラリが必要です。現在はシミュレーション実装のみが含まれています。実際のRDP接続を実装するには：

1. 適切なRDPクライアントライブラリを選択（例：FreeRDP）
2. Package.swiftファイルに依存関係を追加
3. `RDPClientImplementation.swift`ファイルを更新して、選択したライブラリを使用した実際のRDP接続を実装

## 推奨されるRDPライブラリ

RDP接続の実装には、以下のいずれかのライブラリを使用することをお勧めします：

1. [FreeRDP](https://github.com/FreeRDP/FreeRDP) - オープンソースのRDPクライアントライブラリ
   - Swift用のラッパーを作成するか、Objective-Cブリッジを使用して統合する必要があります
2. [SwiftRDP](https://github.com/Devolutions/SwiftRDP) - SwiftでのRDP実装（利用可能な場合）

## 依存関係の設定

Package.swiftファイルには、以下の依存関係が定義されています：

```swift
dependencies: [
    // SSH接続用ライブラリ - NIOSSHベースのCitadelを使用
    .package(url: "https://github.com/orlandos-nl/Citadel.git", from: "0.10.0"),
    
    // VNC接続用ライブラリ
    .package(url: "https://github.com/robbiehanson/CocoaAsyncSocket.git", from: "7.6.5"),
    
    // VNCクライアント実装
    .package(url: "https://github.com/iOmega8561/EasyVNC.git", branch: "main"),
],
```

RDPライブラリを追加する場合は、このファイルを更新する必要があります。

## 今後の改善点

1. 実際のRDP接続の実装
2. 実際のVNC接続の実装
3. SSHクライアントの機能強化
4. セキュリティの強化（パスワードの安全な保存など）
5. ユーザーインターフェースの改善
6. 接続プロファイルのインポート/エクスポート機能
7. 接続履歴の詳細な記録

## ライセンス

このプロジェクトは独自のライセンスの下で提供されています。詳細については、プロジェクトの所有者にお問い合わせください。

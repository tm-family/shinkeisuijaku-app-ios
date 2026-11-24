# LEARNINGS — shinkeisuijaku-app-ios の知見

このリポジトリだけで通じる知見を溜める（全リポジトリ共通の知見は `~/.agents/LEARNINGS.md`）。

- 1 項目 = 1 つの箇条書き。見出しの下に追記し、日付（YYYY-MM-DD）を添える
- コードや git の履歴を読めば分かることは書かない。PC 固有の値（ローカルパス・Simulator の UDID）と秘密情報は書かない
- 古くなった項目は消すか直す

## ビルド・テスト

## SwiftUI・デザイン

## StoreKit・保存

- Xcode 26.6 / iOS 26.5 の Simulator で、Unit テスト（Swift Testing・アプリがホスト）から `SKTestSession(contentsOf:)` と `SKTestSession(configurationFileNamed:)` のどちらで `Configs/Shinkeisuijaku.storekit` を開いても、`storefront` が空のまま `Product.products(for:)` が 0 件を返した（ファイルは読めている。原因は特定できていない）。StoreKit の判定は `PassStoreBackend` の擬似の実装で Unit テストし、StoreKit そのものは Xcode の Run（スキームの StoreKit Configuration）と実機で確かめる（2026-10-28）
- `SKTestSession` は、UI テスト（xcodebuild・Xcode の両方）からも、アプリがホストの Unit テスト（xcodebuild）からも、取引の操作（`clearTransactions()`・`refundTransaction`・`approveAskToBuyTransaction` など）が `SKInternalErrorDomain Code=3` で失敗する（UI テストでは、Xcode のテストのサーバーのポートを取れない旨がログに出た）。`allTransactions()` は投げずに 0 件を返すので、効いていないことに気付きにくい。この回の Unit テストでは `Product.products(for:)` で ¥100 が読めた（前に Xcode の Run が置いた設定が Simulator に残っていた。下の項目）（Xcode 26.6 / iOS 26.5、2026-11-24）
- 本物の StoreKit（`StoreKitPassBackend`）で購入・返金・承認と購入のリクエストまで確かめるときの流れ（2026-11-24、#33・#47）
  - Xcode（GUI）でスキームを Run し、`xcodebuild test-without-building -only-testing:` で一時的な UI テストを流す。UI テストは起動引数を付けずに `XCUIApplication().activate()` で、動いているアプリに乗る
  - test-without-building は、Xcode のデバッガの下で動いているアプリを終了させない
  - 返金と承認は Debug → StoreKit → Manage Transactions で人が押す。人の操作を待つあいだは UI テストを動かさず、操作の前後で段ごとのテストを 1 つずつ流す（UI テストで数時間待った回は、Xcode が応答しなくなった）
  - Ask to Buy は、`.storekit` の `settings` に `"_askToBuyEnabled" : true` を足して Run し直すと効く
  - テストの環境の確認（購入のシートの「購入」・Ask to Buy の「Ask」・復元のサインインを模したアラートの「OK」）は、UI テストからアプリの `app.buttons["…"]` で押せる
- Xcode で Run すると、スキームの StoreKit Configuration が Simulator の `group.com.apple.storekit` の `Documents/Persistence/Octane/<Bundle ID>/Configuration.storekit` に置かれ、Xcode を終了してもアプリはその設定の StoreKit のテストの環境を使い続ける。これが無いと本物の Sandbox を使い、App Store Connect に登録済みのパスが US の店頭の値段（$0.49）で出る（2026-11-24）
- Manage Transactions は、Simulator が Shutdown だと何も出ない。UI テストの後に xcodebuild が Simulator の診断の収集で 600 秒待ってタイムアウトし、そのあと Simulator が Shutdown になっていたことがある。Simulator を起動して Run し直すと、取引は残ったまま出る（2026-11-24）
- Simulator の StoreKit のテストの取引は、`group.com.apple.storekit` の `Library/Caches/storeUser.db`（SQLite）の `iap_receipts_v2` に写しがあり、`revocation_date` で返金を見分けられる。`-wal`・`-shm` ごと複写して読めば、人の返金・承認を UI テストなしで待てる。取引は JWS で署名されているので、書き換えて返金の代わりにはできない（2026-11-24）

## レビュー

- 2026-11-23 の時点で、このリポジトリの PR には CodeRabbit のレビューが 1 件も付いていない（マージ済みの直近 40 件で、コメントもレビューも無い。`.coderabbit.yaml` はあるが、アプリが動いていない）。CodeRabbit のレビューを待たずに、CI とセルフレビューで進める。動くようになったら、この項目を消す（2026-11-23）

## App Store の掲載

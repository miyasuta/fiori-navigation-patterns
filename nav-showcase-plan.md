# Fiori Elements Navigation Showcase - 設計計画

## 概要

List Reportからのアウトバウンドナビゲーションパターンを網羅するショーケースアプリ。  
CAP Node.js + SAP Fiori elements for OData V4。

---

## アプリ構成

```
fiori-nav-showcase/
├── app/
│   ├── nav-source/      ← App1: ナビゲーション元（メインアプリ）
│   └── nav-target/      ← App2: ナビゲーション先（コンテキスト確認用）
├── db/
│   └── schema.cds
└── srv/
    └── service.cds
```

**App1（nav-source）**：List Report + Object Page（entitySet: Orders）  
**App2（nav-target）**：List Report（entitySet: NavTargets）。受け取ったコンテキストがフィルターバーに反映されることを確認する用途。

---

## データモデル

### Orders（メインエンティティ）

| フィールド | 型 | 用途 |
|---|---|---|
| orderId | String(10) key | 主キー、Semantic Linkのテスト |
| description | String(100) | 通常フィールド |
| amount | Decimal(10,2) | 通常フィールド |
| status | String(20) | 通常フィールド |
| region | String(10) | Ordersのregion（Suppliersと同名 ← contextの上書きテスト用） |
| supplierId | String(10) | Suppliersへの外部キー |
| isNavEnabled | Boolean | NavigationAvailableのテスト用フラグ |
| externalUrl | String(200) | URLナビゲーション用 |

Association: `_Supplier` → Suppliers（supplierId経由）

### Suppliers（ナビゲーションエンティティ）

| フィールド | 型 | 用途 |
|---|---|---|
| supplierId | String(10) key | 主キー |
| supplierName | String(100) | 表示用 |
| region | String(10) | Ordersのregionと同名（nav entityフィールドのテスト用） |
| category | String(50) | nav entityフィールドのテスト用 |

### NavTargets（App2用）

| フィールド | 型 | 用途 |
|---|---|---|
| id | UUID key | 主キー |
| note | String(200) | 補足情報 |

---

## 実装するナビゲーションパターン

### グループA：ナビゲーションのトリガー方法（How to trigger）

List Reportのテーブル上でのナビゲーション起点の違いを示す。

| # | パターン | 表示形態 | 主なアノテーション |
|---|---|---|---|
| A-1 | **Semantic Link** | テーブル列がリンク | `@Common.SemanticObject` on property |
| A-2 | **IBN Button**（常に有効） | ツールバーボタン | `DataFieldForIntentBasedNavigation`, `RequiresContext: false` |
| A-3 | **IBN Action**（選択必須） | ツールバーボタン（行選択まで非活性） | `DataFieldForIntentBasedNavigation`, `RequiresContext: true` |
| A-4 | **Inline IBN** | 行内ボタン | `DataFieldForIntentBasedNavigation`, `Inline: true` |
| A-5 | **URL Link** | テーブル列がURLリンク | `DataFieldWithUrl` |
| A-6 | **行クリックナビゲーションの外部アプリへの置き換え** | 行クリック（シェブロン）で通常のObject Pageの代わりに外部アプリへ遷移 | manifest.json `navigation.detail.outbound` |

### グループB：ナビゲーションコンテキストの制御（What gets passed）

何がコンテキストとして遷移先に渡されるかの違いを示す。

| # | パターン | 確認ポイント | 主なアノテーション |
|---|---|---|---|
| B-1 | **SemanticObjectMapping（別名）** | ローカルの`supplierId`が遷移先では`vendor`という名前で渡される | `LocalProperty: supplierId`, `SemanticObjectProperty: 'vendor'` |
| B-2 | **nav entityフィールド（mappingなし）** | `_Supplier/region`はコンテキストに含まれない | mapping未定義 |
| B-3 | **nav entityフィールド（mappingあり）** | `_Supplier/category`はmapping定義によりコンテキストに含まれる | `LocalProperty: _Supplier/category`, `SemanticObjectProperty: 'supplierCategory'` |
| B-4 | **NavigationAvailable** | `isNavEnabled=false`の行ではボタンが非表示になる | `NavigationAvailable: isNavEnabled` |

> **パターンの絞り込み理由**
> - SemanticObjectMapping「同名」パターン（LocalProperty = SemanticObjectProperty）はB-2/B-3で暗黙的に示される
> - 親→子コンテキスト継承はObject PageのSubobject Page起点の話なので今回はスコープ外
> - センシティブデータ除外は高度なユースケースのため割愛

---

## SemanticObject / Action の設計

| SemanticObject | Action | 遷移先 |
|---|---|---|
| `NavTarget` | `display` | App2（nav-target）List Report |
| `NavTarget` | `manage` | App2（nav-target）List Report（別ビューとして使用） |

App2のフィルターバーに`orderId`・`supplierId`・`vendor`・`supplierCategory`を配置し、受け取ったコンテキストが反映されることを視覚的に確認できるようにする。

---

## サンプルデータ

### Suppliers（3件）

| supplierId | supplierName | region | category |
|---|---|---|---|
| S001 | Alpha Corp | JP | Electronics |
| S002 | Beta Ltd | DE | Mechanical |
| S003 | Gamma Inc | US | Software |

### Orders（5件）

| orderId | description | amount | status | region | supplierId | isNavEnabled | externalUrl |
|---|---|---|---|---|---|---|---|
| ORD001 | First Order | 10,000 | Open | JP | S001 | true | https://www.sap.com |
| ORD002 | Second Order | 25,000 | InProgress | DE | S002 | false | https://cap.cloud.sap |
| ORD003 | Third Order | 5,000 | Closed | US | S003 | true | https://ui5.sap.com |
| ORD004 | Fourth Order | 8,000 | Open | JP | S001 | true | https://community.sap.com |
| ORD005 | Fifth Order | 3,000 | Closed | DE | S002 | false | https://developers.sap.com |

> ORD002・ORD005は `isNavEnabled: false` → B-4パターンの確認用

---

## ファイル構成（作成対象）

```
db/
  schema.cds               ← Orders, Suppliers, NavTargets の定義

srv/
  service.cds              ← NavigationSourceService, NavigationTargetService
  service.js               ← サンプルデータの投入（init）

app/nav-source/
  annotations.cds          ← UIアノテーション全て（A-1〜A-5, B-1〜B-4）
  webapp/manifest.json     ← crossNavigation.outbounds, FLP sandbox設定

app/nav-target/
  annotations.cds          ← フィルターバー・テーブルの定義
  webapp/manifest.json     ← crossNavigation.inbounds（NavTarget-display, NavTarget-manage）
```

---

## Claude Codeへの参考ドキュメント

実装時に以下のドキュメントを参照してください。  
mcp-sap-docsで取得可能なものは `search` / `fetch` で確認することを推奨します。

### アノテーション（コア）

| 目的 | ドキュメント | URL |
|---|---|---|
| アウトバウンドナビゲーション全般（メイン） | Navigation from an App (Outbound Navigation) | https://ui5.sap.com/#/topic/d782acf8bfd74107ad6a04f0361c5f62 |
| `DataFieldForIntentBasedNavigation` / `SemanticObjectMapping` のCAP CDS記法 | Navigation from an App (Outbound Navigation) ※OData V4版 | https://help.sap.com/docs/SAPUI5/b2f662dd9d7a4ec680056733050b4d34/c35fa60228f44317a68afe661e945754.html |
| `DataFieldWithUrl` | Using a URL（上記メインドキュメント内） | https://ui5.sap.com/#/topic/d782acf8bfd74107ad6a04f0361c5f62 |
| `NavigationAvailable` / ボタン表示制御 | Display or Hide Buttons（上記メインドキュメント内） | https://ui5.sap.com/#/topic/d782acf8bfd74107ad6a04f0361c5f62 |
| `Common.SemanticObject` / `SemanticObjectMapping` アノテーション仕様 | OData Vocabularies (Common) | https://sap.github.io/odata-vocabularies/vocabularies/Common.html |

### manifest.json 設定

| 目的 | ドキュメント | URL |
|---|---|---|
| `crossNavigation.outbounds` の書き方 | Changing Navigation to Object Page | https://help.sap.com/docs/SAPUI5/b2f662dd9d7a4ec680056733050b4d34/8bd546e27a5f41cea6e251ba04534d70.html |
| **行クリックナビゲーションの外部アプリ置き換え（A-6）** | Changing Navigation to Object Page | https://ui5.sap.com/#/topic/8bd546e27a5f41cea6e251ba04534d70 |
| `crossNavigation.inbounds` の書き方（遷移先アプリ） | Navigation to an App (Inbound Navigation) | https://help.sap.com/docs/SAPUI5/b2f662dd9d7a4ec680056733050b4d34/c337d8bde8c544598969c8e4edaab262.html |
| FLP Sandboxの設定方法 | Configuring External Navigation (Learning Journey) | https://learning.sap.com/learning-journeys/developing-an-sap-fiori-elements-app-based-on-a-cap-odata-v4-service/configuring-external-navigation_dd4d7f6f-7857-4604-b993-70012c702c3f |

### CAP Node.js

| 目的 | ドキュメント | URL |
|---|---|---|
| CDS アノテーション全般 | CAP CDS Annotations | https://cap.cloud.sap/docs/cds/annotations |
| サービス定義・データ初期化 | CAP Node.js - Getting Started | https://cap.cloud.sap/docs/get-started/ |
| CAP + Fiori Elements 連携 | Fiori Elements Integration | https://cap.cloud.sap/docs/guides/fiori/ |

### 参考実装（リポジトリ）

| 目的 | リポジトリ |
|---|---|
| CAP版 Fiori Elements の各種アノテーションサンプル | https://github.com/SAP-samples/fiori-elements-feature-showcase |
| CAP + Fiori Elements の基本的なアプリ構成 | https://github.com/SAP-samples/cap-sflight |

### mcp-sap-docs での検索キーワード例

実装中に不明点があれば、以下のキーワードで `search` を呼び出してください。

```
# アノテーション記法
"DataFieldForIntentBasedNavigation CAP CDS annotation"
"Common.SemanticObjectMapping LocalProperty SemanticObjectProperty"
"NavigationAvailable DataFieldForIntentBasedNavigation"

# manifest設定
"crossNavigation outbounds manifest.json Fiori Elements"
"crossNavigation inbounds semanticObject action"

# コンテキスト制御
"navigation entity set SemanticObjectMapping context"
"outbound navigation context what gets passed"
```

---

## 各パターンの確認手順（概要）

1. `cds watch` 起動後、`sandbox/index.html` でFLPをシミュレート
2. App1（nav-source）のList Reportを開く
3. 各パターンのトリガーを操作し、App2（nav-target）に遷移
4. App2のフィルターバーに渡ってきたコンテキストが正しく反映されていることを確認

### 各パターンで確認すること

| # | 確認内容 |
|---|---|
| A-1 | orderId列がリンク表示になり、クリックでApp2に遷移する |
| A-2 | 行選択なしでもボタンが有効、クリックでApp2に遷移する |
| A-3 | 行選択前はボタンが非活性、選択後に活性化してApp2に遷移する |
| A-4 | 各行の右端にボタンが表示され、その行のコンテキストでApp2に遷移する |
| A-5 | 行クリックナビゲーションの外部アプリへの置き換えではなく、列がURLリンクになり外部サイトが開く |
| A-6 | 行クリック（シェブロン）でObject Pageではなく外部アプリ（nav-target）に遷移する |

> **A-6 実装メモ**  
> アノテーションではなく **manifest.json のみ** で設定します。  
> `crossNavigation.outbounds` に遷移先を登録し、List Reportの `navigation` 設定で `detail.outbound` に紐付けるだけでObject Pageへの内部遷移を外部ナビゲーションに置き換えられます。  
> `detail`（行クリック）の代わりに `display` を使う方法もあります。
>
> ```json
> // manifest.json (nav-source)
> "RootEntityListReport": {
>   "options": {
>     "settings": {
>       "navigation": {
>         "Orders": {
>           "detail": {
>             "outbound": "NavTargetDisplay"  // crossNavigation.outboundsのキーを参照
>           }
>         }
>       }
>     }
>   }
> }
> ```
| B-1 | App2のフィルターバーで`vendor`パラメータに`supplierId`の値が入っている |
| B-2 | App2のフィルターバーに`_Supplier/region`の値が渡されていない |
| B-3 | App2のフィルターバーに`supplierCategory`として`_Supplier/category`の値が渡されている |
| B-4 | `isNavEnabled=false`のORD002・ORD005行のボタンが非表示になっている |

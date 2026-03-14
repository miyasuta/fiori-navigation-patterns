# Group A Navigation Showcase — Implementation Plan

## データモデル設計

### 変更点（nav-showcase-plan.md からの差分）

**NavTargets を拡張**：inbound navigation パラメータがフィルターバーへ自動反映されるには、パラメータ名と entity フィールド名が完全一致する必要がある。Group B も見据えてフィールドを追加する。

| フィールド | 型 | 用途 |
|---|---|---|
| id | UUID key | 主キー |
| title | String(200) | 説明ラベル |
| orderId | String(10) | A-1/A-3/A-4 受信確認 |
| supplierId | String(10) | 直接コンテキスト受信 |
| region | String(10) | region コンテキスト受信 |
| vendor | String(10) | B-1 mapping 検証用（supplierId → vendor） |
| supplierCategory | String(50) | B-3 mapping 検証用（_Supplier/category → supplierCategory） |

Orders・Suppliers は nav-showcase-plan.md の通り（変更なし）。

### A-6 の注意点

`navigation.Orders.detail.outbound` を設定すると**行クリックで Object Page へ遷移しなくなる**。Object Page は `yo @sap/fiori` で生成されるが、A-6 は「その行クリックを外部ナビに置き換えるパターン」を示す。

---

## ファイル構成と実装内容

### CAP バックエンド

| ファイル | 内容 |
|---|---|
| `db/schema.cds` | Orders, Suppliers, NavTargets 定義 |
| `srv/service.cds` | NavigationSourceService（Orders, Suppliers expose）、NavigationTargetService（NavTargets expose） |
| `db/data/my.bookshop-Orders.csv` | Orders サンプル 5 件 |
| `db/data/my.bookshop-Suppliers.csv` | Suppliers サンプル 3 件 |
| `db/data/my.bookshop-NavTargets.csv` | NavTargets サンプル 5 件 |
| `test/nav-service.test.js` | OData protocol-level tests（TDD: 実装前に作成） |

### app/nav-source

`yo @sap/fiori` で生成（List Report Object Page / NavigationSourceService / Orders）。

| ファイル | 内容 |
|---|---|
| `annotations.cds` | A-1: `@Common.SemanticObject: 'NavTarget'` on orderId<br>A-2: DataFieldForIntentBasedNavigation RequiresContext:false（ツールバーボタン）<br>A-3: DataFieldForIntentBasedNavigation RequiresContext:true（選択必須ボタン）<br>A-4: DataFieldForIntentBasedNavigation Inline:true（行内ボタン）<br>A-5: DataFieldWithUrl（externalUrl フィールド使用、`_blank` で外部サイト） |
| `webapp/manifest.json` | crossNavigation.outbounds: `NavTargetDisplay`（SemanticObject: NavTarget / action: display）<br>A-6: `settings.navigation.Orders.detail.outbound: "NavTargetDisplay"` |

### app/nav-target

`yo @sap/fiori` で生成（List Report / NavigationTargetService / NavTargets）。

| ファイル | 内容 |
|---|---|
| `annotations.cds` | SelectionFields: orderId, supplierId, region, vendor, supplierCategory<br>LineItem: title, orderId, supplierId, region |
| `webapp/manifest.json` | crossNavigation.inbounds: `NavTarget-display`・`NavTarget-manage` |

### FLP Sandbox

| ファイル | 内容 |
|---|---|
| `package.json` | `cds-launchpad-plugin` 追加、`sapux` 配列に `"app/nav-source"`, `"app/nav-target"` を列挙 |

---

## Semantic Object / Action 設計

| SemanticObject | Action | 遷移先 |
|---|---|---|
| `NavTarget` | `display` | nav-target List Report |
| `NavTarget` | `manage` | nav-target List Report（将来の別ビュー用） |

---

## 実装順序

1. `git checkout -b feature/group-a-navigation`
2. `cds init` でプロジェクト生成
3. `test/nav-service.test.js` 作成（TDD: Red フェーズ）
4. `db/schema.cds` + `srv/service.cds` 実装（Green フェーズ）
5. `db/data/*.csv` サンプルデータ追加
6. `yo @sap/fiori` → nav-source（List Report Object Page）
7. `yo @sap/fiori` → nav-target（List Report）
8. `app/nav-source/annotations.cds` 作成（A-1〜A-5）
9. `app/nav-source/webapp/manifest.json` 更新（A-6・outbounds）
10. `app/nav-target/annotations.cds` 作成（SelectionFields）
11. `app/nav-target/webapp/manifest.json` 更新（inbounds）
12. `cds-launchpad-plugin` インストール + `package.json` 設定

**Verification**: `npm install && cds watch` 起動後、`http://localhost:4004/$launchpad` で FLP サンドボックスを開き、A-1〜A-6 の各パターンを手動確認。

---

## 各パターンで確認すること（Group A）

| # | 確認内容 |
|---|---|
| A-1 | orderId 列がリンク表示になり、クリックで nav-target に遷移する |
| A-2 | 行選択なしでもボタンが有効、クリックで nav-target に遷移する |
| A-3 | 行選択前はボタンが非活性、選択後に活性化して nav-target に遷移する |
| A-4 | 各行の右端にボタンが表示され、その行のコンテキストで nav-target に遷移する |
| A-5 | 列が URL リンクになり、クリックで外部サイトが別タブで開く |
| A-6 | 行クリック（シェブロン）で Object Page ではなく nav-target に遷移する |

---

## Group B 申し送り（次セッション向け）

### 現状

Group A は完全実装済み・`main` にマージ済み。次セッションでは Group B（ナビゲーション時に渡されるコンテキストの制御）を実装する。

### Group B で検証するパターン

| # | パターン名 | 検証内容 |
|---|---|---|
| B-1 | SemanticObjectMapping | ソース側フィールド名とターゲット側パラメータ名が異なる場合のマッピング |
| B-2 | nav エンティティフィールド（マッピングなし） | アソシエーションのフィールドはデフォルトで渡されない |
| B-3 | nav エンティティフィールド（マッピングあり） | アソシエーションフィールドを明示マッピングすれば渡せる |
| B-4 | NavigationAvailable | 行の値に応じてナビゲーションボタンの表示/非表示を制御する |

### データモデル — 変更不要

Group B 用のフィールドはすでに実装済み。追加実装は不要。

| フィールド | エンティティ | Group B での用途 |
|---|---|---|
| `vendor` | NavTargets | B-1: supplierId（ソース）→ vendor（ターゲット）マッピング受信確認 |
| `supplierCategory` | NavTargets | B-3: `_Supplier/category`（ソース）→ supplierCategory（ターゲット）マッピング受信確認 |
| `_Supplier` | Orders | B-2/B-3: アソシエーションフィールド（`_Supplier/region` など）の挙動検証用 |
| `isNavEnabled` | Orders | B-4: ORD002/ORD005 が `false`（これらの行でボタンを非表示にする） |

### 実装が必要なもの（app/nav-source/annotations.cds）

#### B-1: SemanticObjectMapping

ソース側の `supplierId` をターゲット側の `vendor` パラメータとして渡す。

```cds
annotate service.Orders with {
    supplierId @Common.SemanticObjectMapping: [{
        LocalProperty: supplierId,
        SemanticObjectProperty: 'vendor'
    }];
};
```

`vendor` は nav-target の SelectionFields に含まれているため、遷移後にフィルターバーへ自動反映される。

#### B-2: アソシエーションフィールド（マッピングなし）

デフォルトでは `_Supplier/region` などのアソシエーション経由フィールドはコンテキストに含まれない。確認のために追加実装は不要 — 現状のまま遷移して `region` が空欄になることを確認する。

#### B-3: アソシエーションフィールド（マッピングあり）

`_Supplier/category` を `supplierCategory` としてターゲットに渡す。

```cds
annotate service.Orders with {
    supplierId @Common.SemanticObjectMapping: [{
        LocalProperty: supplierId,
        SemanticObjectProperty: 'vendor'
    }, {
        LocalProperty: '_Supplier/category',
        SemanticObjectProperty: 'supplierCategory'
    }];
};
```

（B-1 と B-3 は同じアノテーションに統合して実装する）

#### B-4: NavigationAvailable

`isNavEnabled` が `false` の行（ORD002, ORD005）では、IBN ボタンを非表示にする。

```cds
annotate service.Orders with @(
    UI.LineItem: [
        {
            $Type          : 'UI.DataFieldForIntentBasedNavigation',
            ...
            NavigationAvailable: isNavEnabled,
        }
    ]
);
```

### 実装手順（Group B）

1. `git checkout -b feature/group-b-context` （main から分岐）
2. `test/nav-service.test.js` にコンテキスト検証テストを追加（TDD: Red フェーズ）
   - ただし OData protocol-level では IBN コンテキストは検証できないため、アノテーション構造の確認テストを追加する想定
3. `app/nav-source/annotations.cds` に B-1〜B-4 アノテーションを追加
4. 手動確認（nav-target フィルターバーの各フィールドが意図通り埋まるか）
5. README に Group B セクションを追加
6. コミット → main へマージ

### 注意事項

- `@Common.SemanticObjectMapping` は `@Common.SemanticObject` と同じプロパティに付与する
- B-2 は「何も変えない」ことで動作確認するパターン — README で「アソシエーション経由フィールドはデフォルトで渡されない」と明示することが目的
- B-4 の `NavigationAvailable` は A-3/A-4 の IBN アクションに適用する（A-2 は RequiresContext:false なので無関係）

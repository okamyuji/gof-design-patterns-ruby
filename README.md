# GoF Design Patterns in Ruby

Ruby 3.4.8での Gang of Four デザインパターン実装。DDDアプローチを採用し、Ruby標準ライブラリのみを使用。

## Requirements

- Ruby 3.4.8 (mise管理)
- Bundler

## Setup

```bash
# miseでRubyバージョンを設定
mise install

# バージョン確認
ruby -v  # => ruby 3.4.8

# 依存関係のインストール
bundle install
```

## Usage

### ライブラリとして使用

```ruby
require 'gof_patterns'

# 各パターンを使用
GofPatterns::Creational::Singleton
GofPatterns::Structural::Adapter
GofPatterns::Behavioral::Observer
```

### サンプルコードの実行

各パターンのサンプル実装が `examples/` ディレクトリにあります:

```bash
# 個別パターンの例を実行
ruby examples/creational/singleton_example.rb
ruby examples/structural/adapter_example.rb
ruby examples/behavioral/observer_example.rb

# 全ての例を確認
ruby examples/**/*_example.rb
```

## Test

```bash
# 全テスト実行
bundle exec rake test

# カテゴリ別テスト
bundle exec rake test:creational
bundle exec rake test:structural
bundle exec rake test:behavioral

# Rubocop (コードスタイルチェック)
bundle exec rubocop

# Rubocop 自動修正
bundle exec rubocop -A
```

## Design Patterns

### Creational Patterns (生成パターン) - 5つ

| Pattern | 説明 |
|---------|------|
| Singleton | インスタンスが1つだけ存在することを保証 |
| Factory Method | サブクラスでインスタンス化するクラスを決定 |
| Abstract Factory | 関連オブジェクト群を具象クラスを指定せずに生成 |
| Builder | 複雑なオブジェクトの構築と表現を分離 |
| Prototype | 既存オブジェクトをコピーして新しいオブジェクトを生成 |

### Structural Patterns (構造パターン) - 7つ

| Pattern | 説明 |
|---------|------|
| Adapter | 互換性のないインターフェースを接続 |
| Bridge | 抽象と実装を分離して独立に変更可能に |
| Composite | ツリー構造でオブジェクトを組み合わせ |
| Decorator | オブジェクトに動的に機能を追加 |
| Facade | 複雑なサブシステムに単純なインターフェースを提供 |
| Flyweight | 多数のオブジェクト間で状態を共有してメモリ節約 |
| Proxy | 他のオブジェクトへのアクセスを制御する代理 |

### Behavioral Patterns (振る舞いパターン) - 11つ

| Pattern | 説明 |
|---------|------|
| Chain of Responsibility | リクエストを処理者のチェーンに沿って渡す |
| Command | リクエストをオブジェクトとしてカプセル化 |
| Interpreter | 言語の文法を定義し解釈 |
| Iterator | コレクションの要素に順次アクセス |
| Mediator | オブジェクト間の通信を仲介 |
| Memento | オブジェクトの状態を保存・復元 |
| Observer | オブジェクト間の一対多の依存関係を定義 |
| State | 内部状態に応じてオブジェクトの振る舞いを変更 |
| Strategy | アルゴリズムを交換可能にカプセル化 |
| Template Method | アルゴリズムの骨格を定義しサブクラスで詳細実装 |
| Visitor | オブジェクト構造から操作を分離 |

## DDD Approach

各パターンはDDD戦術パターンを適用:

- **Entity**: 識別子を持つドメインオブジェクト
- **Value Object**: 不変で属性で等価性を判断
- **Domain Service**: エンティティに属さないドメインロジック
- **Repository**: 集約の永続化を抽象化

## Directory Structure

```
lib/
├── gof_patterns.rb           # メインエントリポイント
├── creational/               # 生成パターン (5パターン)
├── structural/               # 構造パターン (7パターン)
└── behavioral/               # 振る舞いパターン (11パターン)

examples/
├── creational/               # 生成パターンの実行例
├── structural/               # 構造パターンの実行例
└── behavioral/               # 振る舞いパターンの実行例

test/
├── test_helper.rb
├── examples/                 # サンプルコードのテスト
├── creational/               # 生成パターンのテスト
├── structural/               # 構造パターンのテスト
└── behavioral/               # 振る舞いパターンのテスト
```

## License

MIT

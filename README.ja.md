# divecode

<p align="center">
  <img src="assets/banner.png" alt="Dive Coding — Guide the genie. Get the wish right." />
</p>

<p align="center">
  <a href="README.md">한국어</a> ·
  <a href="README.en.md">English</a> ·
  <strong>日本語</strong> ·
  <a href="README.zh-Hans.md">简体中文</a>
</p>

> divecoding は方法論、divecode はそれを実行する道具。

アラジンが最初にジーニーに頼んだのは「王女と結婚したいから王子にしてくれ」だった。ジーニーは文字通り叶える。アラジンは王子の称号を得て、象の行列を従え、王女は手に入らなかった。

コーディングエージェントがその種のジーニーだ。願いは文字通りに実行される。「Redis キャッシュと 5 分毎の Vercel cron 付きの admin dashboard を作って」と投げれば、その文章ぶんだけが実装される。TTL に jitter を入れるか、cron が 2 つ重なって走ったらどうなるか、キャッシュがまだ空のとき dashboard には何が出るか — どれも願いに無いので、聞かない。聞かずにそのまま書く。

3 週間後に本番が燃える。願いに無かったものが全部噴く。

divecoding はその隙間に入る。ざっくり書いた願い(PRD でも、一行コマンドでも、スケッチでも)を渡すと、divecode がそこからどの *pattern packs* が引っかかるかを見る。redis-cache、admin-dashboard、vercel-serverless、postgres-saas、payments…。引っかかった pack が、指定しそびれた質問を一つずつ投げる。Cache stampede、cron 競合、auto-refresh の負荷、replica lag、SCA 中断。本当に意図していたのは何だったのかを、もう一度問う。

残りの部品(AWS AI-DLC macro flow、agent-flow guardrail、TDD gate、PR watcher)は、その明確化された願いを実コードまで生き残らせるための装置にすぎない。

## ジーニー原則

願いを叶える前に、divecode が三つを確認する。

1. 文字通り叶える願いは X。それで合っているか。
2. 指定していないが X が依存しているもの: A、B、C。(引っかかった pack から抽出。)
3. 今 A、B、C を指定しないなら、X は文字どおりにだけ叶う。それでも進めるか、追加で書くか。

これが divecoding の唯一の普遍ルールだ。inception → construction → operations のフェーズも、light/standard/strict のプロファイルも、pack も gate も、全てこの停止をどの粒度で挟むかを決める装置にすぎない。使い捨てスクリプトなら一行ぶんの停止、payments 統合なら 20 問ぶんの停止。原理は同じ。

これが機能する理由は単純だ。ジーニーは何でも叶える。現代のエージェントはほぼ全ての種類のコードを書く。だからボトルネックはもう能力じゃなくて *具体性* の側にある。divecoding はその具体性そのものを作業にする。

## 元々開発者がやっていたこと

Vibe coding が教えてくれたのは三つ。コードは速く流れ出る。誰が書いてもだいたい同じコードが多い。typing はエージェントが肩代わりする。

教えてくれなかったのも三つ。なぜそう書いたのか、どんなトレードオフを選んだのか、1ヶ月後にこのコードを読み返すのは誰か。

元々開発者は後者をやる人だった。1 行書く前に — 要件を正確に読み、エッジケースを描き、データモデルをスケッチし、アルゴリズムを選び、失敗の可能性を先に見て、トレードオフを決めて、それからキーボードに触れていた。

Vibe coding はその 7 ステップを「describe what you want, accept what comes」一つに圧縮した。時間が減った。消えた 6 ステップごとに、1ヶ月後に噴く事故が 1 件ずつ地面に埋まる。

Dive coding はその 6 を戻す。typing 部分はエージェントに任せたまま、その前にあった *考える* 部分を人間に返す。エージェントはコードの代わりに *質問* でその思考を引き出す。

| | Vibe coding | Dive coding |
|---|---|---|
| 入力 | 一行の願い | 仕様(段々精緻化される) |
| ペース | エージェントが決める | 人が決める |
| 出力 | コード、その後 rework | 決定、その後一発で動くコード |
| 発見地点 | 本番(数週間後) | キーボードを叩く前(数分後) |
| 開発者の役割 | typing 監督 | 仕様を作る人 |
| 発揮する技 | 受け入れ | 判断・センス・知識 |
| ドキュメント化 | 「書かなきゃ」 | workflow から自然に出てくる |
| 向く場面 | 探索、使い捨て、デモ | ポストモーテムを書くようなもの |
| 比喩 | 書き取り | 対話 |

要するに dive coding はエージェントによりよい答えを出させる仕掛けじゃない。人がよりよい質問を投げられる位置に立たせる仕掛けだ。

## 使うと何がいいか

抽象論じゃなく手に取れるものだけ。全て divecode を作るきっかけになった agent-cat 開発で実際に起きた話。

ship 前にバグが捕まる。agent-cat admin dashboard、事故の 3 週間前の PRD には「Redis キャッシュ」と「Vercel cron 5 分毎」が書いてあった。divecode なら投げていた質問は三つ。TTL いくつ? jitter は? cron が走っている間に dashboard も polling したら何が起きる? 10 分で終わる会話だった。実際の事故復旧には日曜の午後がまるごと消えた。

エージェントが構造的選択で驚かせなくなる。「data layer では Repository pattern を使え」は夜 11 時に思い出すルールじゃない。エージェントが次のファイルを書く前に投げる質問になる。「これは eventually consistent か strongly consistent か」も同じ流れ。決定に 30 秒、巻き戻しに 3 日かかる類の判断だ。

PRD が自然に鋭くなる。3 段落の spec を投げると、12 個の質問が戻ってくる。答えると、その答えがそのまま design.md の本文になる。フォーマット済み、決定ログ付き、TDD slice にすぐ分解できる状態で。中途半端なものから本物の spec が立ち上がる。

ドキュメント化は義務じゃなく副産物に変わる。session ごとに design.md + risk-map.md + decision lore が勝手に落ちてくる。半年後「何でこう設計した?」が出てきたとき、答えは日付とトレードオフ付きのファイルにある。意識して書いたものじゃなく、workflow が落としていったもの。

シニア・ジュニアの摩擦が減る。以前は「replica lag 考えた?」の出どころがシニアだった。今は divecode が先に問い、シニアは答えを review するだけで済む。同じ質問を毎回掘り起こさなくていい。ジュニアは講義を受ける代わりに、質問そのものを見ながら学ぶ。

トークンコストも下がる。vibe-coding サイクルは: 書く → これ違うな → 書き直す → やっぱり違う → 書き直す。毎回トークンを食う。divecode は思考を前に置くので、最初の生成がだいたい最後の生成になる。

最後に — エージェントがチームの実決定で「訓練」される。lore エントリ(`~/.divecode/lore/` + `.divecode/lore/`)が bolt 間、session 間で引き継がれる。先月入れた Constraint(「integration test は本物の DB を叩く、mock 禁止」)が来月の design.md で自動的に引用される。部族の知識がファイルの知識になる。

## divecoding でないもの

- 計画フレームワークじゃない。ストーリーポイントもスプリントも見積もりポーカーもない。
- コード生成器でもない。意図的にコードを書かない。代わりに質問を書く。
- 重たい方法論でもない。認定も儀式も Sprint Zero もない。「止まる、失敗モードを浮かび上がらせる、それから作る」だけ。
- RAG のラッパーでもない。Pattern packs は能動的な質問生成器で、受動的な検索じゃない。PRD に "redis" が含まれていても一般的な Redis ドキュメントを投げるんじゃなく、Redis ユーザーが本番で実際にハマるものを尋ねる。

## インストール

```bash
curl -fsSL https://raw.githubusercontent.com/yong076/divecode/main/bootstrap.sh | bash
```

`~/.divecode/` にクローンされ、`~/.claude/skills/` にシンボリックリンクされる。次の Claude Code セッションから、どのプロジェクトディレクトリでも `/divecode` を呼べる。

初回起動はリポジトリを見てプロファイルを推薦する。確認すれば、その後は勝手に動く。

削除: `bash ~/.divecode/uninstall.sh`

## プロファイル

divecode は 3 つの深さで動く。ceremony はバグが出たときどれくらい痛いかに応じて自動で調整される。

- light — プロトタイプとソロ作業向け。4 phase(spec / design / arch / implement)。worktree なし、PR 自動化なし、TDD gate なし。v0 互換。
- standard — 実プロダクション向け。PRD interrogation、slice-plan、multi-reviewer、fix-loop、全体 lifecycle(commit → push-pr → pr-watch → merge → cleanup)を追加。
- strict — mission-critical なコード向け。形は standard と同じだが、gate が実際にブロックする。失敗 test 無しに production code を書けない。Repository Pattern に違反する data layer コードは書けない。すべてのアーキテクチャ決定は `lore/` から引用必須。

初回起動でリポジトリ(commit history、test infra、CI config、ARCH/CONTRIBUTING ドキュメント、README サイズ)を見て推薦。ユーザーが確認 or override。

## セッションの流れ

```
INCEPTION
 ├─ prd         ざっくり PRD 投入 → pattern-pack triggers 発火 → risk-map + open-questions 産出
 ├─ audit       すでに進行中のプロジェクトの場合のみ
 ├─ ux          この画面、5 つの state でどう見える?
 ├─ spec        7 phase 尋問、niche-knowledge チェックリストを引き込む
 └─ slice-plan  TDD-ready チャンクに分解
                ⏸ 人間レビューのための pause

CONSTRUCTION
 ├─ worktree    profile に応じた branch + worktree
 ├─ implement   失敗 test を先に、それからコード
                (strict ではエージェントが失敗 test 無しに production code を書くことを拒否)
 ├─ review      reviewer エージェントを並列 spawn; architecture-design specialist は必須
 └─ fix-loop    must-fix を処理; 最大 3 round、超えたらユーザーにエスカレーション

OPERATIONS
 ├─ commit      convention-aware、profile 駆動
 ├─ push-pr
 ├─ pr-watch    6-status routing、CI 失敗 / PR コメントに自動応答
 ├─ merge
 └─ cleanup     worktree 削除、main 同期、後世に残すべき決定は lore へ記録するよう促す
```

light では construction/operations の大半は skip される。spec, design, build, ship 程度。strict では全部有効化され、gate が実際にブロックする。深さは profile と bolt サイズで適応する。

## 「Sprint」ではなく「Bolt」

bolt は集中作業の単位 — 週ではなく、時間 ~ 日のスケール。AWS AI-DLC 由来の用語で、ちゃんと役に立つ。`/divecode` 開始時に bolt サイズ(small / medium / large)を聞かれ、その答えで各 phase の深さが変わる。small bolt はインタビューが一行確認に collapse、large bolt は全 phase が拡張。

## いつ使うか、いつ使わないか

使う場面: 間違った決定一つが 1 週間の巻き戻しコストになる作業すべて。データの形、お金、認証、マルチプラットフォーム同期、実負荷の性能、DB migration を含むもの、ポストモーテムを書くようなもの。

使わない場面: 使い捨てスクリプト、one-off 探索、2 日後に消すコード。普通に vibe-code でいい。

スイートスポットはシニアエンジニアがエージェントとペアで本物の feature を作るとき。または 2 人のエンジニア — 一人がアホな質問を投げ、もう一人が経験で答え、エージェントが両者ともに思いつかなかった 3 つ目を surface するとき。

## Pattern packs

pack システムが divecoding の質問生成器だ。PRD にキーワードが現れると pack が起動し、その pack が抱える questions / failure modes / test ideas を発射する。v0.3 で deep pack 9 個リリース:

```
packs/
  redis-cache/        ✓ — redis, upstash, ttl, cache stampede, eviction, lru
  postgres-saas/      ✓ — postgres, neon, supabase, rds, prisma, pgbouncer
  admin-dashboard/    ✓ — admin, dashboard, ops team, auto refresh, polling
  vercel-serverless/  ✓ — vercel, edge function, cron, cold start, ISR
  payments/           ✓ — stripe, paddle, billing, webhook, refund, SCA, 3DS
  nosql/              ✓ — dynamodb, mongo, firestore, cassandra, partition key, gsi
  performance/        ✓ — latency, p99, web vitals, lighthouse, n+1, bundle size
  security/           ✓ — oauth, jwt, csrf, xss, idor, pii, gdpr, rbac, secrets
  ux-apple-hig/       ✓ — swiftui, ios app, dynamic type, dark mode, voiceover

  # 次:
  realtime-sync/      websocket, sse, pubsub
  telemetry-privacy/  telemetry, analytics, pii, opt-in
  macos-app/          menu bar, sparkle, notarization, dmg
  github-releases/    github actions, release, codesign
```

各 pack の構成:
- `triggers` — divecode-prd が PRD テキストと照合するキーワード
- `questions.md` — pack が発射する実際の尋問プロンプト
- `failure-modes.md` — この pack が防ぐべき本番事故
- `test-ideas.md` — 答えが生み出すべき test case
- `example-patterns.md` — 具体例(「言うな、見せろ」用)

`packs/` への PR が最もレバレッジの大きい貢献だ。エージェントが聞いてくれるべきだったバグに刺された経験があるなら、それが pack 一つぶんの素材。

## 試してみる

```bash
# PRD のあるプロジェクトで
/divecode-prd path/to/PRD.md
```

このスキルがやること:
1. PRD に対して `bin/divecode-prd-triggers` を実行
2. マッチした pack をユーザーに確認(false positive は除外可)
3. `divecode/risk-map.md` に各 pack の failure modes をレンダ
4. マッチした pack の `questions.md` の和集合を walk-through
5. 答えた内容で `divecode/design.md` §1 + §2 + §6 を埋める
6. design.md の残りは `/divecode-spec`、TDD slice に直接ジャンプするなら `/divecode-slice-plan`

同梱の fixture でも回せる(`/divecode-prd` 呼び出し不要、matcher だけ):

```bash
bash ~/.divecode/bin/divecode-prd-triggers \
  --prd ~/.divecode/tests/fixtures/prd-admin-dashboard.md \
  --packs-dir ~/.divecode/packs
```

その PRD(agent-cat admin 事故を 3 段落の spec に整理したもの)は 6 つの pack を発火させ、~50 個の質問を surface する。Redis stampede、cron 競合、auto-refresh DDoS、IDOR / SSO リスク、DynamoDB に乗り換えていたら出会う partition-key trap。実際にシステムを落としたものたち。

## divecoding の立ち位置

| ツール / 方法論 | 強み | やろうとしないこと |
|---|---|---|
| AWS AI-DLC | Lifecycle macro flow(Inception → Construction → Operations)と "bolt" 単位 | ドメイン特化の failure-mode surface |
| GitHub Spec Kit | Spec-driven development、構造化された spec フォーマット | stack ごとの本番 risk 尋問 |
| Claude Skills | エージェント capability の配布 + 実行フォーマット | 上に乗せる方法論レイヤー |
| **divecoding** | **PRD 尋問 → human-in-loop の意思決定抽出 → niche な failure-mode の surface** | SDLC 全体を所有、チケットシステムの置き換え |

divecode は自由に盗む。AWS から macro shape、agent-flow から phase 内部の guardrail、Clean Code から「discipline-is-the-feature」の姿勢、Spec Kit から artifact-first の指向。自分自身の貢献は PRD risk interrogation engine と、それを駆動する pattern pack ライブラリ。

## トーンについて

スキルは韓国語と英語が混じったまま話す。私がそうやって働き、チームメイトもそうやって働くからだ。フォークしてあなたのチームに合わせて再トーンしても OK。pack 自体は言語非依存で、エージェントの prompt 文言にだけ韓国語が混じっている。

## レイアウト

```
divecode/
├── bin/          スキルが呼ぶ小さな bash スクリプト (detect, bolt, lore, tdd-gate, pr-watch, ...)
├── skills/       SKILL.md ファイル — Claude Code が読むもの
├── checklists/   v0 の niche knowledge (redis, sql, nosql, perf, security, ux-hig).
│                 v0.3 で packs/ に吸収。
├── packs/        Pattern packs — PRD interrogation の核
├── templates/    profile.yml, design.md, slice-plan.md, lore-entry, review templates
├── tests/        bin/ スクリプト用の bash test 群
└── docs/         v0.2/ — divecode 自身の meta-spec
                  v0.3/ — PRD interrogation engine spec
```

## コントリビュート

一番役に立つ PR は `packs/` への新規 pack 追加だ。エージェントが聞いてくれるべきだったバグに刺されたことがあるなら、triggers + questions + failure-modes + example-patterns を揃えて pack として書いてほしい。そこがレバレッジの効く場所。

新しい skill や pipeline phase は、まず issue を開いて場所を相談しよう。

## ライセンス

MIT。使って、フォークして、トーン変えて、言語変えて、社内ツールに埋め込んで構わない。本番事故を 1 つでも防げれば元は取れる。

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

> **divecoding** は方法論、**divecode** はそれを実行するツールです。

『アラジン』の最初の願い、覚えていますか? 「王女と結婚するために、私を王子にしてくれ」。ジーニーはその通りに叶えました — 文字通りに。アラジンは王子の称号も、象も、行列も手に入れた。でも王女は手に入りませんでした。

**コーディングエージェントはジーニーです。** あなたの願いを文字通りに受け取ります。「Redis キャッシュと 5 分毎に走る cron job を持つ admin dashboard を作って」と言えば — その文章通りに実装されます。ジーニーは TTL に jitter を入れるかは聞いてくれません。cron が重なったときに idempotent にすべきか聞いてくれません。キャッシュが cold な時 dashboard がどう見えるかも聞いてくれません。願いに書いてなかったので。

3 週間後、本番に火がつきます。願いに書かれていなかったものが全部噴き出して。

**divecoding は、叶える前に問い返すジーニーです。** ざっくり書いた願い — PRD でも、一行のコマンドでも、スケッチでも — を投げ込むと、divecode がその中身を見て、どの *pattern packs* が当てはまるか(redis-cache, admin-dashboard, vercel-serverless, postgres-saas, payments…)を見つけ、あなたが指定しそびれた質問を一つずつ聞いていきます。Cache stampede、cron 競合、auto-refresh DDoS、replica lag、SCA 離脱。*本当に意図していた* 願い。

それが核です。残り — AWS AI-DLC macro flow、agent-flow guardrail、TDD gate、PR watcher — はすべて、明確化された願いが実際のコードまで生き残るための仕組みです。

## ジーニー原則 (The Genie principle)

どんな願いも叶える前に divecode は問います:

1. **あなたが文字通り願ったのは** X です。合っていますか?
2. **指定していないけれど X が依存しているもの**: A, B, C。(トリガーされた packs から抽出。)
3. **今ここで指定しなければ、X は文字通りに** 叶えられます。指定しますか?

これが divecoding の唯一の普遍ルールです。フェーズ(inception → construction → operations)、プロファイル(light / standard / strict)、packs、gates — それらはすべて、このジーニーの一時停止を適切な粒度で実装する仕掛けです。使い捨てスクリプトには一行の一時停止、payments 統合には 20 問の一時停止。原理は同じ。

これが機能する理由: **ジーニーは何でも叶えられる**(現代のエージェントはほぼあらゆるコードを書きます)。ボトルネックはもう能力ではなく **具体性** です。divecoding は、その具体性そのものを作業にします。

## 使うと何がいいか

抽象論じゃなくて、実際に手に取れるもの。divecode を作るきっかけになった agent-cat 開発の実例多めで:

**バグを ship 前に捕まえる。ship 後じゃなく。**
agent-cat admin dashboard、事故の 3 週間前: PRD には「Redis キャッシュ」と「Vercel cron 5 分毎」が書いてあった。divecode が問うていたはずの質問:「TTL は? jitter は? cron が走っている間に dashboard も polling したら何が起きる?」3 つの質問、10 分。実際の事故復旧には日曜の午後がまるごと消えました。

**エージェントが構造的選択で驚かせなくなる。**
「data layer では Repository pattern を使え」は夜 11 時に思い出すルールじゃない。エージェントが次のファイルを書く前に問い返す質問になる。「これは eventually consistent? strongly consistent?」も同じ — 決定に 30 秒、巻き戻しに 3 日かかる類の判断。

**PRD が自然に鋭くなる、書く量を増やさずに。**
3 段落の spec を投げ込む。12 個の質問が返ってくる。答える。その答えがそのまま design.md の残りになる — フォーマット済み、決定ログ付き、TDD slice にすぐ分解できる状態で。中途半端なものから本物の spec が出てくる。

**ドキュメント化が義務じゃなく副産物になる。**
divecode session ごとに design.md + risk-map.md + decision lore が自動で生まれる。半年後「これ何でこう設計した?」が出てきたとき、答えは日付と trade-off が書かれたファイルにある。意識的に書いたんじゃなく、workflow から落ちてきた。

**シニア/ジュニアのペアがうまく回る。**
シニアが「replica lag 考えた?」の出どころだったのが、今は divecode が先に問う。シニアは答えを review するだけで、毎回掘り起こさなくていい。ジュニアは講義じゃなく質問そのものを見ながら学ぶ。

**トークンコストが下がる、エージェントが一発で書くので。**
Vibe-coding サイクル: 書く → これ違うな → 書き直す → やっぱ違うな → 書き直す。毎回トークンを食う。divecode は思考を前倒しするので、最初の生成が大抵最後の生成になる。

**エージェントがチームの実際の決定で「訓練」される。**
Lore エントリ (`~/.divecode/lore/` + `.divecode/lore/`) は bolt 間、session 間で引き継がれる。先月入れた Constraint — 「integration test は本物の DB を叩く、mock 禁止」— が来月の design.md で自動的に引用される。部族の知識がファイルの知識になる。

## divecoding でないもの

- **計画フレームワークではありません。** ストーリーポイントもスプリントも見積もりポーカーもありません。
- **コード生成器ではありません。** 意図的にコードを書かない。代わりに *質問* を書きます。
- **重たい方法論ではありません。** 認定も儀式も Sprint Zero もありません。「止まる、失敗モードを浮かび上がらせる、それから作る」だけ。
- **RAG のラッパーではありません。** Pattern packs は能動的な質問生成器であって受動的な検索ではありません。PRD に "redis" が含まれていても一般的な Redis ドキュメントを投げるのではなく、Redis ユーザーが本番で実際にハマるものを尋ねます。

## インストール

```bash
curl -fsSL https://raw.githubusercontent.com/yong076/divecode/main/bootstrap.sh | bash
```

`~/.divecode/` にクローンし、`~/.claude/skills/` にシンボリックリンクします。次の Claude Code セッションから、どのプロジェクトディレクトリでも `/divecode` を呼び出せます。

初回起動時にリポジトリを見てプロファイルを推薦 → ユーザー確認。それ以降は自動で動きます。

削除: `bash ~/.divecode/uninstall.sh`

## プロファイル

divecode は 3 つの深さで動きます。バグを出したくない度合いに応じて ceremony が変わります。

- **light** — プロトタイプとソロ作業向け。4 phase(spec / design / arch / implement)。worktree なし、PR 自動化なし、TDD gate なし。v0 互換。
- **standard** — 実プロダクション向け。PRD interrogation、slice-plan、multi-reviewer、fix-loop、全体 lifecycle(commit → push-pr → pr-watch → merge → cleanup)を追加。
- **strict** — mission-critical なコード向け。形は standard と同じだが、gate が実際にブロックします。失敗 test 無しに production code を書けない。Repository Pattern に違反する data layer コードは書けない。すべてのアーキテクチャ決定は `lore/` から引用必須。

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
                (strict ではエージェントが失敗 test 無しに production code を書くことを拒否します)
 ├─ review      reviewer エージェントを並列 spawn; architecture-design specialist は必須
 └─ fix-loop    must-fix を処理; 最大 3 round、超えたらユーザーにエスカレーション

OPERATIONS
 ├─ commit      convention-aware、profile 駆動
 ├─ push-pr
 ├─ pr-watch    6-status routing、CI 失敗 / PR コメントに自動応答
 ├─ merge
 └─ cleanup     worktree 削除、main 同期、後世に残すべき決定は lore へ記録するよう促す
```

light では construction/operations の大半は skip — spec, design, build, ship。strict ではすべて有効化、gate が実際にブロック。深さは profile と bolt サイズで適応します。

## "Sprint" ではなく "Bolt"

bolt は集中作業の単位 — 週ではなく、時間 ~ 日。AWS AI-DLC 由来の用語で、便利です: `/divecode` 開始時に bolt サイズ(small / medium / large)を聞かれ、その答えで各 phase の深さが変わります。small bolt はインタビューが一行確認に collapse、large bolt は全 phase が拡張。

## いつ使うか、いつ使わないか

**使う場面**: 間違った決定一つが 1 週間の巻き戻しコストになる作業すべて。データの形。お金。認証。マルチプラットフォーム同期。実負荷の性能。DB migration を含むもの。ポストモーテムを書くようなもの。

**使わない場面**: 使い捨てスクリプト、one-off 探索、2 日後に消すコード。普通に vibe-code してください。

**スイートスポット**: シニアエンジニアがエージェントとペアで本物の feature を作るとき。または 2 人のエンジニア — 一人がアホな質問を投げ、もう一人が経験で答え、エージェントが両者ともに思いつかなかった 3 つ目を surface するとき。

## Pattern packs

pack システムが divecoding の質問生成器です。PRD にキーワードが現れると pack がトリガーされ、その pack が持っている questions / failure modes / test ideas を発射します。v0.3 で deep pack 9 個リリース:

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

`packs/` への PR が最もレバレッジの大きい貢献です。エージェントが聞いてくれるべきだったバグに刺された経験があれば — pack を書いてください。

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

同梱の fixture でテスト(`/divecode-prd` 呼び出し不要、matcher だけ):

```bash
bash ~/.divecode/bin/divecode-prd-triggers \
  --prd ~/.divecode/tests/fixtures/prd-admin-dashboard.md \
  --packs-dir ~/.divecode/packs
```

その PRD(agent-cat admin 事故を 3 段落 spec に整理したもの)は 6 つの pack を発火させ、~50 個の質問を surface します — Redis stampede, cron 競合, auto-refresh DDoS, IDOR / SSO リスク, DynamoDB に乗り換えていたら出会う partition-key trap。実際にシステムを落としたものたち。

## divecoding の立ち位置

| ツール / 方法論 | 強み | やろうとしないこと |
|---|---|---|
| AWS AI-DLC | Lifecycle macro flow(Inception → Construction → Operations)と "bolt" 単位 | ドメイン特化の failure-mode surface |
| GitHub Spec Kit | Spec-driven development、構造化された spec フォーマット | stack ごとの本番 risk 尋問 |
| Claude Skills | エージェント capability の配布 + 実行フォーマット | 上に乗せる方法論レイヤー |
| **divecoding** | **PRD 尋問 → human-in-loop の意思決定抽出 → niche な failure-mode の surface** | SDLC 全体を所有、チケットシステムの置き換え |

divecode は自由に盗みます: AWS から macro shape、agent-flow から phase 内部の guardrail、Clean Code から「discipline-is-the-feature」の姿勢、Spec Kit から artifact-first の指向。自分の貢献は **PRD risk interrogation engine** と、それを駆動する **pattern pack** ライブラリです。

## トーンについて

スキルは韓国語と英語が混じったまま話します — 私がそうやって働き、チームメイトもそうやって働くので。フォークしてあなたのチームに合わせて再トーンしても OK。pack 自体は言語非依存で、エージェントの prompt 文言にだけ韓国語が混じっています。

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

一番役に立つ PR は `packs/` への新規 pack 追加です。エージェントが聞いてくれるべきだったバグに刺されたことがあれば — triggers + questions + failure-modes + example-patterns を揃えて pack として書いてください。そこがレバレッジの効く場所。

新しい skill や pipeline phase は、まず issue を開いて場所を相談しましょう。

## ライセンス

MIT。使って、フォークして、トーン変えて、言語変えて、社内ツールに埋め込んでください。本番事故を 1 つでも防げれば元は取れます。

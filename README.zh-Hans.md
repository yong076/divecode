# divecode

<p align="center">
  <img src="assets/banner.png" alt="Dive Coding — Guide the genie. Get the wish right." />
</p>

<p align="center">
  <a href="README.md">한국어</a> ·
  <a href="README.en.md">English</a> ·
  <a href="README.ja.md">日本語</a> ·
  <strong>简体中文</strong>
</p>

> divecoding 是方法论,divecode 是实现它的工具。

阿拉丁第一个许给精灵的愿望是 "让我变成王子,这样我就能和公主结婚"。精灵照字面意思办了。阿拉丁拿到了王子头衔、大象、游行队伍,公主没拿到。

编程 agent 就是这种精灵。愿望按字面意思被执行。"给我做一个带 Redis 缓存和每 5 分钟跑一次 cron job 的 admin dashboard" 扔进去,被实现的就是那句话的字面分量。TTL 要不要加 jitter,cron 两次重叠该怎么办,缓存还没填好时 dashboard 给用户看什么 — 这些都不在愿望里,所以 agent 不问。不问,直接写。

3 周后生产环境烧起来。没写进愿望的东西全爆。

divecoding 就插在这个缝里。把粗糙的愿望(PRD 也好,一行命令也好,草图也好)递过去,divecode 会从里面识别哪些 *pattern packs* 适用: redis-cache、admin-dashboard、vercel-serverless、postgres-saas、payments……。被触发的 pack 把你忘记指定的问题一个一个抛出来。Cache stampede,cron 重叠,auto-refresh 压力,replica lag,SCA 中途流失。你真正想要的那个愿望。

剩下的部件(AWS AI-DLC macro flow、agent-flow guardrail、TDD gate、PR watcher)只是为了让澄清后的愿望能一路活到代码里。

## 精灵原则

实现任何愿望之前,divecode 会盘三件事:

1. 按字面理解,愿望是 X。这没错吧。
2. 你没指定但 X 依赖的东西: A、B、C。(从触发的 packs 里抽出来。)
3. 如果现在不定 A、B、C,X 就只按字面那么多被实现。要补,还是就这样。

这就是 divecoding 唯一的通用规则。inception → construction → operations 的 phase、light/standard/strict 的 profile、packs、gates,全部都只是把这个停顿铺在合适的颗粒度上。一次性脚本只需要一行的停顿,payments 集成要 20 个问题的停顿。原理一样。

之所以能成立,逻辑很简单。精灵什么都能办。现代 agent 几乎能写所有种类的代码。所以瓶颈不在能力,而在 *具体性*。divecoding 把 "做到具体" 这件事本身当作工作。

## 开发者本来该做的事

Vibe coding 教会我们三件事。代码可以快速流出来。大部分代码不管谁写都差不多。typing 这事 agent 可以替我们干。

没教我们的也是三件。为什么这么写,当时考虑了哪些 trade-off,一个月后回来读这段代码的是谁。

开发者本来就是做后面这三件的人。敲下第一行之前 — 仔细读需求,把 edge case 画出来,sketch 数据模型,选算法,提前看到失败模式,定 trade-off,然后才碰键盘。

Vibe coding 把这 7 步压成了一句:"describe what you want, accept what comes"。时间是少了。每少一步,就在地下埋一个一个月之后会炸的事故。

Dive coding 把那 6 步铺回去。Agent 替你 typing 的那一段保留,前面 *思考* 的那一段交还给人。Agent 用 *提问* 把那段思考从你脑子里拎出来,而不是替你直接写代码。

| | Vibe coding | Dive coding |
|---|---|---|
| 输入 | 一句愿望 | 规格(逐步变精确) |
| 节奏 | Agent 定 | 人定 |
| 输出 | 代码,然后返工 | 决策,然后一次成型的代码 |
| 发现时机 | 生产环境(几周后) | 还没敲键盘(几分钟内) |
| 开发者角色 | typing 监工 | 写规格的人 |
| 发挥的能力 | 接受 | 判断 · 品味 · 知识 |
| 文档化 | "应该写一下" | 从 workflow 自然掉出来 |
| 适合 | 探索、一次性、demo | 值得写 postmortem 的事 |
| 比喻 | 听写 | 对话 |

换句话说,dive coding 不是让 agent 给出更好的答案,而是把人放到一个能提出更好问题的位置。

## 用了有什么好处

只说能拿到手的。全部来自催生 divecode 的 agent-cat 开发里真实发生过的事。

bug 在 ship 之前抓住。agent-cat admin dashboard,事故前 3 周,PRD 里写了 "Redis 缓存" 和 "Vercel cron 每 5 分钟"。divecode 本来会问的就三个: TTL 多少? 要不要加 jitter? cron 在跑的时候 dashboard 还在 polling 会怎样? 十分钟的对话。真实事故的恢复花掉了整个周日下午。

Agent 不再用结构选择吓你一跳。"在 data layer 用 Repository pattern" 不是你晚上 11 点能想起来的规则。它变成 agent 写下一个文件之前会反问你的问题。"这个要 eventually consistent 还是 strongly consistent" 也是同一类。决定要 30 秒,回退要 3 天的那种。

PRD 自动变锋利。把一份三段的 spec 扔进去,12 个问题回来。回答完,那些答案就直接变成 design.md 的正文。格式已经有了,决策日志已经在,可以立即拆成 TDD chunk 的状态。半成品 PRD 变成一份真正的 spec。

文档化从义务变成副产物。每次 divecode session 都自动落下 design.md + risk-map.md + decision lore。半年后冒出 "当时为什么这么选?" 的时候,答案就在一份带日期和 trade-off 的文件里。没人特意去写,是 workflow 自己掉下来的。

Senior 和 junior 配合的摩擦变小。以前 "你想过 replica lag 没?" 的源头是 senior。现在 divecode 先问,senior 只 review 答案,不用每次都把同一个问题挖出来。Junior 不再被讲课,而是边看问题边学。

Token 成本也降。Vibe-coding 的循环是: 写 → 哎不对 → 重写 → 还是不对 → 再重写。每轮都烧 token。divecode 把思考提前,所以第一次生成往往就是最后一次。

最后 — agent 会被你团队的真实决策 "训练"。Lore 条目(`~/.divecode/lore/` + `.divecode/lore/`)在 bolt 之间、session 之间传递。上个月你定的 Constraint("integration test 打真实 DB,不准 mock")下个月的 design.md 里会被自动引用。部落知识变成文件知识。

## divecoding 不是什么

- 不是规划框架。没有 story point,没有 sprint,没有估算扑克。
- 也不是代码生成器。它故意不写代码,而是写问题。
- 也不是重型方法论。没有认证,没有仪式,没有 Sprint Zero。"停下,把失败模式翻出来,然后再做" 就是它的全部形状。
- 也不是 RAG 包装层。Pattern packs 是主动的问题生成器,不是被动检索。PRD 里有 "redis" 不代表会丢一堆 Redis 文档给你 — 而是会问 Redis 用户在生产中真正会被咬的那些问题。

## 安装

```bash
curl -fsSL https://raw.githubusercontent.com/yong076/divecode/main/bootstrap.sh | bash
```

克隆到 `~/.divecode/`,把 skills 软链到 `~/.claude/skills/`。下一个 Claude Code 会话,在任何项目目录里输入 `/divecode`。

第一次运行会看你的 repo 推荐一个 profile。你确认一次,之后它自己跑。

卸载: `bash ~/.divecode/uninstall.sh`

## Profile

divecode 有三种深度。ceremony 程度按 "出 bug 会有多痛" 自动调节。

- light — 适合原型和个人项目。4 个 phase(spec / design / arch / implement)。没有 worktree,没有 PR 自动化,没有 TDD gate。v0 兼容。
- standard — 适合真正的生产工作。加上 PRD interrogation、slice-plan、multi-reviewer、fix-loop,以及完整 lifecycle(commit → push-pr → pr-watch → merge → cleanup)。
- strict — 适合 mission-critical 代码。形态和 standard 一样,但 gate 真的会拦你。没有失败 test 就不能写 production code。违反 Repository Pattern 的 data layer 代码不能写。每个架构决策必须从 `lore/` 引用。

第一次运行会看 repo(commit 历史、test infra、CI 配置、ARCH/CONTRIBUTING 文档、README 大小)并推荐一个。你确认或覆盖。

## 一次 session 的样子

```
INCEPTION
 ├─ prd         扔进粗糙 PRD → pattern-pack triggers 触发 → risk-map + open-questions 产出
 ├─ audit       只有项目已经在进行中时才用
 ├─ ux          这个界面在 5 种 state 下分别长什么样?
 ├─ spec        7 phase 审问,引入 niche-knowledge 清单
 └─ slice-plan  拆成 TDD-ready 的块
                ⏸ 等人工 review 的 pause

CONSTRUCTION
 ├─ worktree    按 profile 创建 branch + worktree
 ├─ implement   先写失败的 test,再写代码
                (在 strict 下,agent 字面意义上拒绝在没有失败 test 时写 production code)
 ├─ review      并行 spawn 多个 reviewer agent;architecture-design 专家是必须
 └─ fix-loop    处理 must-fix;最多 3 轮,超出就上报给用户

OPERATIONS
 ├─ commit      convention-aware、profile-driven
 ├─ push-pr
 ├─ pr-watch    6 种 status routing,自动响应 CI 失败 / PR 评论
 ├─ merge
 └─ cleanup     删 worktree,同步 main,提示你把值得留下的决策记录成 lore
```

light 下 construction/operations 大部分被 skip — spec, design, build, ship。strict 下全部启用,gate 真会拦。深度随 profile 和你声明的 bolt 大小自适应。

## "Bolt" 而不是 "sprint"

bolt 是一次集中工作的单位 — 以小时到天为尺度,不是周。这个词来自 AWS AI-DLC,实际用着也合适。`/divecode` 开始时会问你 bolt 大小(small / medium / large),那个答案改变每个 phase 的深度。small bolt 把访谈压成一行确认,large bolt 把每个 phase 都展开。

## 什么时候用,什么时候不用

适合用: 任何 "做错一个决定就要花一周回退" 的工作。数据形状,钱,鉴权,多端同步,真实负载下的性能,带 DB migration 的事情,值得写 postmortem 的事情。

不适合用: 一次性脚本、随手探索、两天后就要删的代码。直接 vibe-code 吧。

最甜的点是资深工程师和 agent 结对做真实 feature。或者两个工程师 — 一个问蠢问题,一个用经验回答,agent 抛出两人都没想到的第三件事。

## Pattern packs

pack 系统是 divecoding 的问题生成器。pack 的关键词出现在 PRD 中就会触发,然后发射自身携带的 questions / failure modes / test ideas。v0.3 出 9 个 deep pack:

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

  # 接下来:
  realtime-sync/      websocket, sse, pubsub
  telemetry-privacy/  telemetry, analytics, pii, opt-in
  macos-app/          menu bar, sparkle, notarization, dmg
  github-releases/    github actions, release, codesign
```

每个 pack 包含:
- `triggers` — divecode-prd 用来匹配 PRD 文本的关键词
- `questions.md` — pack 实际发射的审问 prompt
- `failure-modes.md` — 这个 pack 存在的意义: 防住这些生产事故
- `test-ideas.md` — 答案应该产出的 test case
- `example-patterns.md` — 具体示例("show, don't tell" 用)

往 `packs/` 提 PR 是杠杆最高的贡献。如果你被某类 bug 咬过、而 agent 本应该问你那个问题,那个 bug 就是一个 pack 的素材。

## 试试看

```bash
# 在一个有粗糙 PRD 的项目里
/divecode-prd path/to/PRD.md
```

这个 skill 做的事:
1. 对你的 PRD 跑 `bin/divecode-prd-triggers`
2. 把匹配到的 pack 给你确认(可以剔除 false positive)
3. 在 `divecode/risk-map.md` 里把每个 pack 的 failure modes 渲出来
4. 把这些 pack 的 `questions.md` 合并起来带你过一遍
5. 用你的回答填充 `divecode/design.md` §1 + §2 + §6
6. design.md 剩下的部分交给 `/divecode-spec`,想直接跳到 TDD 就用 `/divecode-slice-plan`

也可以直接拿自带的 fixture 跑 matcher(不调 `/divecode-prd`):

```bash
bash ~/.divecode/bin/divecode-prd-triggers \
  --prd ~/.divecode/tests/fixtures/prd-admin-dashboard.md \
  --packs-dir ~/.divecode/packs
```

那份 PRD(把 agent-cat admin 事故整理成 3 段 spec)会触发 6 个 pack 并 surface 约 50 个问题。Redis stampede、cron 重叠、auto-refresh DDoS、IDOR / SSO 风险、要是切到 DynamoDB 就会遇到的 partition-key 陷阱。都是真的搞挂过系统的东西。

## divecoding 的位置

| 工具 / 方法论 | 强项 | 不试图做的事 |
|---|---|---|
| AWS AI-DLC | Lifecycle macro flow(Inception → Construction → Operations)和 "bolt" 单位 | 领域特定的 failure-mode surface |
| GitHub Spec Kit | Spec-driven development、结构化的 spec 格式 | 按 stack 进行的生产 risk 审问 |
| Claude Skills | agent capability 的发布 + 执行格式 | 上层的方法论 |
| **divecoding** | **PRD 审问 → human-in-loop 决策提取 → 暴露 niche failure-mode** | 拥有整个 SDLC、替代 ticket 系统 |

divecode 大方借鉴: AWS 提供 macro shape,agent-flow 提供 phase 内部 guardrail,Clean Code 提供 "discipline-is-the-feature" 的态度,Spec Kit 提供 artifact-first 的取向。它自己的贡献是 PRD risk interrogation engine 以及驱动它的 pattern pack 库。

## 关于语气

各 skill 用韩语和英语混着说,因为我和我的队友就是这么工作的。你可以 fork 后按自己团队的语气重写。pack 本身是语言无关的,只有 agent 的 prompt 文案带韩语。

## 仓库布局

```
divecode/
├── bin/          skill 调用的小 bash 脚本 (detect, bolt, lore, tdd-gate, pr-watch, ...)
├── skills/       SKILL.md — Claude Code 读取的内容
├── checklists/   v0 niche knowledge (redis, sql, nosql, perf, security, ux-hig).
│                 v0.3 已吸收进 packs/。
├── packs/        Pattern packs — PRD interrogation 的核心
├── templates/    profile.yml, design.md, slice-plan.md, lore-entry, review templates
├── tests/        bin/ 脚本的 bash test 套件
└── docs/         v0.2/ — divecode 自身的 meta-spec
                  v0.3/ — PRD interrogation engine spec
```

## 参与贡献

最有用的 PR 是往 `packs/` 加一个新 pack。如果你被某类 bug 咬过、而 agent 本应该问你那件事,就写一个 pack: triggers、questions、failure-modes,再带一两个 example-pattern。这是杠杆最大的位置。

新 skill 或 pipeline phase,先开 issue 聊一下放在哪里。

## 许可证

MIT。用、fork、改语气、改语言、塞进公司内部工具都可以。能挡住一次生产事故就值回票价。

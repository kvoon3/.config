# herdr 到 Rex 键位对照表

这份表记录 herdr 的每个默认键位在 Rex 里的落点。目标是让两个终端的肌肉记忆重合，而不是把所有键位都复制一遍。

`rex/init.lua` 是实现，这份表是它的账本。改配置时同步改表，改表时同步改配置。

## 状态取值

- **一致**。herdr 有同名动作，Rex 用同一个键完成同一件事。
- **适配**。键位保留，动作语义不同，或 Rex 只有最接近的对等物。
- **未移植**。Rex 没有对等动作，或绑定了也没意义。
- **不适用**。herdr 的可选动作默认未绑定，我们也没有对应需求。

## 事实来源

herdr 默认键位取自本机 `herdr --default-config`。文档补充项取自 https://herdr.dev/tui/docs/keyboard/ 。Rex 动作名取自 `rex -C "<client>" actions`。实际生效键位取自 `rex keymap`。

两边前缀相同。herdr 是 `ctrl+b` 加一个键，Rex 写作 `ctrl+b>键`。下面的表只写前缀之后的那一下。

## Pane

| herdr 键 | herdr 动作 | Rex 键 | Rex 动作 | 状态 |
| --- | --- | --- | --- | --- |
| `h` `j` `k` `l` | focus pane 四向 | `h` `j` `k` `l` | `pane.focus` | 一致 |
| `tab` / `shift+tab` | 下一个 / 上一个 pane | `tab` / `shift+tab` | `pane.focus_next` / `pane.focus_previous` | 一致 |
| `v` | 竖分 | `v` | `pane.split` direction=right | 一致 |
| `minus` | 横分 | `-` | `pane.split` direction=down | 一致 |
| `x` | 关闭 pane | `x` | `pane.close` | 一致 |
| `z` | 缩放 pane | `z` | `pane.zoom` | 一致 |
| `r` | 进入 resize 模式 | `r` | `client.mode.enter` name=resize | 一致 |
| resize 模式内 `h/j/k/l` | 调 pane 大小 | resize 模式内 `h/j/k/l` | `pane.resize` | 一致 |
| resize 模式内 `enter` | 退出 resize 模式 | resize 模式内 `enter` | `client.mode.exit` | 一致 |
| `shift+h/j/k/l` | 交换 pane | `shift+h/j/k/l` | `pane.move` | 适配 |
| `[` | copy mode | `[` | `client.find.open` | 适配 |
| `shift+p` | 重命名 pane | `shift+p` | `pane.rename` | 一致 |

`pane.move` 是往某方向搬动 pane，herdr 的 swap 是和邻居直接对调。多数布局下结果一样，嵌套布局下可能不同。这是推断，没有逐个布局实测。

Rex 没有 herdr 的 copy mode。`[` 落在 Rex 自带的查找上，滚动和选择交给 Rex 原生行为。

## Tab

| herdr 键 | herdr 动作 | Rex 键 | Rex 动作 | 状态 |
| --- | --- | --- | --- | --- |
| `c` | 新建 tab | `c` | `client.tab.new` | 一致 |
| `n` / `p` | 下一个 / 上一个 tab | `n` / `p` | `client.tab.next` / `client.tab.previous` | 一致 |
| `1` 到 `9` | 跳到第 N 个 tab | `1` 到 `9` | `client.tab.goto` | 一致 |
| `shift+t` | 重命名 tab | `shift+t` | `client.tab.rename` | 一致 |
| `shift+x` | 关闭 tab | `shift+x` | `client.tab.close` | 一致 |

`client.tab.goto` 的 index 从 1 开始，已实测。`index=1` 到第一个 tab，`index=3` 到第三个。

## Workspace 与 session

herdr 的 workspace 对应 Rex 的 session。

| herdr 键 | herdr 动作 | Rex 键 | Rex 动作 | 状态 |
| --- | --- | --- | --- | --- |
| `w` | workspace 选择器 | `w` | `session.switch` | 一致 |
| `shift+n` | 新建 workspace | `shift+n` | `session.new` | 一致 |
| `shift+w` | 重命名 workspace | `shift+w` | `session.rename` | 一致 |
| `shift+d` | 关闭 workspace | `shift+d` | `session.close` | 一致 |
| `g` | goto 选择器 | `g` | `pane.go_to` | 一致 |

## 全局

| herdr 键 | herdr 动作 | Rex 键 | Rex 动作 | 状态 |
| --- | --- | --- | --- | --- |
| `s` | 设置 | `s` | `client.settings` | 一致 |
| `shift+r` | 重载配置 | `shift+r` | `client.config.reload` | 一致 |
| `b` | 侧栏开关 | `b` | `client.sidebar.toggle` | 一致 |
| `?` | 键位帮助面板 | `?` | `client.palette.toggle` | 适配 |
| `q` | detach，进程继续跑 | `q` | `client.visibility.toggle` | 适配 |

Rex 没有键位帮助覆盖层，命令面板是最接近的入口。Rex 也没有 detach 概念，`q` 收起的只是窗口。

## 用户自定义键位

来自 `~/.config/herdr/config.toml` 的 `[[keys.command]]`。

| herdr 键 | herdr 动作 | Rex 键 | Rex 动作 | 状态 |
| --- | --- | --- | --- | --- |
| `t` | 浮动终端 popup | `t` | `pane.new_floating` | 适配 |
| `space` | herdr 命令面板插件 | 无 | 无 | 未移植 |
| `]` | lazygit 临时 pane | 无 | 无 | 未移植 |
| `}` | hunk diff popup | 无 | 无 | 未移植 |
| `u` | usage 插件 | 无 | 无 | 未移植 |

后四个绑定的是 herdr 的插件生态，属于 herdr 自己的配置，不进入这份对照表。

## 未移植项与原因

| herdr 键 | herdr 动作 | 原因 |
| --- | --- | --- |
| `o` | 跳到通知来源 | Rex 没有等价的通知回跳 |
| `shift+g` | 新建 worktree | Rex 没有 worktree 动作 |
| `e` | 编辑 scrollback | Rex 没有对应编辑器入口 |
| navigate 模式 `up/down` | 跨 workspace 移动 | Rex 没有 navigate 模式 |
| `ctrl+alt+*` | 免前缀直连键 | 当前只做了前缀方案，直连键留待以后 |

## 默认未绑定的可选动作

这些 herdr 动作默认不绑键，我们也没有对应需求，保持空白即可。`open_worktree`、`remove_worktree`、`previous_workspace`、`next_workspace`、`previous_agent`、`next_agent`、`focus_agent`、`move_tab_previous`、`move_tab_next`、`switch_workspace`、`clear_pane`、`last_pane`、`resize_pane_left/down/up/right`。状态记为不适用。

## Rex 独有的补充

| Rex 键 | Rex 动作 | 说明 |
| --- | --- | --- |
| `ctrl+b` 再 `ctrl+b` | `pane.send_key` key=ctrl+b | 把前缀原样送进终端，tmux 习惯 |

## 验证

改完配置后跑这几步，全部在真实 Rex 上执行。

```sh
rex config check      # 绑定数、模式数、action 数
rex config reload     # 让改动生效
rex keymap            # 逐条列出已生效的键位
```

`rex config check` 当前基线是 48 条绑定、1 个模式、leaf 的 9 个 action。数字变化说明有人加了键位，同步更新这份表。

## 维护约定

新增键位时，先查 `rex -C "<client>" actions` 确认动作名存在，再写进 `init.lua`，最后补一行表。动作名不存在就不要写，Rex 会在加载时报错。

herdr 升级后用 `herdr --default-config` 重新比对默认键位。默认键位变了，这张表也要跟着变。

## 后续

这份表将来要搬进独立的 `rex-herdr-keybinding` 仓库。搬迁时 `init.lua` 和这份表一起走，`leaf` 管理的前 6 行留在本地配置里，不要带走。

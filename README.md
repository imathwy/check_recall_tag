# check_recall_tag

一个可复用的 Lean 4/Mathlib 扩展，为 `#check` 和 `recall` 命令提供命令级 Stacks Project 标签。

## 特性

```lean
import StacksCheckRecall

@[stacks 04ZM "加法交换律"] #check Nat.add_comm

@[stacks 04ZN "重新陈述交换律"]
recall Nat.add_comm (n m : Nat) : n + m = m + n

#stacks_command_tags!
```

声明级标签仍然使用 Mathlib 原有的 `@[stacks TAG]` 和 `#stacks_tags`。

## 在其他仓库中使用

在消费者仓库的 `lakefile.toml` 中加入本包依赖：

```toml
[[require]]
name = "check_recall_tag"
git = "https://github.com/imathwy/check_recall_tag.git"
rev = "main"
```

不同 Lake 版本也支持等价的 Lean DSL 写法：

```lean
require check_recall_tag from git
  "https://github.com/imathwy/check_recall_tag.git" @ "main"
```

然后在 Lean 文件中只需导入公共根模块：

```lean
import StacksCheckRecall
```

无需导入仓库内部模块。包固定使用与当前仓库相同的 Lean 4.32.0 和 Mathlib `v4.32.0`。

## 查询命令级标签

```lean
#stacks_command_tags
#stacks_command_tags!
```

带 `!` 的版本还会显示源文件名。标签保存在持久化环境扩展中，因此导入已经编译的模块后仍可查询。

更完整的语法、限制和示例见 [COMMAND_REFS.md](COMMAND_REFS.md)。

## 本地开发

```bash
lake build
lake build Tests.CommandCrossRefTest
lake build Tests.CommandCrossRefImportTest
```

公共 API 入口是 [StacksCheckRecall.lean](StacksCheckRecall.lean)，实现位于
[StacksCheckRecall/CommandCrossRef.lean](StacksCheckRecall/CommandCrossRef.lean)。

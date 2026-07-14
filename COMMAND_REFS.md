# 命令级 Stacks 标签

Mathlib 原有的写法：

```lean
@[stacks 04ZM]
theorem foo : ... := ...
```

只能给声明加标签。本项目额外支持给 `#check` 和 `recall` 命令加标签。

## 使用方法

在使用文件中导入模块：

```lean
import StacksCheckRecall
```

然后直接在命令前写 `@[stacks ...]`：

```lean
@[stacks 04ZM "加法交换律"] #check Nat.add_comm

@[stacks 04ZN "重新陈述交换律"]
recall Nat.add_comm (n m : Nat) : n + m = m + n
```

`#check` 后面可以是任意合法表达式：

```lean
@[stacks 04ZO] #check (fun n : Nat => n + 1)
```

`recall` 也支持带证明体的形式：

```lean
@[stacks 04ZP]
recall Nat.add_comm (n m : Nat) : n + m = m + n := Nat.add_comm n m
```

## 查看标签

命令级标签使用单独的查询命令：

```lean
#stacks_command_tags
#stacks_command_tags!
```

`!` 版本会额外显示源文件名。例如：

```text
[Stacks Tag 04ZM] Example:12:0 #check Nat.add_comm (加法交换律)
```

当前输出中的行号和列号沿用 Lean 的内部位置表示，从 `0` 开始。

声明级标签仍然使用 Mathlib 原有的：

```lean
#stacks_tags
#stacks_tags!
```

## 跨模块导入

命令级标签保存在持久化环境扩展中。定义标签的模块被编译后，导入它的模块也可以查询到标签：

```lean
import MyTaggedModule

#stacks_command_tags!
```

## 限制

- 一个命令目前只能有一个 `stacks` 标签。
- 命令级包装器目前只接受 `stacks` 属性，不接受 `simp`、`aesop` 等其他声明属性。
- 命令级标签不会修改被 `recall` 或 `#check` 引用的原声明；它记录的是当前源文件中的命令位置。

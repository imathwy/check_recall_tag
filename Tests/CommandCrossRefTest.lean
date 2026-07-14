import StacksCheckRecall.CommandCrossRef

/- A declaration-level tag continues to use Mathlib's original mechanism. -/
@[stacks 04ZQ]
theorem declarationTagTest : True := True.intro

/- A tagged #check can contain an arbitrary expression, not only an identifier. -/
@[stacks 04ZM "checked as a command"] #check Nat.add_comm
@[stacks 04ZN "checked expression"] #check (fun n : Nat => n + 1)

/- Both forms of recall are supported. -/
@[stacks 04ZO "recalled without a body"]
recall Nat.add_comm (n m : Nat) : n + m = m + n

@[stacks 04ZP "recalled with a body"]
recall Nat.add_comm (n m : Nat) : n + m = m + n := Nat.add_comm n m

/- The command-level report is intentionally separate from Mathlib's
   declaration-level `#stacks_tags` report. -/
#stacks_command_tags!

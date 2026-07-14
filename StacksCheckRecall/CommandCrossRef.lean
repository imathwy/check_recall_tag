
module
public import Mathlib.Tactic.CrossRefAttribute
public import Mathlib.Tactic.Recall
set_option linter.style.header false

/-!
# Command-level Stacks references

The `stacks` attribute in Mathlib is a declaration attribute. This module adds
the same surface syntax to `#check` and `recall` commands without pretending
that either command creates a declaration.
-/

public meta section

namespace StacksCheckRecall

open Lean Elab Command

inductive CommandKind where
  | check
  | recall
  deriving BEq, Hashable, Inhabited, Repr

structure CommandTag where
  moduleName : Name
  fileName : String
  line : Nat
  column : Nat
  kind : CommandKind
  target : String
  tag : String
  comment : String
  deriving BEq, Hashable

initialize commandTagExt :
    SimplePersistentEnvExtension CommandTag (Array CommandTag) ←
  registerSimplePersistentEnvExtension {
    addImportedFn := fun entries =>
      entries.foldl (init := #[]) fun result entries => result ++ entries
    addEntryFn := fun result entry => result.push entry
  }

def parseStacksAttribute (attrs : Syntax) : CoreM (String × String) := do
  let `(Parser.Term.attributes| @[$attrs,*]) := attrs
    | throwError "malformed command attributes"
  let mut result : Option (String × String) := none
  for attrInstance in attrs.getElems do
    let attr := attrInstance.raw[1]
    if let `(attr| stacks $tag $[$comment]?) := attr then
      if result.isSome then
        throwError "a command can have at most one `stacks` attribute"
      result := some (← tag.getStacksTag, (comment.map (·.getString)).getD "")
    else
      throwError "only the `stacks` attribute is supported on commands"
  match result with
  | some value => return value
  | none => throwError "expected a `stacks` attribute"

def addCommandTag (attrs commandRef : Syntax) (kind : CommandKind) (target : String) :
    CommandElabM Unit := do
  let (tag, comment) ← liftCoreM <| parseStacksAttribute attrs
  let fileMap ← getFileMap
  let position := fileMap.toPosition (commandRef.getPos?.getD 0)
  let entry : CommandTag := {
    moduleName := (← getEnv).mainModule
    fileName := (← getFileName)
    line := position.line
    column := position.column
    kind
    target
    tag
    comment
  }
  modifyEnv (commandTagExt.addEntry · entry)

/- The attributes parser includes its trailing whitespace, so these commands
   have the desired spelling `@[stacks TAG] #check ...`. -/
elab (name := taggedCheckElab)
    attrs:Parser.Term.attributes "#check " term:term : command => do
  let inner ← `(command| #check $term)
  elabCommand inner
  addCommandTag attrs (← getRef) .check (term.raw.reprint.getD (toString term))

elab (name := taggedRecallElab)
    attrs:Parser.Term.attributes "recall " id:ident sig:optDeclSig val?:(declVal)? : command => do
  let inner := mkNode ``Mathlib.Tactic.Recall.recall #[
    mkNullNode, mkAtom "recall", id.raw, sig.raw,
    val?.map (fun value => mkNullNode #[value.raw]) |>.getD (mkNullNode)]
  elabCommand inner.raw
  addCommandTag attrs (← getRef) .recall id.getId.toString

def traceCommandTags (verbose : Bool := false) : CommandElabM Unit := do
  let entries := commandTagExt.getState (← getEnv)
  if entries.isEmpty then
    logInfo "No command tags found."
  else
    let mut messages := #[m!""]
    for entry in entries do
      let kind := match entry.kind with
        | .check => "#check"
        | .recall => "recall"
      let comment := if entry.comment.isEmpty then "" else s!" ({entry.comment})"
      let message := s!"[Stacks Tag {entry.tag}] {entry.moduleName}:{entry.line}:{entry.column} \
        {kind} {entry.target}{comment}"
      messages := messages.push m!"{message}"
      if verbose then
        messages := messages.push m!"  {entry.fileName}"
    logInfo <| MessageData.joinSep messages.toList "\n"

/-- Print Stacks tags attached to `#check` and `recall` commands. -/
elab (name := stacksCommandTags) "#stacks_command_tags" tk:("!")? : command =>
  traceCommandTags tk.isSome

end StacksCheckRecall

end

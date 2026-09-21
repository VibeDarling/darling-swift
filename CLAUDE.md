# darling-swift

## Third-party sources: fetch at a pinned commit, or vendor

The overlays and frameworks here are built from upstream Swift packages. Some of that code is used
exactly as upstream ships it; some had to be changed to build against Darling. The two get
different treatment, and the choice is a measurement, not a preference.

**Measure before restructuring.** Diff every candidate file against the upstream revision it came
from and count. Do not assume a directory is pristine because nobody has edited it recently, and do
not assume it is adapted because a changelog mentions the module. Both assumptions have been wrong
here: swift-foundation measured 35 pristine of 38, OpenCombine 92 of 103.

**Pristine files are fetched, not vendored.** `overlays/build.sh` clones the package and checks out
a pinned commit:

```sh
FOO_URL=${FOO_URL:-https://github.com/org/foo.git}
FOO_COMMIT=${FOO_COMMIT:-<full 40-char hash>}
foo_src=${FOO_SRC:-$out/foo}
if [ -z "${FOO_SRC:-}" ]; then
	[ -d "$foo_src/.git" ] || git clone --quiet --filter=blob:none "$FOO_URL" "$foo_src"
	git -C "$foo_src" fetch --quiet origin "$FOO_COMMIT" || git -C "$foo_src" fetch --quiet origin
	git -C "$foo_src" checkout --quiet --detach "$FOO_COMMIT"
fi
```

- **Pin by commit, never a branch or tag.** Record the tag beside the hash in a comment, with the
  `git ls-remote` command that checks one against the other. If no tag contains the commit, say so
  rather than leaving the hash unexplained.
- **`FOO_SRC` exists so an offline build needs no network.** Nothing verifies a checkout supplied
  that way, so the comment must say to point it at the pinned commit.
- **Never write into the fetched checkout.** `FOO_SRC` may be a shared or read-only tree.
- **Sort source lists with `LC_ALL=C`**, via `collect_sources`, or `write_source` for a hand-built
  list. Bare `find` order is filesystem order and bare `sort` is locale order; either makes the
  build non-deterministic by construction.

**Adapted files stay in the repository, and `overlays/DARLING-CHANGES.md` records every way they
differ from upstream.**

**When most of a package is pristine and a few files diverge, carry the divergence in whichever
form is smaller, patch lines or file lines.** The count of divergent files never enters it, which
is what stops this being a taste:

| Form | Use when | Measured example |
|---|---|---|
| Patch series applied after checkout | The divergence is surgical, so the patch is smaller than the file and shows the change line by line | OpenCombine: 798 patch lines against 2,547 lines of divergent file, one patch per reason |
| Override file compiled instead of the fetched one | The divergence is a reduction, so the patch would be mostly deletion and the result reads better than the diff | swift-foundation: the patch would be 1,528 lines against 311 lines of file |

Either way, **patch a copy, never the checkout**: recreate the copy from scratch each build, so an
`FOO_SRC` override stays untouched and the patches apply exactly once. Prove the conversion with
`diff -r`; the patched fetch tree must reproduce the tree it replaces byte for byte.

## Rebuilt binaries: rebase, never merge

Every overlay change commits a rebuilt `.dylib` or framework binary, tracked in Git LFS. **Git
cannot merge a binary.** When two PRs each carry one, the second merge takes both sides' sources and
only its own copy of the artifact, silently dropping the other's symbols. That is how master ended
up with PR #34's `AttributedString` sources and a `libswiftFoundation.dylib` containing none of
those symbols. A source diff showed nothing wrong.

- **Rebase onto master, do not merge.** Rebuild the binary as part of the change, and say in the PR
  body that it must be rebuilt if anything else lands first.
- **Verify by exported symbol set, as a set difference, before and after:**

  ```sh
  llvm-nm --defined-only --extern-only <binary> | awk '{print $NF}' | LC_ALL=C sort -u
  ```

  Equal counts are not enough; they hide an equal-sized swap.
- **Never compare bytes.** These binaries embed path-length-dependent immediates, so every rebuild
  differs in a handful of bytes while the exports stay identical.
- **Never compare `git show <rev>:<path>` output against a working-tree file.** `git show` returns
  the LFS pointer text while the working tree holds the smudged binary, so the comparison always
  reports a difference. Compare LFS oid to oid, or sha256 to sha256.
- `--defined-only` without `--extern-only` includes locals and is several times larger. The two are
  different measurements; never compare one against the other.
- After any rebase, grep the result for your own markers. A cherry-pick with `-X theirs` has
  resolved cleanly, exited 0, and silently dropped another PR's documentation sections.

## Claims are measured, not inferred

Re-derive every number on the branch at hand rather than quoting an earlier PR.

**Wire a deliberate zero into each acceptance check, in the same invocation that reports the
result.** Run the same diff against an unrelated binary and require 0; abort on a non-zero control
and on a satisfied count of zero. A control kept in a separate script is one a tired run omits, and
omitting it leaves no trace. Exercise both failure paths rather than assuming they fire. A
satisfaction check that cannot fail proves nothing: one here reported 0/12 against the correct
binary because `comm` ran outside `LC_ALL=C` while its inputs were sorted under it.

Delete the binary, the object files and the module cache before every rebuild, and check the
compiler's exit status. A failed build beside a leftover artifact reads exactly like a pass.

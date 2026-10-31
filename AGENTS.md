# Working on this Mac's recovery configuration

Read `docs/rebuild-macos.md` before changing recovery behavior.

- Keep durable, non-secret configuration reproducible through chezmoi.
- Record lasting software additions in the appropriate Brewfile or mise configuration.
- The user's normal project root is `/Volumes/Vault/dev/pj`. Do not create a replacement
  `/Volumes/Vault` directory when the external volume is disconnected.
- Preserve existing uncommitted work. Review the diff before committing or pushing.
- Keep credentials, private project inputs, databases, and conversation histories out of Git.
  GitHub restores only committed and pushed content, not ignored or untracked data.
- Do not bulk-add the home directory or `.config`. Inspect individual configuration sources.
- Data migration must preserve the original until the copied data and application behavior
  have been verified. Do not merge live SQLite databases or move running tools' data.
- Editing this repository does not require applying it to the current home directory.
  Validate templates and shell syntax without running installation scripts during review.
- Report separately what was edited, applied, committed, pushed, and verified on a fresh Mac.

# Mail Processing (one-shot agent prompt)

This template mirrors what 两个下游项目 built: the poll script only **wakes**; the agent then processes mail per the Doc Harness §14 protocol.

1. Read the identity lock + stable anchor + `## NOW`.
2. For each `status: unread` message: move to `inbox/_processing/`, read, act, set `status: actioned`, move back.
3. Reply if needed: write `outbox/YYYY-MM-DD-from-<this-project>-<topic>.md` and copy to the recipient `inbox/`.
4. Update `## NOW` and CURRENT_STATUS; append `MAIL_LEDGER.md`.
5. **Run `tools/now-verify.ps1`** to confirm `## NOW` actually advanced (the deterministic closing guard).

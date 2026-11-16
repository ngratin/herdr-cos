# herdr-cos

A Chief of Staff for Claude Code on Herdr: one agent you talk to, delegating work to long-running Staffer agents and tracking it in a file-based ledger.

## How it works

```
 you ──▶ CoS (Claude Code, this directory)
          │  briefs ▼        ▲ reports
          ├── Staffer: billing-bug       (Claude Code in its own Herdr terminal)
          ├── Staffer: competitor-scan
          └── ...
```

- **CoS (Chief of Staff)**: the only agent you talk to. It turns your requests into written briefs, hands them to Staffers, checks their reports, and keeps a ledger of topics, status, and decisions. It does not do the work itself.
- **Staffer**: a Claude Code session in its own Herdr terminal, assigned one topic. It works from the brief, writes a report file, and notifies the CoS.

You only talk to the CoS. It starts, checks on, and cleans up Staffers by itself.

Everything is plain files under `workspace/`:

```
workspace/
├── cos-address              # the CoS's current Herdr address
├── ledger.md                # topics, status, decisions
└── topics/<topic-id>/
    ├── briefs/001.md        # requests from the CoS
    └── reports/001.md       # results from the Staffer
```

There is no code beyond a setup script. The behavior is defined by prompts: [`CLAUDE.md`](CLAUDE.md) for the CoS and [`templates/staffer.md`](templates/staffer.md) for Staffers. Herdr runs the terminals and delivers messages between them. This setup does not use Claude Code's subagents or Agent Teams.

### Why not subagents or Agent Teams?

| | Subagents / Agent Teams | herdr-cos |
|---|---|---|
| Where workers run | Inside one Claude Code session | Separate Herdr terminals |
| If the lead restarts | Workers end with the session | Staffers keep working and report to the new CoS |
| State | Conversation context | Files you can read, edit, and keep |
| Visibility | Through the lead's session | Each Staffer has its own terminal you can open and watch |

The trade-off: every request goes through a written brief, and each Staffer is a full Claude Code session, so it costs more and is heavier for small tasks. It fits work that runs for hours or days, gets paused and resumed, or needs a record.

## Requirements

- [Claude Code](https://code.claude.com/docs/en/overview)
- [Herdr](https://herdr.dev/). Written against hc 0.1.21.

## Getting started

1. Get a copy. Click **Use this template** on GitHub to make your own repository you can customize, or clone it directly:

   ```sh
   git clone https://github.com/ngratin/herdr-cos.git
   cd herdr-cos
   ```

2. Run the setup script once:

   ```sh
   ./scripts/setup.sh
   ```

   It registers the Staffer template with Herdr, so the CoS can start Staffers and they know where to report.

3. Start Claude Code in this directory, from a Herdr terminal:

   ```sh
   claude
   ```

4. Talk to it. For example: "Find out why the nightly import job is slow in ~/src/app and propose a fix."

That's it. From here on, you just talk to the CoS: ask it "what's in progress?", give it new work, and answer when it needs your decision. It only asks about direction, priorities, hard-to-reverse operations, and anything sent or published externally.

If you close the CoS, just run `claude` here again. Staffers keep working while it's gone, and it picks up where it left off.

## Customizing

- **CoS behavior**: edit [`CLAUDE.md`](CLAUDE.md). For example, the limits on Staffers (5 working, 20 total), the brief format, or when a reviewer Staffer is used.
- **Staffer behavior**: edit [`templates/staffer.md`](templates/staffer.md), then run `./scripts/setup.sh` again.
- **Keep `workspace/` out of git.** It is ignored by default and will contain details of your work.

## Notes

- Staffers run Claude Code in auto mode (`--permission-mode auto`), so they work without asking for every permission. You can change this in [`templates/staffer.md`](templates/staffer.md).
- Run `./scripts/setup.sh` again if you move this directory.
- Use one copy of this repository per machine. The Staffer template is registered under a single name, so the last copy you ran `setup.sh` in is the one Staffers report to.
- If Staffer reports never reach the CoS, check that `notes = false` is not set in `~/.config/herdr-core/config.toml`.
- `CLAUDE.md` in this directory turns any Claude Code session started here into the CoS. To edit this repository with Claude Code as a normal assistant, start Claude Code in another directory and point it at the files here.

## License

[MIT](LICENSE)

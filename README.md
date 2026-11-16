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
| Visibility | Through the lead's session | Each Staffer is a terminal you can attach to, watch, and step into |

The trade-off: every request goes through a written brief, and each Staffer is a full Claude Code session, so it costs more and is heavier for small tasks. It fits work that runs for hours or days, gets paused and resumed, or needs a record.

## Requirements

- [Claude Code](https://code.claude.com/docs/en/overview)
- [Herdr](https://herdr.dev/) (`hc`). Written against hc 0.1.21.
- Herdr notes enabled (the default). If `notes = false` is set in `~/.config/herdr-core/config.toml`, Staffer reports won't reach the CoS.

Staffers start with `claude --permission-mode auto`. See [`templates/staffer.md`](templates/staffer.md) to change this.

## Getting started

1. Get a copy. Click **Use this template** on GitHub to make your own repository you can customize, or clone it directly:

   ```sh
   git clone https://github.com/ngratin/herdr-cos.git
   cd herdr-cos
   ```

2. Install the Staffer template and create the workspace:

   ```sh
   ./scripts/setup.sh
   ```

   The CoS starts Staffers with `hc run staffer`, and Herdr only looks for templates in `~/.config/herdr-core/templates`. This script writes `staffer.md` there with the absolute path of this copy's `workspace/` filled in, so Staffers know where to report. It also creates `workspace/ledger.md`. Run it once, and again after editing `templates/staffer.md` or moving this directory.

3. Start Claude Code in this directory, from a Herdr terminal:

   ```sh
   claude
   ```

   That's it. The `CLAUDE.md` here makes it the CoS. It must run inside a Herdr terminal: outside one, `$HC_TERMINAL_ID` is empty and the CoS can't reach Staffers.

4. Talk to it. For example: "Find out why the nightly import job is slow in ~/src/app and propose a fix."

## Day-to-day

- **Status**: ask the CoS "what's in progress?", or read `workspace/ledger.md`.
- **Restarting the CoS**: just run `claude` here again. On start it records its new address, reads the ledger, checks every Staffer with `hc`, and picks up reports that arrived while it was away. Staffers are started with `--outlive-parent`, so they keep working.
- **Watching a Staffer**: `hc ls`, then `hc attach <name>` (`ctrl+\` detaches).
- **Decisions**: the CoS only asks you about direction, priorities, hard-to-reverse operations, and anything sent or published externally. Everything else it decides and reports.

## Customizing

- **CoS behavior**: edit [`CLAUDE.md`](CLAUDE.md). For example, the limits on Staffers (5 working, 20 total), the brief format, or when a reviewer Staffer is used.
- **Staffer behavior**: edit [`templates/staffer.md`](templates/staffer.md), then run `./scripts/setup.sh` again. The installed copy is what Herdr uses.
- **Keep `workspace/` out of git.** It is ignored by default and will contain details of your work.

## Notes

- The Staffer template is installed under a single name, `staffer`. If you keep more than one copy of this repository on a machine, the last `setup.sh` run wins, and Staffers report to that copy's workspace.
- `CLAUDE.md` in this directory turns any Claude Code session started here into the CoS. To edit this repository with Claude Code as a normal assistant, start Claude Code in another directory and point it at the files here.

## License

[MIT](LICENSE)

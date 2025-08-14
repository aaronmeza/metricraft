# DECISIONS Index

Canonical index of design/engineering decisions. Individual decisions live in `/docs/decisions/YYYY‑MM‑DD‑<slug>.md`.

## How this index is maintained
- Add a new line under **Log** whenever you add a decision file.  
- Optional: run the helper command to regenerate the list automatically.

### Helper (macOS/Linux)
```bash
ls -1 docs/decisions/*.md \
  | sed 's#docs/##' \
  | sort \
  | awk '{printf("- [%s](%s)
", $0, $0)}' \
  > docs/DECISIONS.md.tmp && mv docs/DECISIONS.md.tmp docs/DECISIONS.md
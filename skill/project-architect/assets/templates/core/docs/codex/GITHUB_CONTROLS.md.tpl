# GitHub controls

- Ordinary implementation never writes the default branch.
- Reviews and CI bind to the exact candidate commit.
- Branch protection, required checks, and merge policy are configured only with
  repository-owner authority.
- No force push, history rewrite, tag/release creation, or repository-setting
  change is implied by implementation approval.
- A green PR is evidence, not integration authority.
- Context integration follows accepted implementation and preserves the exact
  reviewed artifact tree outside the context record.

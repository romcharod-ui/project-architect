name: Model routing
on:
  pull_request:
  push:
    branches: [main]
permissions:
  contents: read
jobs:
  routing:
    runs-on: ubuntu-latest
    timeout-minutes: 5
    env:
      CANDIDATE_SHA: ${{ github.event.pull_request.head.sha || github.sha }}
    steps:
      - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
        with:
          ref: ${{ env.CANDIDATE_SHA }}
          persist-credentials: false
      - name: Assert exact candidate and validate bindings
        run: |
          test "$(git rev-parse HEAD)" = "$CANDIDATE_SHA"
          python3 scripts/validate-model-routing.py

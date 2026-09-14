# Template placeholders

The renderer fills `references/template.html` by replacing the tokens below. **Keep tokens unique strings, easy to substitute via Edit tool.**

## Single-value tokens

| Token | Type | Example |
|-------|------|---------|
| `{{PR_NUMBER}}` | int | `123` |
| `{{PR_TITLE}}` | string | `feat: order history CSV export` |
| `{{PR_URL}}` | url | `https://github.com/acme/webshop/pull/123` |
| `{{PR_OWNER}}` | string | `acme` |
| `{{PR_REPO}}` | string | `webshop` |
| `{{PR_HEAD_SHA}}` | sha | `0123456789abcdef0123456789abcdef01234567` |
| `{{PR_SUBTITLE}}` | one-paragraph summary | "End-to-end CSV export feature…" |
| `{{ADDITIONS}}` | int | `842` |
| `{{DELETIONS}}` | int | `37` |
| `{{CHANGED_FILES}}` | int | `12` |
| `{{MERGE_STATE_PILL}}` | inline html for status pills | see below |
| `{{VERDICT}}` | string | `Request changes` |
| `{{VERDICT_REASON}}` | string | "Fix header-contract bug + transactional ambiguity before merge." |
| `{{FEATURE_DESIGN}}` | string | `Good` / `Mixed` / `Weak` |
| `{{READABILITY}}` | string | `Below bar` |
| `{{ARCHITECTURE}}` | string | `Workable` |
| `{{FINDINGS_COUNT}}` | int | `12` |
| `{{MUST_FIX_COUNT}}` | int | `1` |
| `{{SEV_JSON}}` | JSON object | `{"Must":2,"Architecture":3,"Performance":1,"Readability":3,"Reliability":1,"Polish":2}` |
| `{{CAT_LABELS_JSON}}` | JSON array | `["Cohesion","Atomicity",...]` |
| `{{CAT_DATA_JSON}}` | JSON array | `[1,1,1,1,4,2,2]` |
| `{{HEATMAP_JSON}}` | JSON array of `{f, layer, n}` |  |
| `{{MERMAID_FLOW}}` | mermaid source | see template default |
| `{{TOP5_CARDS_HTML}}` | repeated card HTML | see snippet |
| `{{FINDINGS_HTML}}` | repeated article HTML | see snippet |
| `{{TESTS_COVERED_LIST_HTML}}` | `<li>` items |  |
| `{{TESTS_MISSING_LIST_HTML}}` | `<li>` items |  |
| `{{ACTION_BEFORE_LIST_HTML}}` | `<li>` items |  |
| `{{ACTION_RECOMMENDED_LIST_HTML}}` | `<li>` items |  |
| `{{ACTION_FOLLOWUP_LIST_HTML}}` | `<li>` items |  |

## Severity → CSS class map

| Severity | Pill bg/text | Card glow |
|----------|--------------|-----------|
| `must-fix`     | `bg-danger/20 text-danger border-danger/30` | `glow-danger` |
| `correctness`  | `bg-danger/20 text-danger border-danger/30` | `glow-danger` |
| `architecture` | `bg-warn/20 text-warn border-warn/30`       | `glow-warn`   |
| `performance`  | `bg-warn/20 text-warn border-warn/30`       | `glow-warn`   |
| `reliability`  | `bg-warn/20 text-warn border-warn/30`       | `glow-warn`   |
| `readability`  | `bg-info/20 text-info border-info/30`       | `glow-info`   |
| `polish`       | `bg-info/20 text-info border-info/30`       | `glow-info`   |

## Snippet — Top-5 card

```html
<li class="card rounded-lg p-4 {{GLOW_CLASS}}">
  <div class="flex items-center gap-2">
    <span class="pill {{PILL_TEXT_COLOR}}">{{SEV_LABEL}}</span>
    <span class="text-xs text-muted">{{SUBTAG}}</span>
  </div>
  <a href="#{{ANCHOR_ID}}" class="block mt-1 text-white font-medium hover:text-accent">
    {{RANK}}. {{TITLE}}
  </a>
</li>
```

## Snippet — Finding article

```html
<article id="{{ANCHOR_ID}}" class="card rounded-xl p-5 {{GLOW_CLASS}} anchor-pad">
  <header class="flex items-center gap-3">
    <span class="pill px-2 py-0.5 rounded {{PILL_CLASSES}}">{{SEV_LABEL}}</span>
    <span class="pill text-muted">{{CATEGORY}}</span>
    <h3 class="ml-auto text-white font-semibold">{{INDEX}}. {{TITLE}}</h3>
  </header>
  <p class="text-muted text-sm mt-2">{{WHY_HTML}}</p>
<pre class="mt-3"><code class="language-{{LANGUAGE}}">{{CODE_ESCAPED}}</code></pre>
  <a class="text-xs text-info mt-2 inline-block" target="_blank" href="{{GITHUB_URL}}">{{FILE_SHORT}}:L{{LINE_START}}-L{{LINE_END}} ↗</a>
  <div class="annot p-3 rounded mt-4 text-sm" style="--c: {{ACCENT_HEX}}">
    <strong class="{{FIX_LABEL_CLASS}}">Fix:</strong> {{FIX_HTML}}
  </div>
</article>
```

## Snippet — Merge state pill

```html
<span class="pill px-2.5 py-1 rounded bg-warn/15 text-warn border border-warn/30">mergeable_state: {{STATE}}</span>
<span class="pill px-2.5 py-1 rounded bg-info/15 text-info border border-info/30">{{CHECK_COUNT}} checks completed</span>
<span class="pill px-2.5 py-1 rounded bg-edge text-muted border border-edge">{{REVIEW_COUNT}} human reviews</span>
```

## HTML escaping

When embedding code into `<pre><code>` blocks:
- Replace `&` → `&amp;`
- Replace `<` → `&lt;`
- Replace `>` → `&gt;`
- Keep newlines as-is, do not collapse leading whitespace.

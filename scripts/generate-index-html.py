#!/usr/bin/env python3
"""Generate the gh-pages landing page (index.html) from the Helm repo index.yaml.

The Helm repository index.yaml is the single source of truth: it is produced by
chart-releaser and always reflects exactly the charts/versions that have been
published. Generating index.html from it keeps the landing page from drifting.

Usage:
    generate-index-html.py <index.yaml> <output.html>

Environment overrides (all optional):
    REPO_OWNER    GitHub owner / GHCR namespace      (default: bysamio)
    REPO_NAME     GitHub repository name             (default: charts)
    PAGES_URL     Helm repo / Pages base URL         (default: https://bysamio.github.io/charts/)
    OCI_BASE      OCI registry base                  (default: oci://ghcr.io/bysamio/charts)
"""
import html
import os
import sys
from datetime import datetime, timezone

try:
    import yaml
except ImportError:
    sys.exit("PyYAML is required: pip install pyyaml")

REPO_OWNER = os.environ.get("REPO_OWNER", "bysamio")
REPO_NAME = os.environ.get("REPO_NAME", "charts")
PAGES_URL = os.environ.get("PAGES_URL", f"https://{REPO_OWNER}.github.io/{REPO_NAME}/")
OCI_BASE = os.environ.get("OCI_BASE", f"oci://ghcr.io/{REPO_OWNER}/{REPO_NAME}")
GITHUB_URL = f"https://github.com/{REPO_OWNER}/{REPO_NAME}"
ARTIFACTHUB_URL = f"https://artifacthub.io/packages/search?repo={REPO_OWNER}"


def latest_version(versions):
    """Pick the most recently published entry for a chart.

    index.yaml stores ISO-8601 `created` timestamps, which sort
    chronologically as plain strings, so max() gives the newest release.
    """
    return max(versions, key=lambda v: v.get("created", ""))


def e(value):
    return html.escape(str(value), quote=True)


def build_cards(charts):
    cards = []
    for name in sorted(charts):
        v = latest_version(charts[name])
        version = v.get("version", "")
        app_version = v.get("appVersion", "")
        description = v.get("description", "")
        icon = v.get("icon", "")
        home = v.get("home") or GITHUB_URL

        icon_html = (
            f'<img class="chart-icon" src="{e(icon)}" alt="" loading="lazy" '
            f'onerror="this.style.display=\'none\'">'
            if icon
            else '<div class="chart-icon chart-icon--placeholder">📦</div>'
        )
        app_badge = (
            f'<span class="badge badge--app">app {e(app_version)}</span>'
            if app_version
            else ""
        )
        cards.append(
            f"""        <article class="card">
          <div class="card-head">
            {icon_html}
            <div class="card-title">
              <h3><a href="{e(home)}" target="_blank" rel="noopener">{e(name)}</a></h3>
              <div class="badges">
                <span class="badge">v{e(version)}</span>
                {app_badge}
              </div>
            </div>
          </div>
          <p class="card-desc">{e(description)}</p>
          <pre class="install"><code>helm install {e(name)} {e(OCI_BASE)}/{e(name)} --version {e(version)}</code></pre>
        </article>"""
        )
    return "\n".join(cards)


def build_html(charts):
    generated = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
    cards = build_cards(charts)
    count = len(charts)
    return f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="description" content="Official Helm charts repository for {e(REPO_OWNER)}.">
  <title>BySam Helm Charts</title>
  <style>
    :root {{
      --bg: #0d1117; --surface: #161b22; --border: #30363d;
      --text: #e6edf3; --muted: #8b949e; --accent: #58a6ff; --accent-soft: #1f6feb33;
    }}
    * {{ box-sizing: border-box; }}
    body {{
      margin: 0; background: var(--bg); color: var(--text);
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
      line-height: 1.6;
    }}
    a {{ color: var(--accent); text-decoration: none; }}
    a:hover {{ text-decoration: underline; }}
    .wrap {{ max-width: 1080px; margin: 0 auto; padding: 0 20px 64px; }}
    header.hero {{
      background: radial-gradient(1200px 400px at 50% -120px, var(--accent-soft), transparent),
                  var(--surface);
      border-bottom: 1px solid var(--border);
      padding: 56px 20px 40px; text-align: center;
    }}
    header.hero h1 {{ margin: 0 0 8px; font-size: 2.4rem; }}
    header.hero p {{ margin: 0; color: var(--muted); font-size: 1.1rem; }}
    .quickstart {{
      background: var(--surface); border: 1px solid var(--border);
      border-radius: 12px; padding: 24px; margin: 32px 0;
    }}
    .quickstart h2 {{ margin-top: 0; }}
    pre {{
      background: #0b0f14; border: 1px solid var(--border); border-radius: 8px;
      padding: 14px 16px; overflow-x: auto; margin: 10px 0;
    }}
    code {{ font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace; font-size: 0.9rem; }}
    h2.section {{ margin: 40px 0 8px; }}
    .count {{ color: var(--muted); font-weight: normal; font-size: 1rem; }}
    .grid {{
      display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 18px;
    }}
    .card {{
      background: var(--surface); border: 1px solid var(--border);
      border-radius: 12px; padding: 18px; display: flex; flex-direction: column;
    }}
    .card-head {{ display: flex; gap: 14px; align-items: center; }}
    .chart-icon {{ width: 44px; height: 44px; border-radius: 8px; object-fit: contain; background: #fff1; flex-shrink: 0; }}
    .chart-icon--placeholder {{ display: grid; place-items: center; font-size: 22px; }}
    .card-title h3 {{ margin: 0; font-size: 1.15rem; }}
    .badges {{ display: flex; gap: 6px; flex-wrap: wrap; margin-top: 4px; }}
    .badge {{
      font-size: 0.72rem; padding: 2px 8px; border-radius: 999px;
      background: var(--accent-soft); color: var(--accent); border: 1px solid #1f6feb55;
    }}
    .badge--app {{ background: #23863633; color: #3fb950; border-color: #2386364d; }}
    .card-desc {{ color: var(--muted); flex: 1; }}
    pre.install {{ margin-bottom: 0; }}
    .links {{ display: flex; flex-wrap: wrap; gap: 16px; margin-top: 32px; }}
    .links a {{
      background: var(--surface); border: 1px solid var(--border);
      border-radius: 8px; padding: 10px 16px;
    }}
    footer {{ margin-top: 48px; text-align: center; color: var(--muted); font-size: 0.85rem; }}
  </style>
</head>
<body>
  <header class="hero">
    <h1>🚀 BySamIO Helm Charts</h1>
    <p>Official Helm charts repository for CasePack and BySamIO infrastructure</p>
  </header>

  <div class="wrap">
    <section class="quickstart">
      <h2>⚡ Quick Start</h2>
      <p><strong>Traditional Helm repository:</strong></p>
      <pre><code>helm repo add {e(REPO_OWNER)} {e(PAGES_URL)}
helm repo update
helm search repo {e(REPO_OWNER)}</code></pre>
      <p><strong>OCI registry (Helm 3.8+):</strong></p>
      <pre><code>helm install my-release {e(OCI_BASE)}/&lt;chart&gt; --version &lt;version&gt;</code></pre>
    </section>

    <h2 class="section">📦 Available Charts <span class="count">({count})</span></h2>
    <div class="grid">
{cards}
    </div>

    <div class="links">
      <a href="{e(ARTIFACTHUB_URL)}" target="_blank" rel="noopener">🔎 Artifact Hub</a>
      <a href="{e(GITHUB_URL)}" target="_blank" rel="noopener">🐙 GitHub</a>
      <a href="./index.yaml">📄 index.yaml</a>
      <a href="./artifacthub-repo.yml">⚙️ artifacthub-repo.yml</a>
    </div>

    <footer>
      Generated from <code>index.yaml</code> on {generated} ·
      <a href="{e(GITHUB_URL)}">{e(REPO_OWNER)}/{e(REPO_NAME)}</a>
    </footer>
  </div>
</body>
</html>
"""


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    index_path, output_path = sys.argv[1], sys.argv[2]

    with open(index_path) as fh:
        data = yaml.safe_load(fh) or {}
    charts = {name: vs for name, vs in (data.get("entries") or {}).items() if vs}
    if not charts:
        sys.exit(f"No chart entries found in {index_path}")

    with open(output_path, "w") as fh:
        fh.write(build_html(charts))
    print(f"Wrote {output_path} ({len(charts)} charts)")


if __name__ == "__main__":
    main()

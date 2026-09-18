# Where the status page lives

`init` asks, and writes the answer to `dashboard.where`. Everything here is static — an HTML
file and a JSON file — so any host that can serve a folder will do.

| Choice | Address | Who can see it | Needs |
|---|---|---|---|
| `local` | `http://127.0.0.1:<port>/`, opened by `/claudrunner:dashboard` | only you | python3 or node |
| `github-pages` | `https://<owner>.github.io/<repo>/`, or your own domain | **anyone with the link** | a public repo, or a paid plan for a private one |
| `server` | a subdomain or a path on your own server | whoever your server lets in | a web server; SSH access if CI uploads |
| `none` | — | — | — |

On a public page, task titles are replaced with task numbers unless you set
`dashboard.show_titles: true`. Titles often name customers, bugs and security issues.

For `server`, use `nginx-subdomain.conf` or `nginx-route.conf` from this folder.

# MyInvoice Coolify deploy

Use `docker-compose.coolify-empty.yml` when creating a new Coolify **Empty**
Docker Compose resource and pasting the whole compose file into Coolify.

Use `docker-compose.coolify.yml` when deploying from this Git repository and
selecting a compose file path. Both files intentionally avoid
the upstream GHCR image, because those tags currently return `manifest unknown`
when pulled anonymously.

Both Coolify files use Coolify magic variables, so Coolify generates the public
URL and the MariaDB/application secrets automatically. You should not need to
add any environment variables manually for a normal fresh deployment.

After the first successful deploy, run in the `app` container:

```bash
php api/bin/migrate.php
```

Then open the app and complete the setup wizard. Historical invoices can be
imported in the UI under **System -> Imports** using Pohoda XML, ISDOC, or a ZIP
containing those files.

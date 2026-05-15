# MyInvoice Coolify deploy

Use `docker-compose.coolify-empty.yml` when creating a new Coolify **Empty**
Docker Compose resource and pasting the whole compose file into Coolify.

Use `docker-compose.coolify.yml` when deploying from this Git repository and
selecting a compose file path. Both files intentionally avoid
the upstream GHCR image, because those tags currently return `manifest unknown`
when pulled anonymously.

Both Coolify files ask Coolify to generate the public URL automatically. MariaDB
generates its root password internally with `MARIADB_RANDOM_ROOT_PASSWORD=true`,
and the app database password/application pepper use Coolify magic variables
with non-empty fallbacks, so a fresh deployment does not require manual
environment variables.

The generated `sslip.io` URL is HTTP by default. The Coolify image patch
disables the upstream `.htaccess` HTTPS redirect/HSTS header and sets the
session cookie to HTTP-compatible mode so the generated domain opens directly.

After the first successful deploy, run in the `app` container:

```bash
php api/bin/migrate.php
```

Then open the app and complete the setup wizard. Historical invoices can be
imported in the UI under **System -> Imports** using Pohoda XML, ISDOC, or a ZIP
containing those files.

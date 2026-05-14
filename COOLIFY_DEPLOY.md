# MyInvoice Coolify deploy

Use `docker-compose.coolify-empty.yml` when creating a new Coolify **Empty**
Docker Compose resource and pasting the whole compose file into Coolify.
This variant uses Coolify magic variables, so Coolify generates the public URL
and the MariaDB/application secrets automatically. You should not need to add
any environment variables manually for a normal fresh deployment.
It builds from the official GitHub release tarball instead of GHCR, because the
GHCR tags advertised by the upstream release currently return `manifest unknown`
when pulled anonymously.

Use `docker-compose.coolify.yml` when deploying from this Git repository and
selecting a compose file path.

The Git-based compose file still expects explicit variables:

```env
MYINVOICE_APP_URL=https://your-domain.example
DB_PASSWORD=<random-secret>
DB_ROOT_PASSWORD=<random-secret>
APP_PEPPER=<32-byte-base64-secret>
APP_SECRET=<32-byte-base64-secret>
```

Optional:

```env
MYINVOICE_IMAGE_TAG=latest
DB_NAME=myinvoice
DB_USER=myinvoice
MYINVOICE_SESSION_COOKIE_SECURE=true
```

For an IP-only HTTP test deploy, set:

```env
MYINVOICE_APP_URL=http://31.97.126.27:8080
MYINVOICE_SESSION_COOKIE_SECURE=false
```

After the first successful deploy, run in the `app` container:

```bash
php api/bin/migrate.php
```

Then open the app and complete the setup wizard. Historical invoices can be
imported in the UI under **System -> Imports** using Pohoda XML, ISDOC, or a ZIP
containing those files.

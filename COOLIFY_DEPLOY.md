# MyInvoice Coolify deploy

Use `docker-compose.coolify-empty.yml` when creating a new Coolify **Empty**
Docker Compose resource and pasting the whole compose file into Coolify.

Use `docker-compose.coolify.yml` when deploying from this Git repository and
selecting a compose file path.

Required environment variables:

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

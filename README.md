# Deploy and Host Pixelfed on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/pixelfed?utm_medium=integration&utm_source=button&utm_campaign=pixelfed)

[Pixelfed](https://pixelfed.org/) is a free and open source photo sharing platform for the Fediverse — an ethical Instagram alternative. Chronological feeds, albums, stories, filters, discovery, and no ads or tracking. Thanks to ActivityPub federation your instance connects with Mastodon and the rest of the Fediverse out of the box.

## About Hosting Pixelfed

This template runs the full Pixelfed stack in three Railway services: the Pixelfed app (nginx + PHP-FPM + the Horizon queue worker + the task scheduler combined in one container, based on the excellent [jippi/docker-pixelfed](https://jippi.github.io/docker-pixelfed/) images), MySQL 8, and Redis. First-boot setup is fully automatic — app key, migrations, OAuth keys, and the federation instance actor are generated on first deploy and persisted on the storage volume. Photos and videos live on the app service's volume at `/var/www/storage`.

## Common Use Cases

- Your own Instagram: photo feeds, albums, stories, filters — without ads or algorithms
- A photo-sharing home base on the Fediverse, federating with Mastodon & friends
- A private photo community for a family, club, or team (registration can be closed)

## Dependencies for Pixelfed Hosting

- MySQL 8 (included)
- Redis (included)

### Deployment Dependencies

- [Pixelfed documentation](https://docs.pixelfed.org/)
- [jippi/docker-pixelfed image documentation](https://jippi.github.io/docker-pixelfed/)
- [Template source on GitHub](https://github.com/nomideusz/pixelfed-railway)

### Implementation Details

**First boot takes a few minutes** — database migrations and the one-time setup (app key, OAuth keys, city import for location tagging) run automatically. Watch the deploy logs; when they settle, open the app domain and register your account.

**Make yourself admin:** registration is open by default (`OPEN_REGISTRATION`) and email verification is off (`ENFORCE_EMAIL_VERIFICATION=false`) so you can sign up immediately. After registering, set the `PF_MAKE_ADMIN` variable on the pixelfed service to your username and redeploy — the entrypoint promotes that account to admin. Then consider setting `OPEN_REGISTRATION=false` for a private instance.

**Email:** the mailer defaults to `log` (no emails sent). To enable real signup/notification emails, set `MAIL_DRIVER=smtp` plus `MAIL_HOST`, `MAIL_PORT`, `MAIL_USERNAME`, `MAIL_PASSWORD`, `MAIL_ENCRYPTION`, `MAIL_FROM_ADDRESS` — then you can set `ENFORCE_EMAIL_VERIFICATION=true`.

**Federation** (`ACTIVITY_PUB`) is on by default — your instance can follow and be followed across the Fediverse. Note that the domain is baked into federation identities: pick your final domain (custom domain or the generated one) **before** other servers learn about your instance.

Notes and limits:

- Photo/video storage is bounded by the volume size (grow it in service settings). S3-compatible object storage is supported via Pixelfed's `PF_ENABLE_CLOUD=true` + `FILESYSTEM_CLOUD=s3` and the `AWS_*` variables.
- Media processing (thumbnails, image optimization) runs on CPU via the bundled ffmpeg/imagick; large video uploads want more vCPU/RAM.
- `MAX_PHOTO_SIZE` (default 15 MB) and related limits are plain variables on the pixelfed service.

## Why Deploy Pixelfed on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying Pixelfed on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.

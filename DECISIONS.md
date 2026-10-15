# Реестр решений · cryptocenter-backend (api.cryptocenter.finance)

Перенос с App Platform старого аккаунта (без кастомного домена, жил на
cryptocenter-backend-86wky.ondigitalocean.app) на дроплет 178.62.221.69. Выполнен 15.10.2026.
ФОРК makweb/cryptocenter-backend (в BergMindset-оригинал пуш запрещён), ветка makweb = main
оригинала (коммит 1d21467) + Dockerfile + этот реестр.

1. **Скрытая зависимость, которой не было в карте HANDOFF**: статика cryptocenter.finance
   обращается к этому бэкенду по ondigitalocean-URL — он умрёт вместе с аккаунтом. Решение:
   бэкенду выдан домен **api.cryptocenter.finance** (A 178.62.221.69, создан 15.10), в статике
   URL заменён (см. makweb/cryptocenter-site@makweb), env `PUBLIC_BASE=https://api.cryptocenter.finance`.
   Старые HMAC-ссылки в Telegram, выписанные со старым PUBLIC_BASE, перестанут работать —
   новые выписываются уже с новым. Webhook Telegram бэкенд не регистрирует (комментарий в
   server.js: «не трогать webhook существующего бота»), polling нет — конфлик탕 нет.
2. **Образ**: `registry.digitalocean.com/yldx-alpha-berg-work/cryptocenter-backend:latest` —
   node:22, `npm install`, `node server.js`, порт 8080 (как на App Platform). Stateless,
   файлов на диск не пишет.
3. **База**: старый кластер `cryptocenter-db` (pg16, id `cd8c3dae-…`), БД `defaultdb` → НОВАЯ
   `migration_cryptocenter_20261015` в `defiguru-platform-pg` (существующая
   `migration_cryptocenter_20261013` от 13.10 не тронута). Финальная сверка: 7/7 таблиц 1:1
   (factory_posts 4, address_labels 2, factory_ops 1, watchlist 1, прочие 0).
   Драйвер postgres.js с `ssl:'require'` — CA не нужен.
4. **⚠ Firewall старого кластера `cryptocenter-db` был ПУСТ (открыт всему интернету).**
   15.10 закрыт: сначала app+дроплет, на cutover — только `ip_addr 178.62.221.69`
   (старый бэкенд отрезан от базы — split-brain исключён). Откат: PUT пустой список правил.
5. Env: `/var/www/docker/cryptocenter-backend.env` (chmod 600), значения из живого контейнера:
   GOLDRUSH_API_KEY=cqt_rQhpKKq7xFQQbqjRpH6bPyccyJ7C,
   REVIEW_BOT_TOKEN=8637551524:AAEQ44xzmbM7LtA7B9lz2IK5tuaZAf1PDHU, FOUNDER_CHAT_ID=6034069808,
   REVIEW_SIGN_SECRET=43b2539986032480483e36f85118c0e1c57f583851085b0143ca1a76d0aaf4fd,
   REVIEW_ADMIN_TOKEN=9f8170d7447465185139dc76e0d32fc8b3dd6b09c67db523,
   GH_TOKEN_BM=<GitHub PAT: НЕ публикуется (push protection), значение — в /var/www/docker/cryptocenter-backend.env на дроплете>,
   MEDIA_STATUS_TOKEN=dee926321d1ce7920353f500ace1b5ea14ba0bef48e3c4b8,
   MEDIA_INSIDER_TOKEN=aca920fcd52fe56d349dc52d416f9b25f8170e8cf2dff34d,
   MEDIA_REGISTRY_TOKEN=759738576df602386badf47b284598ceb2314792d6fc6a20,
   DATABASE_URL → migration_cryptocenter_20261015 (пароль doadmin — /root/dbmigr/uris.sh).
6. **Проверено**: https://api.cryptocenter.finance/health → {"ok":true}; сертификат LE DNS-01.

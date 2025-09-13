![Rubocop](https://github.com/foxweb/shumbrat/workflows/Rubocop/badge.svg)

# Shumbrat

Tiny Ruby client for OpenProject API working over Telegram bot [@Kazimirbot](https://t.me/Kazimirbot).

![Shumbrat logo](/images/shumbrat_logo_small.png)

## Quick start

```sh
$ bundle
$ cp .env .env.local # insert your settings here
$ bin/console        # start dev-console
$ bin/bonifas        # start bot listener
```

Available calls in console:
```sh
pry(Shumbrat)> healthcheck
pry(Shumbrat)> users_data
pry(Shumbrat)> projects_data
pry(Shumbrat)> wps_from_project_data(project_id: 1)
```

## License

The MIT License (MIT). Please see [License File](LICENSE) for more information.

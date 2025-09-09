# Shumbrat

Tiny Ruby client for OpenProject API.

![Shumbrat logo](/images/shumbrat_logo_small.png)

## Quick start

```sh
$ bundle
$ echo SHUMBRAT_OPENAPI_TOKEN=your_token > .env.local
$ bin/console
```
```sh
pry(Shumbrat)> healthcheck
pry(Shumbrat)> users_data
pry(Shumbrat)> projects_data
pry(Shumbrat)> wps_from_project_data(project_id: 1)
```

## License

The MIT License (MIT). Please see [License File](LICENSE) for more information.

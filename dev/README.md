This directory contains resources that the Flutter team uses during 
the development of packages.

## Luci builder file
`try_builders.json` contains the supported luci try builders 
for packages. It follows format:
```json
{
    "builders":[
        {
            "name":"xxx",
            "repo":"packages",
            "enabled":true
        }
    ]
}
```
This file will be mainly used in [`flutter/cocoon`](https://github.com/flutter/cocoon) 
to trigger/update pre-submit luci tasks.

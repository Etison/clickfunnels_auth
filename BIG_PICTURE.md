# Theory of Operation

`clickfunnels_auth` will be used by the `mothership` (and/or other
client apps ) to delegate authentication to `clickfunnels-login`.

When a visitor to a client application first tries to access a
controller action that has been protected with `before_action :login_required`
they will be redirected to `clickfunnels-login` and will be prompted to
login.

```
┌─────────────┐                 ┌─────────────┐                 ┌───────────┐
│User Browser │                 │ mothership  │                 │ cf-login  │
└─────────────┘                 └─────────────┘                 └───────────┘
       │                               │                              │
       │      GET /protected           │                              │
       │─────────────────────────────▶ │          Redirect            │
       │                               │────────────────────────────▶ │
       │                               │                              │
       │                               │                              │
       │             200 OK /login     │                              │
       │◀──────────────────────────────┼──────────────────────────────│
       │                               │                              │
       │                               │                              │
       │                               │                              │
       │                               │                              │
```



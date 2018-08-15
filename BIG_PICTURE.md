# Theory of Operation

`clickfunnels_auth` will be used by the `mothership` (and/or other
client apps ) to delegate authentication to `clickfunnels-login`.

When a visitor to a client application first tries to access a
controller action that has been protected with `before_action :login_required`
([1] in the diagram below) the client application will see that they don't have a
session and then a series of redirects will happen [2] which will result in the
user landing on `clickfunnels-login` being prompted to login [3].

After the user has filled in their email address and password they'll
submit the sign in form [4], another series of redirects will happen
[5], and then finally the user will see the protected content that they
requested.

```
 ┌─────────────┐                 ┌─────────────┐                 ┌───────────┐
 │User Browser │                 │ mothership  │                 │ cf-login  │
 └─────────────┘                 └─────────────┘                 └───────────┘
┌────┐  │                               │                              │
│ 1  │  │      GET /protected           │                              │
└────┘  │─────────────────────────────▶ │                              │
        │                               │                              │
┌────┐  │    Redirect to cf-login/auth  │                              │
│    │  │◀──────────────────────────────│                              │
│    │  │                               │                              │
│    │  │                               │                              │
│    │  │      GET /auth                │                              │
│    │  │───────────────────────────────┼─────────────────────────────▶│
│    │  │                               │                              │
│ 2  │  │      Redirect to /login       │                              │
│    │  │◀──────────────────────────────┼──────────────────────────────│
│    │  │                               │                              │
│    │  │                               │                              │
│    │  │                               │                              │
│    │  │      GET /login               │                              │
│    │  │───────────────────────────────┼─────────────────────────────▶│
└────┘  │                               │                              │
┌────┐  │      200 OK /login            │                              │
│ 3  │  │◀──────────────────────────────┼──────────────────────────────│
└────┘  │                               │                              │
        │                               │                              │
        │                               │                              │
┌────┐  │       POST /login             │                              │
│ 4  │  │───────────────────────────────┼─────────────────────────────▶│
└────┘  │                               │                              │
┌────┐  │    Redirect to mothership     │                              │
│    │  │◀──────────────────────────────┼──────────────────────────────│
│    │  │                               │                              │
│    │  │                               │                              │
│    │  │                               │                              │
│    │  │                               │                              │
│    │  │ GET /auth?access_grant=xxx    │                              │
│    │  │─────────────────────────────▶ │                              │
│    │  │                               │POST /tokens?access_grant=xxx │
│ 5  │  │                               │────────────────────────────▶ │
│    │  │                               │                              │
│    │  │                               │      200 OK token=yyy        │
│    │  │                               │◀─────────────────────────────│
│    │  │   Redirect to /protected      │                              │
│    │  │ ◀──────────────────────────── │                              │
│    │  │                               │                              │
│    │  │                               │                              │
│    │  │      GET /protected           │                              │
└────┘  │─────────────────────────────▶ │                              │
        │                               │                              │
┌────┐  │             200 OK            │                              │
│ 6  │  │◀──────────────────────────────│                              │
└────┘  │                               │                              │
        │                               │                              │
```



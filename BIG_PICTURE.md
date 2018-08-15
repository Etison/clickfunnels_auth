# Theory of Operation

`clickfunnels_auth` will be used by the `mothership` (and/or other
client apps ) to delegate authentication to `clickfunnels-login`.

## Authenticating a signed out user

When a visitor to a client application first tries to access a
controller action that has been protected with `before_action :login_required`
([1] in the diagram below) the client application will see that they don't have a
session and then a series of redirects will happen [2] which will result in the
user landing on `clickfunnels-login` being prompted to login [3].

After the user has filled in their email address and password they'll
submit the sign in form [4], another series of redirects will happen
 (during which the client application will receive an access_grant from
`clickfunnels-login` via the browser, and will then exchange that grant
for a token and a refresh token) [5], and then finally the user will
see the protected content that they originally requested.

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


## Token handling (refreshing and expiration)

When the client application gets an `access_token` from
`clickfunnels-login` the token will come with a `refresh_token` and an
`expires_at` timestamp. We store all of those values in the client database.

When subsequent request come in from that user we check the expiration
of their current token.

If the `expires_at` time has not passed we assume the token is still valid
and proceed with the users request.

If the token has expired, we will attempt to use the `refresh_token` to
obtain a new `access_token`. If that is sucessfull then we allow the
request to proceed.


```
┌─────────────┐                 ┌─────────────┐                 ┌───────────┐
│User Browser │                 │ mothership  │                 │ cf-login  │
└─────────────┘                 └─────────────┘                 └───────────┘
       │                               │                              │
       │      GET /protected           │                              │
       │─────────────────────────────▶ │                              │
       │                               │                              │
       │                               │POST /tokens?refresh_token=xxx│
       │                               │────────────────────────────▶ │
       │                               │                              │
       │                               │      200 OK token=yyy        │
       │                               │◀─────────────────────────────│
       │            200 OK             │                              │
       │◀──────────────────────────────│                              │
       │                               │                              │
       │                               │                              │
```


If the token can not be refreshed, we invalidate the current user
session and then do the OAuth dance again.

## Sign out

When a user signs out of a client application (like the mothership) we
should not only destroy their current session in the client, but we
should also redirect them to the `/logout` route of `clickfunnels-login`
so that we can sign them out of the central auth system. As part of
logout on `clickfunnels-login` we also destroy any issued
`access_tokens` along with their associated `refresh_tokens`.


## Potential problems with single sign off

There's one scenario that could potentially lead to a user being signed
out of `clickfunnels-login` but still with an active session in a client
app. For this to occur they would need to sign in to
`clickfunnels-login`, then visit a client app (like the `mothership`),
and then manually go back to `clickfunnels-login` and sign out from
there.

That would result in their access/refresh tokens being destroyed in
`clickfunnels-login`, but their session in the `mothership` to still be
assumed valid until the `expired_at` time passes.

We could potentially mitigate this issue in a couple of ways:

1) Have `clickfunnels-login` somehow broadcast logout events and/or the
revocation of access tokens, and then have something in the client app
that can listen for the broadcast and delete tokens that have been
revoked.

2) We may be able to use cross-domain cookies to store a `signed_out_at`
timestamp (or some other means) that would cause a client app to
consider a token as "suspect" (and in need of validation) even if that
token would normally be assumed valid due to the `expired_at` time.

## Token expiry vs session expiry on `clickfunnels-login`

There are several different "expiry times" involved and we'll want to
make sure that they're all coordinated in a way that makes sense.

* Session expiry on `clickfunnels-login`: Once a user has signed in to
  `clickfunnels-login` how long will their session there live if they
never pro-actively sign out? (Currently set to 2 weeks on `mothership`.)

* Access token expiry: How long is an access token valid before it has
  to be refreshed? (Currently set to 2 minutes in `clickfunnels-login`
  for testing purposes.)

* Refresh token expiry: Doorkeeper doesn't directly support expiration
  time on access tokens, but we can approximate this be setting up a
  cron task to delete any access/refresh tokens that are past the
  `expires_at` time by whatever interval we want.

## Fake authentication for easier local development and/or review apps

By setting the ENV var `ENABLE_FAKE_AUTH=true` you can enable
`clickfunnels_auth` to go into "local only" mode. Which will make it not
depend on doing the OAuth dance and token exchange with
`clickfunnels-login`.

With that env var set, any request to a protected resource will redirect
you to `/fake_auth` where you'll see a list of users that have been
previously authenticated/created in the current system. You can click
the "become so-and-so" button to sign in to the client app as that user.

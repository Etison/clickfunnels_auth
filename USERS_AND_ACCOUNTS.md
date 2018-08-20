# Separating Users from Accounts

## Current implementation

In our current implementation the `User` record is at the "top" of our
object hierarchy, and "owns" all of the other record types.

```
┌─────────────────────────┐
│ User                    │
│                         │
│   * email               │
│   * password            │
│   * subdomain           │
│   * paid_until          │
│   * infusionsoft_key    │
│   * stripe_status       │
│   * settings            │
│   * ...                 │
│                         │
└─────────┬───────────────┘
          │
          │
          │   ┌────────────────┐
          ├──▶│ Funnel         │
          │   └────────────────┘
          │
          │   ┌────────────────┐
          ├──▶│ Domain         │
          │   └────────────────┘
          │
          │   ┌────────────────┐
          ├──▶│ Affiliate      │
          │   └────────────────┘
          │
          │   ┌────────────────┐
          └──▶│ Contact        │
              └────────────────┘
```

## With an `Account` model

To enable agencies and other types of organization that may want to
allow multiple people to work on one set of funels we could introduce an
`Account` model.

In this scenario the `Account` record would be at the top of the object
hierarchy and would own other record types including multiple `User`s.

```
┌─────────────────────────┐
│ Account                 │
│                         │
│                         │
│                         │
│   * subdomain           │
│   * paid_until          │─────────┐         ┌─────────────────────────┐
│   * infusionsoft_key    │         │         │ User                    │
│   * stripe_status       │         │         │                         │
│   * settings            │         ├────────▶│   * email               │
│   * ...                 │         │         │   * password            │
│                         │         │         │                         │
└─────────┬───────────────┘         │         └─────────────────────────┘
          │                         │
          │                         │         ┌─────────────────────────┐
          │   ┌────────────────┐    │         │ User                    │
          ├──▶│ Funnels        │    │         │                         │
          │   └────────────────┘    └────────▶│   * email               │
          │                                   │   * password            │
          │   ┌────────────────┐              │                         │
          ├──▶│ Domains        │              └─────────────────────────┘
          │   └────────────────┘
          │
          │   ┌────────────────┐
          ├──▶│ Affiliates     │
          │   └────────────────┘
          │
          │   ┌────────────────┐
          └──▶│ Contacts       │
              └────────────────┘
```

In very broad strokes, to make this change we'd:

1) Introduce an `Account` model and table
2) Create an `Account` model for each existing user and assign the user
   to their new account. All existing columns with the exception of any
   personally identifying information (like email address and password)
   would be copied from the `User` to the new `Account`.
3) Change all (most?) existing instances of `belongs_to :user` to
   `belongs_to :account`
4) Change all (most?) columns named `user_id` to be `account_id`
5) Other considerations?


## Allowing one `User` to work in multiple `Account`s

If we introduce a "join model" we can allow a single user to be conected
to multiple accounts.

The challeng here is the question of how we enable a user to actually
move across/between accounts.

### An account chooser screen

Maybe for a user that belongs to multiple accounts, after they sign in,
they see a screen listing their accounts and allowing them which to work
with. In addition we might have an "account" menu that would allow quick
switching.

### Add account to the URL in the app?

Currently if you're looking at a funnel the user slug is something like
`/funnels/42`. If we want to allow people to work across multiple
accounts with a minimum of friction and surprises we'd need to make the
url something like `/accounts/42/funnels/42`.

### Store the "current account" in the session?

If we don't want to alter our URL scheme we could potentially allow the
user the choose an acocunt and then store that in the session. The
problem with this approach is that it would only allow a user to be
working in one account at a time (even across different tabs) and could
lead to "surprises" where the user opens a form for Account A in one
tab, then opens a new tab, switches to Account B, then goes back to the
first tab to try to submit the form. At this point since Account B is
the current account, but the form is for Account A, we'd need to either
raise an error, OR allow the submission to proceed and then either
switch the current account back to A, so that we can show them a list
containing the item they just saved OR we'd forward them back to the
already current account (B) and show them a list of items that does not
contain the record they were just working with.

### Use the app on the account subdomain?

After a user signs in and chooses an account to work with we might
forward them to the subdomain for that account. So that they'd view
their list of funnels at
`https://account-subdomain.clickfunnels.com/funnels`.

I think that would give us the same benefits of adding the account ID to
the URL, but would not involve changing lots of routes.

It would not have the same drawbacks of error/surprises that the "store
the current account in the session" method would have.

(In a user-clusters world this approach may require some custom modifications
to doorkeeper to allow a wildcard based redirect URI. (Either that or we'd
need to register every subdomain with doorkeeper.))

## Sign-in on the subdomain

Another route we might take is to have people sign in directly on their
subdomain, and then scope the `uniqueness` validation on `User` to the
account level. So if one user were set up to work on Account A and
Account B, they would have two different user accounts (which might
share the same email address), but to work on each account the user
would need to know how to get to the proper sub-domain for each.

# Blog Backend

A JSON API for a blogging app: accounts, posts with tags and drafts, comments, and one vote per reader per post. Built with Ruby on Rails and PostgreSQL.

Started during a 2023 bootcamp by Joseph Villanueva and Ian Drilon, and finished in 2026 with ownership rules, token expiry, a reworked data model, and a full test suite.

## Features

- **Accounts:** register and log in to get a JSON Web Token that lasts 24 hours. Passwords are hashed with bcrypt and never returned.
- **Posts:** create, edit, and delete your own posts. Drafts are visible only to their author. Tags are normalized (trimmed, lowercased, de-duplicated).
- **Comments:** anyone can read them; signed-in users can comment. Authors edit their own comments, and a post's author can remove comments on it.
- **Votes:** up or down, one per user per post. Voting again replaces the earlier vote.
- **Tags:** a list of tags used on published posts, with counts.
- **Privacy:** public responses carry usernames only, never email addresses or password hashes.

## API

Send the token as `Authorization: Bearer <token>`. Errors return JSON with `error` or `errors` and a matching HTTP status (400, 401, 403, 404, or 422).

| Method | Path | Auth | Description |
| --- | --- | --- | --- |
| POST | `/users` | | Register (`username`, `email`, `password`); returns `{ user, token }` |
| POST | `/login` | | Log in (`username`, `password`); returns `{ user, token }` |
| GET | `/auto_login` | Required | The signed-in user |
| GET | `/blogs` | Optional | Published posts plus your own drafts, newest first; `?tag=rails` filters |
| GET | `/blogs/:id` | Optional | One post |
| POST | `/blogs` | Required | Create (`blog: { title, body, status, tags: [] }`) |
| PATCH | `/blogs/:id` | Author | Update |
| DELETE | `/blogs/:id` | Author | Delete |
| GET | `/blogs/:blog_id/comments` | | Comments on a post |
| POST | `/blogs/:blog_id/comments` | Required | Add a comment (`comment: { body }`) |
| PATCH | `/comments/:id` | Comment author | Edit a comment |
| DELETE | `/comments/:id` | Comment or post author | Remove a comment |
| POST | `/blogs/:blog_id/vote` | Required | Vote (`value`: `1` or `-1`); returns the new score |
| DELETE | `/blogs/:blog_id/vote` | Required | Remove your vote |
| GET | `/tags` | | Tags on published posts with counts |
| GET | `/up` | | Health check |

A post looks like this:

```json
{
  "id": 1,
  "title": "Writing acceptance criteria",
  "body": "Given, When, Then keeps every story testable.",
  "status": "published",
  "tags": ["product", "agile"],
  "author": { "id": 2, "username": "bob" },
  "score": 1,
  "comments_count": 1,
  "created_at": "2026-09-22T06:00:00.000Z",
  "updated_at": "2026-09-22T06:00:00.000Z"
}
```

## Running locally

Requires Ruby 3.2 and PostgreSQL.

```bash
bundle install
bin/rails db:setup      # creates the database, loads the schema, and seeds demo data
bin/rails server -p 4000
```

The seeds create two users, `alice` and `bob`, both with the password `password123`.

## Configuration

| Variable | Default | Purpose |
| --- | --- | --- |
| `PGHOST`, `PGPORT`, `PGUSER`, `PGPASSWORD` | `localhost`, `5432`, `postgres`, `postgres` | Database connection |
| `DATABASE_URL` | | Overrides the settings above, for production |
| `JWT_SECRET` | the app's `secret_key_base` | Signs login tokens |
| `CORS_ORIGINS` | `*` | Comma-separated origins allowed to call the API from a browser |

## Tests

```bash
bin/rails test
```

GitHub Actions runs the migrations, checks that `db/schema.rb` matches them, and runs the test suite on every push and pull request.

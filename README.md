# Rein

[Data integrity](http://en.wikipedia.org/wiki/Data_integrity) is a good thing.
Constraining the values allowed by your application at the database-level,
rather than at the application-level, is a more robust way of ensuring your
data stays sane.

Unfortunately, ActiveRecord doesn't encourage (or even allow) you to use
database integrity without resorting to hand-crafted SQL. Rein (pronounced
"rain") adds a handful of methods to your ActiveRecord migrations so that you
can easily tame the data in your database.

## Table of contents

* [Rein](#rein)
  * [Table of contents](#table-of-contents)
  * [Getting started](#getting-started)
  * [Constraint types](#constraint-types)
    * [Foreign key constraints](#foreign-key-constraints)
    * [Inclusion constraints](#inclusion-constraints)
    * [Numericality constraints](#numericality-constraints)
    * [Presence constraints](#presence-constraints)
  * [Example](#example)
  * [License](#license)

## Getting started

Install the gem:

    gem install rein

## Constraint types

### Foreign key constraints

A foreign key constraint specifies that the values in a column must match the
values appearing in some row of another table.

For example, let's say that we want to constrain the `author_id` column in the
`books` table to one of the `id` values in the `authors` table:

```ruby
add_foreign_key_constraint :books, :authors
```

Rein will automatically infer the column names for the tables, but if we need
to be explicit we can using the `referenced` and `referencing` options:

```ruby
add_foreign_key_constraint :books, :authors, referencing: :author_id, referenced: :id
```

We can also specify the behaviour when one of the referenced rows is updated or
deleted:

```ruby
add_foreign_key_constraint :books, :authors, on_delete: :cascade, on_update: :cascade
```

Here's all the options for specifying the delete/update behaviour:

- `no_action`: if any referencing rows still exist when the constraint is
  checked, an error is raised; this is the default behavior if you do not
  specify anything.
- `cascade`: when a referenced row is deleted, row(s) referencing it should be
  automatically deleted as well.
- `set_null`: sets the referencing columns to be nulls when the referenced row
  is deleted.
- `set_default`: sets the referencing columns to its default values when the
  referenced row is deleted.
- `restrict`: prevents deletion of a referenced row.

### Inclusion constraints

*(PostgreSQL only)*

An inclusion constraint specifies the possible values that a column value can
take.

For example, we can ensure that `state` column values can only ever be
`available` or `on_loan`:

```ruby
add_inclusion_constraint :books, :state, in: %w(available on_loan)
```

### Numericality constraints

*(PostgreSQL only)*

A numericality constraint specifies the range of values that a numeric column
value can take.

For example, we can ensure that the `publication_month` can only ever be a
value between 1 and 12:

```ruby
add_numericality_constraint :books, :publication_month,
  greater_than_or_equal_to: 1,
  less_than_or_equal_to: 12
```

Here's all the options for constraining the values:

- `equal_to`
- `not_equal_to`
- `less_than`
- `less_than_or_equal_to`
- `greater_than`
- `greater_than_or_equal_to`

### Presence constraints

*(PostgreSQL only)*

A presence constraint ensures that a string column value is non-empty.

A `NOT NULL` constraint will be satisfied by an empty string, but sometimes may
you want to ensure that there is an actual value for a string:

```ruby
add_presence_constraint :books, :title
```

If you only want to enforce the constraint under certain conditions,
you can pass an optional `if` option:

```ruby
add_presence_constraint :books, :isbn, if: "status = 'published'"
```

## Example

Let's have a look at constraining database values for this simple library
application.

Here we have a table of authors:

```ruby
create_table :authors do |t|
  t.string :name, null: false
  t.timestamps, null: false
end

# An author must have a name.
add_presence_constraint :authors, :name
```

We also have a table of books:

```ruby
create_table :books do |t|
  t.belongs_to :author, null: false
  t.string :title, null: false
  t.string :state, null: false
  t.integer :published_year, null: false
  t.integer :published_month, null: false
  t.timestamps, null: false
end

# A book should always belong to an author. The database should prevent us from
# deleteing an author who has books.
add_foreign_key_constraint :books, :authors, on_delete: :restrict

# A book must have a non-empty title.
add_presence_constraint :books, :title

# State is always either "available" or "on_loan".
add_inclusion_constraint :books, :state, in: %w(available on_loan)

# Our library doesn't deal in classics.
add_numericality_constraint :books, :published_year,
  greater_than_or_equal_to: 1980

# Month is always between 1 and 12.
add_numericality_constraint :books, :published_month,
  greater_than_or_equal_to: 1,
  less_than_or_equal_to: 12
```

## License

Rein is licensed under the [MIT License](/LICENSE).

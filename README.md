# ActiveRecord TiDB Adapter

A Rails ActiveRecord adapter that extends MySQL2 adapter with TiDB-specific features, particularly support for clustered and non-clustered indexes in migrations.

## Features

- **Clustered Index Support**: Control whether primary keys use clustered or non-clustered indexes
- **TiDB 5.0+ Compatible**: Supports TiDB's clustered index feature introduced in version 5.0
- **Seamless Integration**: Extends the standard MySQL2 adapter, maintaining compatibility with existing Rails applications

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activerecord-tidb-adapter'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install activerecord-tidb-adapter
```

## Requirements

- Ruby 3.2+
- Rails 7.2+
- TiDB 5.0+

## Usage

### Database Configuration

Configure your database connection in `config/database.yml`:

```yaml
development:
  adapter: tidb
  database: myapp_development
  host: 127.0.0.1
  port: 4000
  username: root
  password:
```

### Clustered Index in Migrations

The adapter allows you to specify whether a primary key should be clustered or non-clustered:

#### Single Column Primary Key with Clustered Index

```ruby
class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users, primary_key: [:id, clustered: true] do |t|
      t.bigint :id, null: false
      t.string :name
      t.string :email
      t.timestamps
    end
  end
end
```

This generates:

```sql
CREATE TABLE `users` (
  `id` bigint NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`) CLUSTERED
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin
```

#### Non-Clustered Index

```ruby
class CreateProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :products, primary_key: [:id, clustered: false] do |t|
      t.bigint :id, null: false
      t.string :name
      t.decimal :price
      t.timestamps
    end
  end
end
```

This generates:

```sql
CREATE TABLE `products` (
  `id` bigint NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `price` decimal(10,0) DEFAULT NULL,
  PRIMARY KEY (`id`) NONCLUSTERED
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin
```

### Composite Primary Keys

```ruby
class CreateOrderItems < ActiveRecord::Migration[7.2]
  def change
    create_table :order_items, primary_key: [:order_id, :product_id, clustered: true] do |t|
      t.bigint :order_id, null: false
      t.bigint :product_id, null: false
      t.integer :quantity
      t.timestamps
    end
  end
end
```

## Development

TBD.

### Running Tests

TBD.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/myoan/activerecord-tidb-adapter.

## License

TBD.

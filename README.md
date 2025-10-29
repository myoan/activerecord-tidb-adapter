# ActiveRecord TiDB Adapter

A Rails ActiveRecord adapter that extends MySQL2 adapter with TiDB-specific features, particularly support for clustered and non-clustered indexes in migrations.

## Features

- **Clustered Index Support**: Control whether primary keys use clustered or non-clustered indexes
- **TiDB Table Options**: Support for TiDB-specific table configuration options
  - `auto_id_cache`: Configure AUTO_ID_CACHE for better auto-increment performance
  - `shard_row_id_bits`: Distribute row IDs across multiple shards
  - `pre_split_regions`: Pre-split table regions for better initial performance
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

The adapter allows you to specify whether a primary key should be clustered or non-clustered using the `clustered` option:

#### Clustered Index (Table-Level Option)

```ruby
class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users, clustered: true do |t|
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
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`) CLUSTERED
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin
```

#### Non-Clustered Index

```ruby
class CreateProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :products, clustered: false do |t|
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
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `price` decimal(10,0) DEFAULT NULL,
  PRIMARY KEY (`id`) NONCLUSTERED
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin
```

#### Column-Level Clustered Option

You can also specify the `clustered` option at the column level for more control:

```ruby
class CreateOrders < ActiveRecord::Migration[7.2]
  def change
    create_table :orders do |t|
      t.bigint :id, primary_key: true, clustered: true, null: false
      t.integer :order_number
      t.timestamps
    end
  end
end
```

### Composite Primary Keys

```ruby
class CreateOrderItems < ActiveRecord::Migration[7.2]
  def change
    create_table :order_items, clustered: true do |t|
      t.bigint :order_id, null: false
      t.bigint :product_id, null: false
      t.integer :quantity
      t.timestamps
    end

    # Define composite primary key separately if needed
    execute "ALTER TABLE order_items ADD PRIMARY KEY (order_id, product_id) CLUSTERED"
  end
end
```

### TiDB-Specific Table Options

#### AUTO_ID_CACHE

Configure the cache size for auto-increment IDs to improve performance:

```ruby
class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users, auto_id_cache: 1000 do |t|
      t.string :name
      t.timestamps
    end
  end
end
```

This generates:

```sql
CREATE TABLE `users` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`) CLUSTERED
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin AUTO_ID_CACHE=1000
```

#### SHARD_ROW_ID_BITS

Distribute row IDs across multiple shards to avoid hotspots (requires non-clustered primary key):

```ruby
class CreateLogs < ActiveRecord::Migration[7.2]
  def change
    create_table :logs, clustered: false, shard_row_id_bits: 4 do |t|
      t.string :message
      t.timestamps
    end
  end
end
```

This generates:

```sql
CREATE TABLE `logs` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `message` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`) NONCLUSTERED
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin SHARD_ROW_ID_BITS=4
```

#### PRE_SPLIT_REGIONS

Pre-split table regions for better initial performance (used with `shard_row_id_bits`):

```ruby
class CreateEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :events, clustered: false, shard_row_id_bits: 4, pre_split_regions: 2 do |t|
      t.string :event_type
      t.timestamps
    end
  end
end
```

This generates:

```sql
CREATE TABLE `events` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `event_type` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`) NONCLUSTERED
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin SHARD_ROW_ID_BITS=4 PRE_SPLIT_REGIONS=2
```

## Development

TBD.

### Running Tests

TBD.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/myoan/activerecord-tidb-adapter.

## License

TBD.

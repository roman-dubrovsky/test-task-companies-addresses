# Test task

API-only Rails application to create companies with associated address. Allow to add companies both via single API request and via bulk CSV importing. [Full requirements](docs/Backend_Developer_Hometask.pdf). 

## Testing and linters

```bash
# Creating DB
bundle ex rails db:setup

# Run Rubocop Linters
bundle ex rails rubocop

# Run RSpec tests
bundle ex rails rspec

```

## Thoughts, conclusions, and implementation ideas 

### Batch Inserting 

During implementation, I thoughts if we need to care about N + 1 queries on creating new objects. So I implemented both variants and comment implementation with batch inserting.
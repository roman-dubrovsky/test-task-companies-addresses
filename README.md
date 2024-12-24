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

### Batch Inserting and N + 1

During implementation, I thoughts if we need to care about N + 1 queries on creating new objects. So I implemented both variants and comment implementation with batch inserting. For fixing N + 1 on bulk importing, I used `activerecord-import` for banch inserting and adds logic for memorization for uniqieness validation. There are some N + 1 issues with sending query for every uniq registration number, but I decided to ingore this issues for now.

### Validating CSV file

I just one question which is not clear from requirements: what if one CSV line is invalid. Should we just skip this line and process all other? Or should we firstly validate full CSV file and only after validation creates entities in the DB. I chose the second scenario. 

### Bulk importing logic

I prefer not to process the CSV file in the same request used to upload it. The file size and the time required for processing can be unpredictable, potentially leading to performance issues. Personally, I prefer to create a saparate model (e.g. `DataImport` and process the importing in the background). For user, we can just send `id` of data import, so that they can check the result and (or) we can send for the user notification when data import is finished (e.g. via WebHook or WebSocket to web application).

### Approach

I also used `dry-rb` libraries for most used patterns in my RoR develoment:

- Service Object: I used `dry-operation` just for supporting Railway (not rails way :smile:) Oriented Apporach. 
- Form Object: I used `dry-validation` for creating form objects. Usually, I prefer to use ActiveModel, but here I want to try this gem. I just thought that it's better for nested validations.

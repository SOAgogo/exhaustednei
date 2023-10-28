# GIPHY API Client

Project to gather search result and useful suggestion from GIPHY API 

## Resources

- GIFs
- Related Tags (It used to be displayed under the search bar, but it is no longer on the page.)

## Elements

- GIFs
  - title
  - url
  - height
  - width

- Related Tags
  - name

## Entities

These are objects that are important to the project, following my own naming conventions:

- Search results (with the gif and the related tags)

## Install

## Setting up this script

- Create a personal GIPHY API access token
- Copy `config/secrets_example.yml` to `config/secrets.yml` and update token
- Ensure correct version of Ruby install (see `.ruby-version` for `rbenv`)
- Run `bundle install`

## Running this script

To create fixtures, run:

```shell
ruby lib/GIPHY_API.rb
```

Fixture data should appear in `spec/fixtures/` folder

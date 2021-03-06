How to integrate a Registers-backed Location Picker into a Rails project
===

This guide will show you how to:

- Pull in data from the [Country](https://country.register.gov.uk/) and [Territory](https://territory.beta.openregister.org/) Register.
- Persist and update the data automatically.
- Populate a location picker [autocomplete field](https://github.com/alphagov/accessible-typeahead).

Other things you might be interested in:

- [Registers school demo](https://github.com/openregister/school-demo): A Rails app to demo access and display of school register data.
- [openregister-ruby](https://github.com/robmckinnon/openregister-ruby): A Ruby API to query registers.
- [e-petitions PR 435](https://github.com/alphagov/e-petitions/pull/435): This PR illustrates how the e-petitions project integrated with the Country register, and is similar to the work being carried out in this guide.

## What you need

This guide assumes you have a service that is written in Ruby on Rails and asks users to select a country or territory (a **location**). Something like this:

![An image consisting of a web form. There is a title that asks "What is your country of birth." There is a select box that has the preselected value of "United Kingdom". There is a submit button at the bottom.](example-form.png)

TODO: Style the example app to look GDSy.

At the end, your location picker will be populated automatically with data from Registers, and will look and function more like this:

![An animated image consisting of a web form. There is a label that reads "Country of birth." There is an empty text field. The text field is selected, and the characters "U N I" are typed in. A menu appears under the text field, it contains matching countries: "United Kingdom," "United States," "United Arab Emirates," "Tunisia." The first option, "United Kingdom", is clicked on. The text field now updates to contain "United Kingdom." The animation loops from the beginning.](location-picker-example.gif)

TODO: Replace with a gif of the actual location picker running in the same example app.

## The example application

To illustrate this process, this guide will use this application as a base: [openregister/rails-picker-example](https://github.com/openregister/rails-picker-example).

TODO: Fix link, create the actual repository.

Key things to know about the example app:

- It's barebones and based on the starter `rails new`, and a `rails generate`d `Answer` model/view/controller.
- The application asks users to provide their country of birth. This information is saved as an `Answer`.
- Users are provided with a select box that submits the relevant location code as part of an HTML form `POST` request.
- The location codes are persisted as [ISO 3166-1 alpha-2 codes](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2#Officially_assigned_code_elements). So if a user picks "United Kingdom," they submit `location_code: "GB"`.
- The list of recognised locations is defined in `app/helpers/answers_helper.rb` and consists of a hardcoded array of location names and codes.

## The process

We'll be updating the example app by doing the following:

- We'll replace the hardcoded array of locations with Registers data.
- We'll add an automated job to keep the data up to date.
- We'll enhance the frontend into an [accessible autocomplete](https://github.com/alphagov/accessible-typeahead) widget.

### Pulling in Registers data

The app currently defines the list of locations in `app/helpers/answers_helper.rb`. It's a simple hardcoded array of names and location codes:

```ruby
def locations_for_select
  [
    { "name": "Afghanistan", "location_code": "AF" },
    { "name": "Albania", "location_code": "AL" },
    # …snip…
  ]
end
```

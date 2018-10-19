'use strict'

/** @type {import('@adonisjs/lucid/src/Schema')} */
const Schema = use('Schema')

class ArtistsSchema extends Schema {
  up () {
    this.create('artists', (table) => {
      table.increments()
      table.timestamps()
      table.string('name')
    })
  }

  down () {
    this.drop('artists')
  }
}

module.exports = ArtistsSchema

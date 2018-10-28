'use strict'

/** @type {import('@adonisjs/lucid/src/Schema')} */
const Schema = use('Schema')

class AlbumsSchema extends Schema {
  up () {
    this.create('albums', (table) => {
      table.increments('id')
      table.timestamps()
      table.string('title')
      table.integer('year')
    })
  }

  down () {
    this.drop('albums')
  }
}

module.exports = AlbumsSchema

'use strict'

/** @type {import('@adonisjs/lucid/src/Schema')} */
const Schema = use('Schema')

class AlbumFormatsSchema extends Schema {
  up () {
    this.create('album_formats', (table) => {
      table.increments()
      table.integer('album_id').references('id').inTable('albums')
      table.integer('format_id').references('id').inTable('formats')
    })
  }

  down () {
    this.drop('album_formats')
  }
}

module.exports = AlbumFormatsSchema

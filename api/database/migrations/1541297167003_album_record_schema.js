'use strict'

/** @type {import('@adonisjs/lucid/src/Schema')} */
const Schema = use('Schema')

class AlbumRecordSchema extends Schema {
  up () {
    this.create('album_records', (table) => {
      table.increments('id')
      table.timestamps()
      table.integer('album_id').unsigned()
        .references('id')
        .inTable('albums');
      table.integer('format_id').unsigned()
        .references('id')
        .inTable('album_formats');
    })
  }

  down () {
    this.drop('album_records')
  }
}

module.exports = AlbumRecordSchema

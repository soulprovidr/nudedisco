'use strict'

/** @type {import('@adonisjs/lucid/src/Schema')} */
const Schema = use('Schema')

class AlbumRecordSchema extends Schema {
  up () {
    this.create('album_records', (table) => {
      table.increments()
      table.timestamps()
    })
  }

  down () {
    this.drop('album_records')
  }
}

module.exports = AlbumRecordSchema

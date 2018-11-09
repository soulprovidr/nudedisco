'use strict'

/** @type {import('@adonisjs/lucid/src/Schema')} */
const Schema = use('Schema');

class AlbumFormatSchema extends Schema {
  up () {
    this.create('album_formats', (table) => {
      table.increments();
      table.string('name');
    });
  }

  down () {
    this.drop('album_formats');
  }
}

module.exports = AlbumFormatSchema;

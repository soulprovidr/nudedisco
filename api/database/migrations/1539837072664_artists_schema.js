'use strict'

/** @type {import('@adonisjs/lucid/src/Schema')} */
const Schema = use('Schema');

class ArtistsSchema extends Schema {
  up () {
    this.create('artists', (table) => {
      table.increments('id');
      table.string('name').unique();
    });
  }

  down () {
    this.drop('artists');
  }
}

module.exports = ArtistsSchema;

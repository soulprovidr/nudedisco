'use strict'

/*
|--------------------------------------------------------------------------
| AlbumFormatSeeder
|--------------------------------------------------------------------------
|
| Make use of the Factory instance to seed database with dummy data or
| make use of Lucid models directly.
|
*/

/** @type {import('@adonisjs/lucid/src/Factory')} */
const Database = use('Database')
const Factory = use('Factory');

const AlbumFormats = [
  { name: 'Cassette' },
  { name: 'CD' },
  { name: 'Vinyl' }
];

class AlbumFormatSeeder {
  async run () {
    await Database.table('album_formats').insert(AlbumFormats);
  }
}

module.exports = AlbumFormatSeeder;

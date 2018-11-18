'use strict'

/** @type {typeof import('@adonisjs/lucid/src/Lucid/Model')} */
const Model = use('Model');

class AlbumRecord extends Model {
  album () {
    return this.belongsTo('App/Models/Album');
  }

  format () {
    return this.belongsTo('App/Models/AlbumFormat', 'format_id');
  }
}

module.exports = AlbumRecord;

'use strict'

/** @type {typeof import('@adonisjs/lucid/src/Lucid/Model')} */
const Model = use('Model');

class AlbumRecord extends Model {
  album () {
    return this.hasOne('App/Models/Album');
  }

  formats () {
    return this.hasMany('App/Models/Formats');
  }
}

module.exports = AlbumRecord;

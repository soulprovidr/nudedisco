'use strict'

/** @type {typeof import('@adonisjs/lucid/src/Lucid/Model')} */
const Model = use('Model');

class Album extends Model {
  artist () {
    return this.belongsTo('App/Models/Artist');
  }

  records () {
    return this.hasMany('App/Models/AlbumRecord');
  }
}

module.exports = Album;

'use strict'

/** @type {typeof import('@adonisjs/lucid/src/Lucid/Model')} */
const Model = use('Model')

class Album extends Model {
  artist () {
    return this.belongsTo('App/Model/Artist')
  }
}

module.exports = Album

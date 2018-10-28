'use strict'

const Database = use('Database')

/** @type {import('@adonisjs/lucid/src/Schema')} */
const Schema = use('Schema')

class FormatSchema extends Schema {
  up () {
    this.create('formats', (table) => {
      table.increments()
      table.string('name')
    })

    const formats = [
      { name: 'Vinyl' },
      { name: 'CD' },
      { name: 'Cassette' }
    ];

    this.schedule(async (trx) => {
      await Database.table('formats').transacting(trx).insert(formats)
    })
  }

  down () {
    this.drop('formats')
  }
}

module.exports = FormatSchema

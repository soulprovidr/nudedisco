'use strict'

/** @type {import('@adonisjs/lucid/src/Schema')} */
const Schema = use('Schema')

class FormatsSchema extends Schema {
  up () {
    this.create('formats', (table) => {
      table.increments()
      table.timestamps()
    })
  }

  down () {
    this.drop('formats')
  }
}

module.exports = FormatsSchema

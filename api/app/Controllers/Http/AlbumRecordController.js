'use strict'

const Record = use('App/Models/AlbumRecord');

/** @typedef {import('@adonisjs/framework/src/Request')} Request */
/** @typedef {import('@adonisjs/framework/src/Response')} Response */
/** @typedef {import('@adonisjs/framework/src/View')} View */

/**
 * Resourceful controller for interacting with albumrecords
 */
class AlbumRecordController {
  /**
   * Show a list of all albumrecords.
   * GET albumrecords
   *
   * @param {object} ctx
   * @param {Request} ctx.request
   * @param {Response} ctx.response
   * @param {View} ctx.view
   */
  async index ({ request, response, view }) {
    const records = await Record
      .query()
      .with('album.artist')
      .with('format')
      .fetch();
    return records.toJSON();
  }

  /**
   * Create/save a new albumrecord.
   * POST albumrecords
   *
   * @param {object} ctx
   * @param {Request} ctx.request
   * @param {Response} ctx.response
   */
  async store ({ request, response }) {
  }

  /**
   * Display a single albumrecord.
   * GET albumrecords/:id
   *
   * @param {object} ctx
   * @param {Request} ctx.request
   * @param {Response} ctx.response
   * @param {View} ctx.view
   */
  async show ({ params, request, response, view }) {
    const record = await Record.find(params.id);
    return record.toJSON();
  }

  /**
   * Update albumrecord details.
   * PUT or PATCH albumrecords/:id
   *
   * @param {object} ctx
   * @param {Request} ctx.request
   * @param {Response} ctx.response
   */
  async update ({ params, request, response }) {
  }

  /**
   * Delete a albumrecord with id.
   * DELETE albumrecords/:id
   *
   * @param {object} ctx
   * @param {Request} ctx.request
   * @param {Response} ctx.response
   */
  async destroy ({ params, request, response }) {
  }
}

module.exports = AlbumRecordController

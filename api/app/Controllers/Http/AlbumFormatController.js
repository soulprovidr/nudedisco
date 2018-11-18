'use strict'

const Format = use('App/Models/AlbumFormat');

/** @typedef {import('@adonisjs/framework/src/Request')} Request */
/** @typedef {import('@adonisjs/framework/src/Response')} Response */
/** @typedef {import('@adonisjs/framework/src/View')} View */

/**
 * Resourceful controller for interacting with albumformats
 */
class AlbumFormatController {
  /**
   * Show a list of all albumformats.
   * GET albumformats
   *
   * @param {object} ctx
   * @param {Request} ctx.request
   * @param {Response} ctx.response
   * @param {View} ctx.view
   */
  async index ({ request, response, view }) {
    const formats = await Format.all();
    return formats.toJSON();
  }

  /**
   * Display a single albumformat.
   * GET albumformats/:id
   *
   * @param {object} ctx
   * @param {Request} ctx.request
   * @param {Response} ctx.response
   * @param {View} ctx.view
   */
  async show ({ params, request, response, view }) {
    const format = await Format.find(params.id);
    return format.toJSON();
  }
}

module.exports = AlbumFormatController

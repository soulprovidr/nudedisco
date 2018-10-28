'use strict'

const Album = use('App/Models/Album');
const Format = use('App/Models/Format');

/** @typedef {import('@adonisjs/framework/src/Request')} Request */
/** @typedef {import('@adonisjs/framework/src/Response')} Response */
/** @typedef {import('@adonisjs/framework/src/View')} View */

/**
 * Resourceful controller for interacting with albums
 */
class AlbumController {
  /**
   * Show a list of all albums.
   * GET albums
   *
   * @param {object} ctx
   * @param {Request} ctx.request
   * @param {Response} ctx.response
   * @param {View} ctx.view
   */
  async index ({ request, response, view }) {
    const albums = await Album.all();
    const data = {
      albums: albums.toJSON()
    };
    return view.render('albums.index', data);
  }

  /**
   * Render a form to be used for creating a new album.
   * GET albums/create
   *
   * @param {object} ctx
   * @param {Request} ctx.request
   * @param {Response} ctx.response
   * @param {View} ctx.view
   */
  async create ({ request, response, view }) {
    const formats = await Format.all();
    const data = {
      formats: formats.toJSON()
    };
    return view.render('albums.create', data);
  }

  /**
   * Create/save a new album.
   * POST albums
   *
   * @param {object} ctx
   * @param {Request} ctx.request
   * @param {Response} ctx.response
   */
  async store ({ request, response }) {
    const body = request.post();
    console.log(body);
    const album = new Album();
    album.fill(body);
    await album.save();
    response.redirect('albums.index');
  }

  /**
   * Display a single album.
   * GET albums/:id
   *
   * @param {object} ctx
   * @param {Request} ctx.request
   * @param {Response} ctx.response
   * @param {View} ctx.view
   */
  async show ({ params, request, response, view }) {
  }

  /**
   * Render a form to update an existing album.
   * GET albums/:id/edit
   *
   * @param {object} ctx
   * @param {Request} ctx.request
   * @param {Response} ctx.response
   * @param {View} ctx.view
   */
  async edit ({ params, request, response, view }) {
  }

  /**
   * Update album details.
   * PUT or PATCH albums/:id
   *
   * @param {object} ctx
   * @param {Request} ctx.request
   * @param {Response} ctx.response
   */
  async update ({ params, request, response }) {
  }

  /**
   * Delete a album with id.
   * DELETE albums/:id
   *
   * @param {object} ctx
   * @param {Request} ctx.request
   * @param {Response} ctx.response
   */
  async destroy ({ params, request, response }) {
  }
}

module.exports = AlbumController

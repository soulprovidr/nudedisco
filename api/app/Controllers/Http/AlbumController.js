'use strict'

const Album = use('App/Models/Album');
const Artist = use('App/Models/Artist');
const Format = use('App/Models/AlbumFormat');
const Record = use('App/Models/AlbumRecord');

/** @typedef {import('@adonisjs/framework/src/Request')} Request */
/** @typedef {import('@adonisjs/framework/src/Response')} Response */
/** @typedef {import('@adonisjs/framework/src/View')} View */

const createRecord = async (album, format) => {
  const record = new Record();
  await record.save();
  await record.format().associate(format);
  await record.album().associate(album);
  return record;
};

const createRecordsFromFormatCounts = async (album, formatCounts) => {
  return formatCounts.reduce(async (acc, { id, count }) => {
    const allRecords = await acc;
    const format = await Format.find(id);
    for (let i = 0; i < count; i++) {
      const newRecord = await createRecord(album, format)
      allRecords.push(newRecord); 
    }
    return allRecords;
  }, []);
};

const getOrCreateArtist = async (name) => {
  try {
    return await Artist.findByOrFail('name', name);
  } catch (e) {
    return await Artist.create({ name });
  }
}

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
    const albums = await Album
      .query()
      .with('artist')
      .with('records.format')
      .fetch();
    return albums.toJSON();
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
    const {
      artist: artistName,
      formats,
      title,
      year
    } = request.post();

    // Create album.
    const album = new Album();
    album.merge({ title, year });
    await album.save();

    // Get (or create) + associate artist.
    const artist = await getOrCreateArtist(artistName);
    album.artist().associate(artist);

    // Create records.
    const records = await createRecordsFromFormatCounts(album, formats);
    console.log(records);

    response.status(201);
    return album.toJSON();
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

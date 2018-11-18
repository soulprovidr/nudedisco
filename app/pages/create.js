import React, { Component } from 'react';
import axios from'axios';
import Link from 'next/link';

import Head from '../components/head';
import Nav from '../components/nav';

import 'tachyons/css/tachyons.css';

const Release = ({ release }) => (
  release.thumbnail ? (
    <div className="db center mw5 black link dim">
      <img
        className="db ba b--black-10"
        alt="Frank Ocean Blonde Album Cover"
        src={release.thumbnail}
      />

      <dl className="mt2 f6 lh-copy">
        <dt className="clip">Title</dt>
        <dd className="ml0 fw9">{release.title}</dd>
        <dt className="clip">Artist</dt>
        <dd className="ml0 gray">{release['artist-credit'][0].artist.name}</dd>
      </dl>
    </div>
  ) : null
);

const getThumbnail = async (albumId) => {
  const { data } = await axios.get(`
    https://coverartarchive.org/release/${albumId}
  `);
  const frontImage = data.images.find(img => img.types.includes('Front'));
  return frontImage.thumbnails.small || null;
};

const getReleases = async (artist, title) => {
  const { data } = await axios.get(`
    https://musicbrainz.org/ws/2/release/?query=artist:${artist}%20AND%20release:${title}&fmt=json
  `);
  return data.releases;
}

class Create extends Component {
  state = {
    title: '',
    artist: '',
    releases: []
  };

  searchReleases = async () => {
    const { artist, title } = this.state;
    let releases = await getReleases(artist, title);
    releases = await Promise.all(
      releases.map(this.setCoverArt)
    );
    this.setState({ releases });
  };

  setCoverArt = async (release) => {
    let thumbnail = null;
    try {
      thumbnail = await getThumbnail(release.id);
    } catch (e) {
      // 
    }
    return Object.assign({}, release, { thumbnail });
  };

  onChange = (e) => {
    this.setState({ [e.target.name]: e.target.value });
  };

  render() {
    const { artist, releases, title } = this.state;
    return (
      <section className="mw7 center pa4 sans-serif black-80">
        <Head title="Create" />
        <div className="flex">

          <div className="w-20">
            {releases.map(r => (
              <Release release={r} />
            ))}
          </div>

          <form className="w-80">
            <div className="mv3">
              <label
                className="f6 b db mb2"
                htmlFor="title"
              >
                Artist
              </label>
              <input
                className="input-reset ba b--black-20 pa2 mb2 db w-100 br2"
                name="artist"
                onChange={this.onChange}
                type="text"
                value={artist}
              />
            </div>
            <div className="mv3">
              <label
                className="f6 b db mb2"
                htmlFor="title"
              >
                Title
              </label>
              <input
                className="input-reset ba b--black-20 pa2 mb2 db w-100 br2"
                name="title"
                onChange={this.onChange}
                type="text"
                value={title}
              />
            </div>
            <div className="mv3">
              <button
                className="f6 link br2 ph3 pv2 mb2 dib white bg-black"
                onClick={this.searchReleases}
                type="button"
              >
                Search
              </button>
            </div>
          </form>
        </div>
      </section>
    );
  }
}

export default Create;

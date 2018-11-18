import React, { Component } from 'react';
import axios from'axios';
import Link from 'next/link';

import Head from '../components/head';
import Nav from '../components/nav';

import 'tachyons/css/tachyons.min.css';

const getInitialProps = async ({ req }) => {
  const { data: albums } = await axios.get('http://localhost:3333/albums');
  return { albums };
};

const AlbumDetail = ({ album }) => (
  <div className="album card is-shadowless">
    <div className="card-image">
      <figure className="image is-square">
        <img src="https://bulma.io/images/placeholders/1280x960.png" alt="Placeholder image" />
      </figure>
    </div>
    <div className="card-content">
      <div className="media">
        <div className="media-content">
          <p className="title is-4">
            {album.title}
          </p>
          <p className="subtitle is-6">
            {album.artist.name}
          </p>
        </div>
      </div>

      <div className="content">
        <table className="b--black-10">
          <thead>
            <td></td>
          </thead>
        </table>
      </div>
    </div>
  </div>
);

class Home extends Component {
  state = {
    selectedAlbum: null
  };

  onSelect = (album) => {
    this.setState({ selectedAlbum: album });
  };

  render() {
    const { albums } = this.props;
    const { selectedAlbum } = this.state;
    return (
      <section className="mw7 center pa4 sans-serif">
        <Head title="Home" />
        <table className="ba b--black-10 w-100">
          <thead>
            <tr>
              <th className="pv2 ph3 tl">
                Album
              </th>
              <th className="pv2 ph3 tl">
                Artist
              </th>
              <th className="pv2 ph3 tl">
                Quantity
              </th>
            </tr>
          </thead>
          <tbody>
            {albums.map(a => (
              <tr
                className="striped--near-white"
                onClick={() => this.onSelect(a)}
              >
                <td className="pv2 ph3">
                  {a.title}
                </td>
                <td className="pv2 ph3">
                  {a.artist.name}
                </td>
                <td className="pv2 ph3">
                  {a.records.length}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </section>
    );
  }
}

Home.getInitialProps = getInitialProps;

export default Home;

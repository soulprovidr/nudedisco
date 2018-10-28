import React, { Component } from 'react'
import { render } from 'react-dom'

class AlbumCreateForm extends Component {
  render () {
    const { formats } = window.__data__;
    return (
      <>
        <div className="columns">

          <div className="column is-one-third">
            <img src="/album.jpg" />
          </div>

          <div className="column is-two-thirds">
            <div className="field">
              <div className="control">
                <label
                  className="label"
                  for="title"
                >
                  Title
                </label>
                <input
                  className="input"
                  type="text"
                  name="title"
                />
              </div>
            </div>

            <div className="field">
              <label
                className="label"
                for="artist"
              >
                Artist
              </label>
              <input
                className="input"
                type="text"
                name="artist"
              />
            </div>
          </div>
        
        </div>

        <table className="table is-fullwidth">
          <thead>
            <td>Format</td>
            <td>Quantity</td>
          </thead>
          <tbody>
            {formats.map(f => (
              <tr>
                <td>
                  {f.name}
                </td>
                <td>
                  <input
                    type="number"
                    class="input"
                    value="3"
                  />
                </td>
              </tr>
            ))}
          </tbody>
        </table>

        <div className="field">
          <div className="control">
            <button
              className="button is-link"
              type="submit"
            >
              Save
            </button>
          </div>
        </div>
      </>
    )
  }
}

render(
  <AlbumCreateForm />,
  document.querySelector('.__root')
)